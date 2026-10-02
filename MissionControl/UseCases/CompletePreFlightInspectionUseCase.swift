//
//  CompletePreFlightInspectionUseCase.swift
//  MissionControl
//
//  The pre-flight inspection is the gate between "planned" and "ready to fly": it is where a damaged propeller is caught and the aircraft is stopped from being marked ready, so the rule lives in a Use Case instead of being scattered through the screens.

import Foundation

struct CompletePreFlightInspectionUseCase<AircraftStore: PersistenceStore, MissionStore: PersistenceStore>
where AircraftStore.Entity == Aircraft, MissionStore.Entity == Mission {
    let aircraftStore: AircraftStore
    let missionStore: MissionStore

    /// Completes a mission's pre-flight inspection. A failed check grounds the aircraft (recording the defect) and keeps the mission in preparation.
    /// Throws: `PreFlightInspectionError` if the mission is missing, the aircraft already has an unresolved defect, a mandatory check has no result or a check failed.

    @discardableResult
    func execute(missionID: UUID, items: [InspectionItem]) throws -> Mission {
        var missions = missionStore.loadAll()
        var allAircraft = aircraftStore.loadAll()

        guard let missionIndex = missions.firstIndex(where: { $0.id == missionID }),
              let aircraftIndex = allAircraft.firstIndex(where: { $0.id == missions[missionIndex].aircraftID }) else {
            throw PreFlightInspectionError.missionNotFound
        }

        if let defect = allAircraft[aircraftIndex].openDefects.first {
            throw PreFlightInspectionError.aircraftHasUnresolvedDefect(defect: defect)
        }

        if let unchecked = items.first(where: { $0.isMandatory && $0.result == .notChecked }) {
            throw PreFlightInspectionError.mandatoryCheckNotRecorded(checkName: unchecked.checkName)
        }

        missions[missionIndex].inspection = items

        if let failed = items.first(where: { $0.result == .fail }) {
            let detail = failed.notes.trimmingCharacters(in: .whitespacesAndNewlines)
            allAircraft[aircraftIndex].openDefects.append("\(failed.checkName): \(detail.isEmpty ? "reported as failed" : detail)")
            missions[missionIndex].status = .planned
            aircraftStore.save(allAircraft)
            missionStore.save(missions)
            throw PreFlightInspectionError.safetyCheckFailed(checkName: failed.checkName)
        }

        missions[missionIndex].status = .ready
        missionStore.save(missions)
        return missions[missionIndex]
    }
}

enum PreFlightInspectionError: LocalizedError, Equatable {
    /// Who hits this: an operator opens an inspection for a mission or aircraft that has since been removed.
    /// Recovery: go back to the dashboard and open the mission again.
    case missionNotFound

    /// Who hits this: an operator inspects an aircraft that still has an unresolved defect from an earlier check or flight.
    /// Recovery: record the repair on the Aircraft Register, then inspect again.
    case aircraftHasUnresolvedDefect(defect: String)

    /// Who hits this: an operator tries to complete the inspection while a mandatory check is still "Not checked".
    /// Recovery: record Pass or Fail for the named check.
    case mandatoryCheckNotRecorded(checkName: String)

    /// Who hits this: an operator records a failed check (e.g. a damaged propeller).
    /// Recovery: repair the aircraft, record the repair on the Aircraft Register, then inspect again.
    case safetyCheckFailed(checkName: String)

    var errorDescription: String? {
        switch self {
        case .missionNotFound:
            return "This mission can't be found. Go back to the dashboard and open it again."
        case .aircraftHasUnresolvedDefect(let defect):
            return "This aircraft is not ready. Resolve the defect (\(defect)) on the Aircraft Register before proceeding."
        case .mandatoryCheckNotRecorded(let checkName):
            return "Record a result for \"\(checkName)\" before completing the inspection."
        case .safetyCheckFailed(let checkName):
            return "This aircraft is not ready. \(checkName) failed the inspection, so the aircraft is now grounded. Record the repair on the Aircraft Register, then inspect again."
        }
    }
}
