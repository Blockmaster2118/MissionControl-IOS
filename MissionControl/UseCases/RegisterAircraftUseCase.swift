//
//  RegisterAircraftUseCase.swift
//  MissionControl
//

import Foundation

/// The business operation of adding a new aircraft to an operator's register so it can be assigned to missions.
struct RegisterAircraftUseCase<AircraftStore: PersistenceStore> where AircraftStore.Entity == Aircraft {
    let aircraftStore: AircraftStore

    /// Registers a new aircraft, validating it against MissionControl's registration rules first.
    /// Throws: `AircraftRegistrationError` if the name is missing or already taken.

    @discardableResult
    func execute(name: String, serialNumber: String, notes: String) throws -> Aircraft {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            throw AircraftRegistrationError.missingName
        }

        let existingAircraft = aircraftStore.loadAll()
        if let duplicate = existingAircraft.first(where: { $0.name.caseInsensitiveCompare(trimmedName) == .orderedSame }) {
            throw AircraftRegistrationError.duplicateName(existingAircraftName: duplicate.name)
        }

        let aircraft = Aircraft(name: trimmedName, serialNumber: serialNumber, notes: notes)
        aircraftStore.save(existingAircraft + [aircraft])
        return aircraft
    }
}

enum AircraftRegistrationError: LocalizedError, Equatable {
    /// Who hits this: an operator left the name field empty and tried to save.
    /// Recovery: type a name before saving.
    case missingName

    /// Who hits this: an operator tried to register an aircraft whose name matches one already in their register.
    /// Recovery: pick a different, more specific name.
    case duplicateName(existingAircraftName: String)

    var errorDescription: String? {
        switch self {
        case .missingName:
            return "Give this aircraft a name (e.g. \"DJI-03\") so you can pick it out when planning a mission."
        case .duplicateName(let existingAircraftName):
            return "You already have an aircraft named \"\(existingAircraftName)\". Use a different name so your flight history stays easy to tell apart."
        }
    }
}
