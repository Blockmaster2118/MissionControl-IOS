//
//  RecordFlightUseCaseTests.swift
//  MissionControlTests
//

import Testing
import Foundation
@testable import MissionControl

struct RecordFlightUseCaseTests {

    private func seededStores(status: MissionStatus = .ready) -> (aircraft: InMemoryStore<Aircraft>, missions: InMemoryStore<Mission>, flights: InMemoryStore<FlightRecord>, missionID: UUID) {
        let aircraft = Aircraft(name: "DJI-01", serialNumber: "SIM-0001")
        let mission = Mission(name: "Roof Inspection", site: "12 Harbour St", scheduledDate: Date(), aircraftID: aircraft.id, status: status)
        return (InMemoryStore(items: [aircraft]), InMemoryStore(items: [mission]), InMemoryStore<FlightRecord>(), mission.id)
    }

    @Test func recordFlight_marksMissionFlown_andKeepsTheFlightRecord() throws {
        let (aircraftStore, missionStore, flightStore, missionID) = seededStores()
        let useCase = RecordFlightUseCase(aircraftStore: aircraftStore, missionStore: missionStore, flightStore: flightStore)

        let flight = try useCase.execute(missionID: missionID, startTime: Date(), duration: 1_200, outcome: "Roof captured", observations: "", newDefect: "")

        #expect(flight.duration == 1_200)
        #expect(flightStore.loadAll().count == 1)
        #expect(missionStore.loadAll().first?.status == .flown)
    }

    @Test func recordFlight_groundsTheAircraft_whenANewDefectIsObserved() throws {
        let (aircraftStore, missionStore, flightStore, missionID) = seededStores()
        let useCase = RecordFlightUseCase(aircraftStore: aircraftStore, missionStore: missionStore, flightStore: flightStore)

        try useCase.execute(missionID: missionID, startTime: Date(), duration: 60, outcome: "OK", observations: "", newDefect: "Gimbal vibration")

        #expect(aircraftStore.loadAll().first?.openDefects == ["Gimbal vibration"])
    }

    @Test func recordFlight_fails_whenPreFlightInspectionIsIncomplete() {
        let (aircraftStore, missionStore, flightStore, missionID) = seededStores(status: .planned)
        let useCase = RecordFlightUseCase(aircraftStore: aircraftStore, missionStore: missionStore, flightStore: flightStore)

        do {
            _ = try useCase.execute(missionID: missionID, startTime: Date(), duration: 600, outcome: "", observations: "", newDefect: "")
            Issue.record("Expected FlightRecordingError.preFlightInspectionIncomplete to be thrown")
        } catch FlightRecordingError.preFlightInspectionIncomplete {
            // expected
        } catch {
            Issue.record("Expected .preFlightInspectionIncomplete but got \(error)")
        }
    }

    @Test func recordFlight_fails_whenDurationIsZero() {
        let (aircraftStore, missionStore, flightStore, missionID) = seededStores()
        let useCase = RecordFlightUseCase(aircraftStore: aircraftStore, missionStore: missionStore, flightStore: flightStore)

        do {
            _ = try useCase.execute(missionID: missionID, startTime: Date(), duration: 0, outcome: "", observations: "", newDefect: "")
            Issue.record("Expected FlightRecordingError.invalidDuration to be thrown")
        } catch FlightRecordingError.invalidDuration {
            // expected
        } catch {
            Issue.record("Expected .invalidDuration but got \(error)")
        }
    }
}
