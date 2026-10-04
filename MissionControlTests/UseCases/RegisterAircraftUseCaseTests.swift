//
//  RegisterAircraftUseCaseTests.swift
//  MissionControlTests
//

import Testing
import Foundation
@testable import MissionControl

struct RegisterAircraftUseCaseTests {

    @Test func registerAircraft_succeeds_withValidDetails() throws {
        let store = InMemoryStore<Aircraft>()
        let useCase = RegisterAircraftUseCase(aircraftStore: store)

        let aircraft = try useCase.execute(name: "DJI-01", serialNumber: "SIM-0001", notes: "Roof inspection kit")

        #expect(aircraft.name == "DJI-01")
        #expect(store.loadAll().count == 1)
        #expect(store.loadAll().first?.id == aircraft.id)
    }

    @Test func registerAircraft_fails_whenNameIsBlank() {
        let useCase = RegisterAircraftUseCase(aircraftStore: InMemoryStore<Aircraft>())

        do {
            _ = try useCase.execute(name: "   ", serialNumber: "", notes: "")
            Issue.record("Expected AircraftRegistrationError.missingName to be thrown for a blank name")
        } catch AircraftRegistrationError.missingName {
            // expected
        } catch {
            Issue.record("Expected .missingName but got \(error)")
        }
    }

    @Test func registerAircraft_fails_whenNameIsDuplicate_caseInsensitive() throws {
        let useCase = RegisterAircraftUseCase(aircraftStore: InMemoryStore<Aircraft>())
        try useCase.execute(name: "DJI-01", serialNumber: "", notes: "")

        do {
            _ = try useCase.execute(name: "dji-01", serialNumber: "", notes: "")
            Issue.record("Expected AircraftRegistrationError.duplicateName to be thrown for a case-insensitive name clash")
        } catch AircraftRegistrationError.duplicateName {
            // expected
        } catch {
            Issue.record("Expected .duplicateName but got \(error)")
        }
    }
}
