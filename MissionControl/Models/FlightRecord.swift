//
//  FlightRecord.swift
//  MissionControl
//

import Foundation

/// **Business rules** (enforced by `RecordFlightUseCase` when a flight is recorded):
/// A flight can only be recorded against a mission whose pre-flight inspection is complete (`.ready`) and whose aircraft has no unresolved defect.
/// A flight's `duration` must be a positive time; a flight that lasts zero or negative seconds didn't happen.

struct FlightRecord: PersistableEntity {
    let id: UUID
    var missionID: UUID
    var aircraftID: UUID
    var startTime: Date
    var duration: TimeInterval
    var outcome: String
    var observations: String

    init(
        id: UUID = UUID(),
        missionID: UUID,
        aircraftID: UUID,
        startTime: Date = Date(),
        duration: TimeInterval,
        outcome: String = "",
        observations: String = ""
    ) {
        self.id = id
        self.missionID = missionID
        self.aircraftID = aircraftID
        self.startTime = startTime
        self.duration = duration
        self.outcome = outcome
        self.observations = observations
    }
}

extension FlightRecord: MissionEventRecord {
    var eventDate: Date { startTime }

    func eventSummary(missionName: String, aircraftName: String) -> String {
        "\(missionName) — \(aircraftName) — \(duration.formattedTime)\(outcome.isEmpty ? "" : ", \(outcome)")"
    }
}
