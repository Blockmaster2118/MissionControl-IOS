//
//  RecordFlightUseCase.swift
//  MissionControl
//
//  Recording a flight closes the loop on a mission - it is the point where "what happened" becomes part of the aircraft's history and any new defect is carried forward to the next pre-flight check.

import Foundation

struct RecordFlightUseCase<
    AircraftStore: PersistenceStore,
    MissionStore: PersistenceStore,
    FlightStore: PersistenceStore
> where AircraftStore.Entity == Aircraft, MissionStore.Entity == Mission, FlightStore.Entity == FlightRecord {
    let aircraftStore: AircraftStore
    let missionStore: MissionStore
    let flightStore: FlightStore

    /// Records a flight against a prepared mission, marks the mission as flown and grounds the aircraft if a new defect was observed.
    /// Throws: `FlightRecordingError` if the mission is missing, wasn't inspected as ready, the aircraft is grounded or the duration isn't positive.

    @discardableResult
    func execute(
        missionID: UUID,
        startTime: Date,
        duration: TimeInterval,
        outcome: String,
        observations: String,
        newDefect: String
    ) throws -> FlightRecord {
        var missions = missionStore.loadAll()
        var allAircraft = aircraftStore.loadAll()

        guard let missionIndex = missions.firstIndex(where: { $0.id == missionID }),
              let aircraftIndex = allAircraft.firstIndex(where: { $0.id == missions[missionIndex].aircraftID }) else {
            throw FlightRecordingError.missionNotFound
        }

        guard missions[missionIndex].status == .ready else {
            throw FlightRecordingError.preFlightInspectionIncomplete
        }

        guard !allAircraft[aircraftIndex].isGrounded else {
            throw FlightRecordingError.aircraftGrounded(aircraftName: allAircraft[aircraftIndex].name)
        }

        guard duration > 0 else {
            throw FlightRecordingError.invalidDuration(seconds: duration)
        }

        let flight = FlightRecord(
            missionID: missionID,
            aircraftID: allAircraft[aircraftIndex].id,
            startTime: startTime,
            duration: duration,
            outcome: outcome,
            observations: observations
        )
        flightStore.save(flightStore.loadAll() + [flight])

        missions[missionIndex].status = .flown
        missionStore.save(missions)

        let trimmedDefect = newDefect.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedDefect.isEmpty {
            allAircraft[aircraftIndex].openDefects.append(trimmedDefect)
            aircraftStore.save(allAircraft)
        }
        return flight
    }
}

enum FlightRecordingError: LocalizedError, Equatable {
    /// Who hits this: an operator tries to record a flight for a mission that has since been removed.
    /// Recovery: go back to the dashboard and open the mission again.
    case missionNotFound

    /// Who hits this: an operator tries to record a flight before the pre-flight inspection is complete (or after the mission was already flown).
    /// Recovery: complete the pre-flight inspection first.
    case preFlightInspectionIncomplete

    /// Who hits this: an operator tries to record a flight on an aircraft that has been grounded since the inspection.
    /// Recovery: record the repair on the Aircraft Register, then inspect again.
    case aircraftGrounded(aircraftName: String)

    /// Who hits this: an operator enters a flight time of zero (typically a data-entry mistake).
    /// Recovery: enter the actual time in the air.
    case invalidDuration(seconds: TimeInterval)

    var errorDescription: String? {
        switch self {
        case .missionNotFound:
            return "This mission can't be found. Go back to the dashboard and open it again."
        case .preFlightInspectionIncomplete:
            return "Complete the required pre-flight checks before recording this mission as flown."
        case .aircraftGrounded(let aircraftName):
            return "\(aircraftName) has an unresolved defect. Record the repair on the Aircraft Register before logging this flight."
        case .invalidDuration:
            return "Enter a flight time of at least one minute."
        }
    }
}
