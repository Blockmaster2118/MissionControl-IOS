//
//  DataStore.swift
//  MissionControl
//

import Foundation
import Combine
import WidgetKit

@MainActor
final class DataStore: ObservableObject {
    @Published private(set) var aircraft: [Aircraft] = []
    @Published private(set) var missions: [Mission] = []
    @Published private(set) var flights: [FlightRecord] = []
    @Published private(set) var outstandingToday: [Mission] = []
    @Published private(set) var briefs: [SharedBrief] = []

    private let aircraftStore = SwiftDataAircraftStore()
    private let missionStore = SwiftDataMissionStore()
    private let flightStore = SwiftDataFlightStore()

    init() {
        seedDemoDataIfNeeded()
        loadAll()
    }

    func loadAll() {
        aircraft = aircraftStore.loadAll().sorted { $0.name < $1.name }
        missions = missionStore.loadAll().sorted { $0.scheduledDate < $1.scheduledDate }
        flights = flightStore.loadAll().sorted { $0.startTime > $1.startTime }
        outstandingToday = missionStore.outstandingMissions(on: Date())
        briefs = SharedStore.pendingBriefs()
        publishNextMissionSnapshot()
    }

    // MARK: - Aircraft: register (Use Case), update (simple CRUD)

    @discardableResult
    func registerAircraft(name: String, serialNumber: String, notes: String) throws -> Aircraft {
        let useCase = RegisterAircraftUseCase(aircraftStore: aircraftStore)
        defer { loadAll() }
        return try useCase.execute(name: name, serialNumber: serialNumber, notes: notes)
    }

    func updateAircraft(_ updated: Aircraft) {
        var allAircraft = aircraftStore.loadAll()
        guard let index = allAircraft.firstIndex(where: { $0.id == updated.id }) else { return }
        allAircraft[index] = updated
        aircraftStore.save(allAircraft)
        loadAll()
    }

    func recordRepair(on aircraft: Aircraft) {
        var repaired = aircraft
        repaired.openDefects = []
        updateAircraft(repaired)
    }

    // MARK: - Mission: plan (Use Case), inspect (Use Case), attach brief (simple CRUD)

    @discardableResult
    func planMission(name: String, site: String, date: Date, aircraftID: UUID?) throws -> Mission {
        let useCase = PlanMissionUseCase(aircraftStore: aircraftStore, missionStore: missionStore)
        defer { loadAll() }
        return try useCase.execute(name: name, site: site, date: date, aircraftID: aircraftID)
    }

    @discardableResult
    func completeInspection(missionID: UUID, items: [InspectionItem]) throws -> Mission {
        let useCase = CompletePreFlightInspectionUseCase(aircraftStore: aircraftStore, missionStore: missionStore)
        defer { loadAll() }   // a failed check still grounds the aircraft, so always reload
        return try useCase.execute(missionID: missionID, items: items)
    }

    func attachBrief(_ brief: SharedBrief, to mission: Mission) {
        var allMissions = missionStore.loadAll()
        guard let index = allMissions.firstIndex(where: { $0.id == mission.id }) else { return }
        allMissions[index].briefs.append(brief.content)
        missionStore.save(allMissions)
        SharedStore.discard(brief)
        loadAll()
    }

    // MARK: - Flight: record (Use Case)

    @discardableResult
    func recordFlight(
        missionID: UUID,
        startTime: Date,
        duration: TimeInterval,
        outcome: String,
        observations: String,
        newDefect: String
    ) throws -> FlightRecord {
        let useCase = RecordFlightUseCase(aircraftStore: aircraftStore, missionStore: missionStore, flightStore: flightStore)
        defer { loadAll() }
        return try useCase.execute(
            missionID: missionID,
            startTime: startTime,
            duration: duration,
            outcome: outcome,
            observations: observations,
            newDefect: newDefect
        )
    }

    // MARK: - Lookups

    func aircraft(for id: UUID) -> Aircraft? {
        aircraft.first { $0.id == id }
    }

    func mission(for id: UUID) -> Mission? {
        missions.first { $0.id == id }
    }

    func flightsForMission(_ missionID: UUID) -> [FlightRecord] {
        flights.filter { $0.missionID == missionID }
    }

    func flightsForAircraft(_ aircraftID: UUID) -> [FlightRecord] {
        flights.filter { $0.aircraftID == aircraftID }
    }

    func flightSummary(forAircraft aircraftID: UUID) -> FlightSummary {
        FlightSummary(flights: flightsForAircraft(aircraftID))
    }

    var awaitingInspection: [Mission] {
        missions.filter { $0.status == .planned }
    }

    var groundedAircraft: [Aircraft] {
        aircraft.filter(\.isGrounded)
    }

    var recentlyFlown: [Mission] {
        Array(missions.filter { $0.status == .flown }.suffix(3).reversed())
    }

    // MARK: - Demo data

    /// Simulated aircraft and mission so the whole workflow can be demonstrated without a real drone.
    private func seedDemoDataIfNeeded() {
        guard aircraftStore.loadAll().isEmpty else { return }
        let primary = Aircraft(name: "DJI-01", serialNumber: "SIM-0001")
        let spare = Aircraft(name: "DJI-02", serialNumber: "SIM-0002")
        aircraftStore.save([primary, spare])
        let tomorrowMorning = Calendar.current.date(bySettingHour: 9, minute: 30, second: 0, of: Date().addingTimeInterval(86_400)) ?? Date()
        missionStore.save([Mission(name: "Roof Inspection", site: "12 Harbour St, Sydney", scheduledDate: tomorrowMorning, aircraftID: primary.id)])
    }
}
