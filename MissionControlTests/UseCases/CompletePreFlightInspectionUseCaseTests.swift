//
//  CompletePreFlightInspectionUseCaseTests.swift
//  MissionControlTests
//

import Testing
import Foundation
@testable import MissionControl

struct CompletePreFlightInspectionUseCaseTests {

    private func seededStores(openDefects: [String] = []) -> (aircraft: InMemoryStore<Aircraft>, missions: InMemoryStore<Mission>, mission: Mission) {
        let aircraft = Aircraft(name: "DJI-01", serialNumber: "SIM-0001", openDefects: openDefects)
        let mission = Mission(name: "Roof Inspection", site: "12 Harbour St", scheduledDate: Date().addingTimeInterval(86_400), aircraftID: aircraft.id)
        return (InMemoryStore(items: [aircraft]), InMemoryStore(items: [mission]), mission)
    }

    private func allPassed(_ mission: Mission) -> [InspectionItem] {
        mission.inspection.map { item in
            var passed = item
            passed.result = .pass
            return passed
        }
    }

    @Test func completeInspection_marksMissionReady_whenEveryCheckPasses() throws {
        let (aircraftStore, missionStore, mission) = seededStores()
        let useCase = CompletePreFlightInspectionUseCase(aircraftStore: aircraftStore, missionStore: missionStore)

        let inspected = try useCase.execute(missionID: mission.id, items: allPassed(mission))

        #expect(inspected.status == .ready)
        #expect(missionStore.loadAll().first?.status == .ready)
    }

    @Test func completeInspection_fails_whenAMandatoryCheckIsNotRecorded() {
        let (aircraftStore, missionStore, mission) = seededStores()
        let useCase = CompletePreFlightInspectionUseCase(aircraftStore: aircraftStore, missionStore: missionStore)
        var items = allPassed(mission)
        items[1].result = .notChecked

        do {
            _ = try useCase.execute(missionID: mission.id, items: items)
            Issue.record("Expected PreFlightInspectionError.mandatoryCheckNotRecorded to be thrown")
        } catch PreFlightInspectionError.mandatoryCheckNotRecorded(let checkName) {
            #expect(checkName == "Propellers")
        } catch {
            Issue.record("Expected .mandatoryCheckNotRecorded but got \(error)")
        }
    }

    @Test func completeInspection_groundsAircraftAndKeepsMissionInPreparation_whenPropellerFails() {
        let (aircraftStore, missionStore, mission) = seededStores()
        let useCase = CompletePreFlightInspectionUseCase(aircraftStore: aircraftStore, missionStore: missionStore)
        var items = allPassed(mission)
        items[1].result = .fail
        items[1].notes = "cracked blade"

        do {
            _ = try useCase.execute(missionID: mission.id, items: items)
            Issue.record("Expected PreFlightInspectionError.safetyCheckFailed to be thrown")
        } catch PreFlightInspectionError.safetyCheckFailed(let checkName) {
            #expect(checkName == "Propellers")
            #expect(aircraftStore.loadAll().first?.isGrounded == true)
            #expect(missionStore.loadAll().first?.status == .planned)
        } catch {
            Issue.record("Expected .safetyCheckFailed but got \(error)")
        }
    }

    @Test func completeInspection_fails_whenAircraftHasAnUnresolvedDefect() {
        let (aircraftStore, missionStore, mission) = seededStores(openDefects: ["Propellers: cracked blade"])
        let useCase = CompletePreFlightInspectionUseCase(aircraftStore: aircraftStore, missionStore: missionStore)

        do {
            _ = try useCase.execute(missionID: mission.id, items: allPassed(mission))
            Issue.record("Expected PreFlightInspectionError.aircraftHasUnresolvedDefect to be thrown")
        } catch PreFlightInspectionError.aircraftHasUnresolvedDefect {
            // expected
        } catch {
            Issue.record("Expected .aircraftHasUnresolvedDefect but got \(error)")
        }
    }
}
