//
//  PlanMissionUseCaseTests.swift
//  MissionControlTests
//

import Testing
import Foundation
@testable import MissionControl

struct PlanMissionUseCaseTests {

    private func seededAircraftStore() -> (store: InMemoryStore<Aircraft>, aircraftID: UUID) {
        let aircraft = Aircraft(name: "DJI-01", serialNumber: "SIM-0001")
        return (InMemoryStore(items: [aircraft]), aircraft.id)
    }

    private let noon = Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: Date()) ?? Date()

    @Test func planMission_succeeds_withRegisteredAircraftAndFutureDate() throws {
        let (aircraftStore, aircraftID) = seededAircraftStore()
        let missionStore = InMemoryStore<Mission>()
        let useCase = PlanMissionUseCase(aircraftStore: aircraftStore, missionStore: missionStore, now: { noon })

        let mission = try useCase.execute(name: "Roof Inspection", site: "12 Harbour St", date: noon.addingTimeInterval(86_400), aircraftID: aircraftID)

        #expect(mission.status == .planned)
        #expect(mission.inspection.count == 5)
        #expect(missionStore.loadAll().count == 1)
    }

    @Test func planMission_succeeds_whenDateIsEarlierToday() throws {
        let (aircraftStore, aircraftID) = seededAircraftStore()
        let useCase = PlanMissionUseCase(aircraftStore: aircraftStore, missionStore: InMemoryStore<Mission>(), now: { noon })

        let startOfToday = Calendar.current.startOfDay(for: noon)
        let mission = try useCase.execute(name: "", site: "Depot", date: startOfToday, aircraftID: aircraftID)

        #expect(mission.name == "Site mission")
    }

    @Test func planMission_fails_whenNoAircraftIsChosen() {
        let (aircraftStore, _) = seededAircraftStore()
        let useCase = PlanMissionUseCase(aircraftStore: aircraftStore, missionStore: InMemoryStore<Mission>(), now: { noon })

        do {
            _ = try useCase.execute(name: "Roof", site: "12 Harbour St", date: noon, aircraftID: nil)
            Issue.record("Expected MissionPlanningError.missingAircraft to be thrown")
        } catch MissionPlanningError.missingAircraft {
            // expected
        } catch {
            Issue.record("Expected .missingAircraft but got \(error)")
        }
    }

    @Test func planMission_fails_whenDateIsYesterday() {
        let (aircraftStore, aircraftID) = seededAircraftStore()
        let useCase = PlanMissionUseCase(aircraftStore: aircraftStore, missionStore: InMemoryStore<Mission>(), now: { noon })

        do {
            _ = try useCase.execute(name: "Roof", site: "12 Harbour St", date: noon.addingTimeInterval(-2 * 86_400), aircraftID: aircraftID)
            Issue.record("Expected MissionPlanningError.scheduledDateInPast to be thrown")
        } catch MissionPlanningError.scheduledDateInPast {
            // expected
        } catch {
            Issue.record("Expected .scheduledDateInPast but got \(error)")
        }
    }

    @Test func planMission_fails_whenSiteIsBlank() {
        let (aircraftStore, aircraftID) = seededAircraftStore()
        let useCase = PlanMissionUseCase(aircraftStore: aircraftStore, missionStore: InMemoryStore<Mission>(), now: { noon })

        do {
            _ = try useCase.execute(name: "Roof", site: "  ", date: noon, aircraftID: aircraftID)
            Issue.record("Expected MissionPlanningError.missingSite to be thrown")
        } catch MissionPlanningError.missingSite {
            // expected
        } catch {
            Issue.record("Expected .missingSite but got \(error)")
        }
    }
}
