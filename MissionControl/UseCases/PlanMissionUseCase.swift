//
//  PlanMissionUseCase.swift
//  MissionControl
//
//  MissionControl's essential question is "how can we help small commercial drone operators know, before every flight, which mission they're flying, with which aircraft, and whether it is ready" - planning a mission is where that workflow starts, so it gets its own Use Case rather than being a bare "append to an array" call made from a View.

import Foundation

struct PlanMissionUseCase<AircraftStore: PersistenceStore, MissionStore: PersistenceStore>
where AircraftStore.Entity == Aircraft, MissionStore.Entity == Mission {
    let aircraftStore: AircraftStore
    let missionStore: MissionStore
    private let now: () -> Date

    init(aircraftStore: AircraftStore, missionStore: MissionStore, now: @escaping () -> Date = Date.init) {
        self.aircraftStore = aircraftStore
        self.missionStore = missionStore
        self.now = now
    }

    /// Plans a new mission, validating it against MissionControl's planning rules first.
    /// Throws: `MissionPlanningError` if no aircraft was chosen, the aircraft isn't registered, the site is blank or the date has already passed.

    @discardableResult
    func execute(name: String, site: String, date: Date, aircraftID: UUID?) throws -> Mission {
        guard let aircraftID else {
            throw MissionPlanningError.missingAircraft
        }

        guard aircraftStore.loadAll().contains(where: { $0.id == aircraftID }) else {
            throw MissionPlanningError.aircraftNotRegistered(aircraftID: aircraftID)
        }

        let trimmedSite = site.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedSite.isEmpty else {
            throw MissionPlanningError.missingSite
        }

        guard date >= Calendar.current.startOfDay(for: now()) else {
            throw MissionPlanningError.scheduledDateInPast(date: date)
        }

        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let mission = Mission(name: trimmedName.isEmpty ? "Site mission" : trimmedName, site: trimmedSite, scheduledDate: date, aircraftID: aircraftID)
        missionStore.save(missionStore.loadAll() + [mission])
        return mission
    }
}

enum MissionPlanningError: LocalizedError, Equatable {
    /// Who hits this: an operator tries to save a mission without choosing which aircraft will fly it.
    /// Recovery: choose an aircraft, or register one first.
    case missingAircraft

    /// Who hits this: an operator tries to plan a mission with an aircraft that was removed from the register.
    /// Recovery: choose another aircraft, or register it again.
    case aircraftNotRegistered(aircraftID: UUID)

    /// Who hits this: an operator left the site location empty.
    /// Recovery: enter where the mission takes place.
    case missingSite

    /// Who hits this: an operator picks a date that has already passed.
    /// Recovery: choose today or a later date.
    case scheduledDateInPast(date: Date)

    var errorDescription: String? {
        switch self {
        case .missingAircraft:
            return "Choose an aircraft before saving this mission."
        case .aircraftNotRegistered:
            return "That aircraft isn't in your Aircraft Register any more. Choose another aircraft, or add it again under Aircraft."
        case .missingSite:
            return "Enter the site location so you know where this mission takes place."
        case .scheduledDateInPast:
            return "That date has already passed. Choose today or a later date."
        }
    }
}
