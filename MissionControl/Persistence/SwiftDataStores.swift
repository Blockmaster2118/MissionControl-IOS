//
//  SwiftDataStores.swift
//  MissionControl
//

import Foundation
import SwiftData

// MARK: - SwiftData models

@Model final class StoredAircraft {
    @Attribute(.unique) var id: UUID
    var name = ""
    var serialNumber = ""
    var notes = ""
    var openDefects: [String] = []
    @Relationship(inverse: \StoredMission.aircraft) var missions: [StoredMission] = []
    init(id: UUID) { self.id = id }
}

@Model final class StoredMission {
    @Attribute(.unique) var id: UUID
    var name = ""
    var site = ""
    var scheduledDate = Date()
    var statusRaw = MissionStatus.planned.rawValue
    var inspection: [InspectionItem] = []
    var briefs: [String] = []
    var aircraft: StoredAircraft?
    @Relationship(inverse: \StoredFlight.mission) var flights: [StoredFlight] = []
    init(id: UUID) { self.id = id }
}

@Model final class StoredFlight {
    @Attribute(.unique) var id: UUID
    var startTime = Date()
    var duration: TimeInterval = 0
    var outcome = ""
    var observations = ""
    var mission: StoredMission?
    init(id: UUID) { self.id = id }
}

// MARK: - Shared stack

struct SwiftDataStack {
    static let shared = SwiftDataStack()
    let context: ModelContext

    init(inMemory: Bool = false) {
        do {
            let container = try ModelContainer(
                for: StoredAircraft.self, StoredMission.self, StoredFlight.self,
                configurations: ModelConfiguration(isStoredInMemoryOnly: inMemory)
            )
            context = ModelContext(container)
        } catch {
            fatalError("MissionControl couldn't open its SwiftData store: \(error)")
        }
    }
}

/// Makes the stored rows match `items`: updates existing rows, inserts new ones and deletes any row whose entity is no longer in the list.
private func replaceAll<Model: PersistentModel, Entity: PersistableEntity>(
    _ items: [Entity],
    of modelType: Model.Type,
    in context: ModelContext,
    id: (Model) -> UUID,
    apply: (Model?, Entity) -> Void
) {
    let existing = (try? context.fetch(FetchDescriptor<Model>())) ?? []
    let keep = Set(items.map(\.id))
    for stored in existing where !keep.contains(id(stored)) { context.delete(stored) }
    for item in items { apply(existing.first { id($0) == item.id }, item) }
    try? context.save()
}

// MARK: - Aircraft

struct SwiftDataAircraftStore: PersistenceStore {
    private let context: ModelContext

    init(stack: SwiftDataStack = .shared) { context = stack.context }

    func loadAll() -> [Aircraft] {
        let stored = (try? context.fetch(FetchDescriptor<StoredAircraft>())) ?? []
        return stored.map { Aircraft(id: $0.id, name: $0.name, serialNumber: $0.serialNumber, notes: $0.notes, openDefects: $0.openDefects) }
    }

    func save(_ items: [Aircraft]) {
        replaceAll(items, of: StoredAircraft.self, in: context, id: { $0.id }) { stored, item in
            let model = stored ?? StoredAircraft(id: item.id)
            if stored == nil { context.insert(model) }
            model.name = item.name
            model.serialNumber = item.serialNumber
            model.notes = item.notes
            model.openDefects = item.openDefects
        }
    }
}

// MARK: - Missions

struct SwiftDataMissionStore: PersistenceStore {
    private let context: ModelContext

    init(stack: SwiftDataStack = .shared) { context = stack.context }

    func loadAll() -> [Mission] {
        let stored = (try? context.fetch(FetchDescriptor<StoredMission>())) ?? []
        return stored.compactMap(Self.mission)
    }

    /// Domain query: missions scheduled on `day` that have not yet been flown.
    func outstandingMissions(on day: Date) -> [Mission] {
        let start = Calendar.current.startOfDay(for: day)
        let end = Calendar.current.date(byAdding: .day, value: 1, to: start) ?? start
        let flown = MissionStatus.flown.rawValue
        let predicate = #Predicate<StoredMission> { $0.scheduledDate >= start && $0.scheduledDate < end && $0.statusRaw != flown }
        let stored = (try? context.fetch(FetchDescriptor<StoredMission>(predicate: predicate, sortBy: [SortDescriptor(\.scheduledDate)]))) ?? []
        return stored.compactMap(Self.mission)
    }

    func save(_ items: [Mission]) {
        replaceAll(items, of: StoredMission.self, in: context, id: { $0.id }) { stored, item in
            let model = stored ?? StoredMission(id: item.id)
            if stored == nil { context.insert(model) }
            model.name = item.name
            model.site = item.site
            model.scheduledDate = item.scheduledDate
            model.statusRaw = item.status.rawValue
            model.inspection = item.inspection
            model.briefs = item.briefs
            let aircraftID = item.aircraftID
            model.aircraft = try? context.fetch(FetchDescriptor<StoredAircraft>(predicate: #Predicate { $0.id == aircraftID })).first
        }
    }

    private static func mission(_ stored: StoredMission) -> Mission? {
        guard let aircraft = stored.aircraft else { return nil }
        return Mission(id: stored.id, name: stored.name, site: stored.site, scheduledDate: stored.scheduledDate, aircraftID: aircraft.id,
                       status: MissionStatus(rawValue: stored.statusRaw) ?? .planned, inspection: stored.inspection, briefs: stored.briefs)
    }
}

// MARK: - Flights

struct SwiftDataFlightStore: PersistenceStore {
    private let context: ModelContext

    init(stack: SwiftDataStack = .shared) { context = stack.context }

    func loadAll() -> [FlightRecord] {
        let stored = (try? context.fetch(FetchDescriptor<StoredFlight>())) ?? []
        return stored.compactMap { flight in
            guard let mission = flight.mission, let aircraft = mission.aircraft else { return nil }
            return FlightRecord(id: flight.id, missionID: mission.id, aircraftID: aircraft.id, startTime: flight.startTime,
                                duration: flight.duration, outcome: flight.outcome, observations: flight.observations)
        }
    }

    func save(_ items: [FlightRecord]) {
        replaceAll(items, of: StoredFlight.self, in: context, id: { $0.id }) { stored, item in
            let model = stored ?? StoredFlight(id: item.id)
            if stored == nil { context.insert(model) }
            model.startTime = item.startTime
            model.duration = item.duration
            model.outcome = item.outcome
            model.observations = item.observations
            let missionID = item.missionID
            model.mission = try? context.fetch(FetchDescriptor<StoredMission>(predicate: #Predicate { $0.id == missionID })).first
        }
    }
}
