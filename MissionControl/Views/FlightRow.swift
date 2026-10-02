//
//  FlightRow.swift
//  MissionControl
//

import SwiftUI

struct FlightRow: View {
    @EnvironmentObject var dataStore: DataStore
    let flight: FlightRecord

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(flight.eventSummary(
                missionName: dataStore.mission(for: flight.missionID)?.name ?? "Unknown Mission",
                aircraftName: dataStore.aircraft(for: flight.aircraftID)?.name ?? "Unknown Aircraft"
            ))
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(Color.controlTextPrimary)

            Text(flight.eventDate.formatted(date: .abbreviated, time: .shortened))
                .font(.system(size: 12))
                .foregroundStyle(Color.controlTextSecondary)

            if !flight.observations.isEmpty {
                Text(flight.observations)
                    .font(.system(size: 12))
                    .foregroundStyle(Color.controlTextSecondary)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .controlCard()
    }
}
