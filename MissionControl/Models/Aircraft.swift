//
//  Aircraft.swift
//  MissionControl
//

import Foundation

/// **Business rules** (enforced by `RegisterAircraftUseCase` at the point an aircraft is added — an `Aircraft` value itself is just data):
/// An aircraft must have a non-blank name, because the name is how the operator picks it out when planning a mission and when reviewing flight history.
/// No two aircraft may share the same name (case-insensitive), so that flight history is never ambiguous about which aircraft flew a mission.
/// An aircraft with any entry in `openDefects` is grounded: it can't pass a pre-flight inspection or be flown until the repair is recorded.

struct Aircraft: PersistableEntity {
    let id: UUID
    var name: String
    var serialNumber: String
    var notes: String
    var openDefects: [String]

    init(
        id: UUID = UUID(),
        name: String,
        serialNumber: String = "",
        notes: String = "",
        openDefects: [String] = []
    ) {
        self.id = id
        self.name = name
        self.serialNumber = serialNumber
        self.notes = notes
        self.openDefects = openDefects
    }

    var isGrounded: Bool {
        !openDefects.isEmpty
    }

    var statusLabel: String {
        isGrounded ? "Grounded" : "Cleared for pre-flight"
    }
}
