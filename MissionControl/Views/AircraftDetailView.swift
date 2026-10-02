//
//  AircraftDetailView.swift
//  MissionControl
//

import SwiftUI

struct AircraftDetailView: View {
    @EnvironmentObject var dataStore: DataStore
    let aircraftID: UUID

    var body: some View {
        Group {
            if let aircraft = dataStore.aircraft(for: aircraftID) {
                content(for: aircraft)
            } else {
                EmptyStateView(title: "Aircraft Not Found", systemImage: "airplane", message: "Go back to the Aircraft Register and choose another aircraft.")
                    .padding(20)
            }
        }
        .background(Color.controlBackground.ignoresSafeArea())
    }

    private func content(for aircraft: Aircraft) -> some View {
        let summary = dataStore.flightSummary(forAircraft: aircraft.id)
        return ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 6) {
                    SectionHeader(title: aircraft.name)
                    VStack(spacing: 0) {
                        StatRow(label: "Serial", value: aircraft.serialNumber.isEmpty ? "Unknown" : aircraft.serialNumber)
                        ControlDivider()
                        StatRow(label: "Status", value: aircraft.statusLabel, valueColor: aircraft.isGrounded ? .orange : .green)
                        ControlDivider()
                        StatRow(label: "Flights", value: "\(summary.flightCount)")
                        ControlDivider()
                        StatRow(label: "Total Flight Time", value: summary.totalFlightTime.formattedTime)
                        ControlDivider()
                        StatRow(label: "Longest Flight", value: summary.longestFlight?.duration.formattedTime ?? "None yet")
                    }
                    .padding(.horizontal, 14)
                    .controlCard()
                }

                if aircraft.isGrounded {
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader(title: "Open Defects")
                        ForEach(aircraft.openDefects, id: \.self) { defect in
                            Label(defect, systemImage: "exclamationmark.triangle.fill")
                                .font(.system(size: 14))
                                .foregroundStyle(.orange)
                        }
                        Button("Record Repair Completed") { dataStore.recordRepair(on: aircraft) }
                            .buttonStyle(.borderedProminent)
                    }
                }

                VStack(alignment: .leading, spacing: 12) {
                    SectionHeader(title: "Flight History")
                    if summary.flights.isEmpty {
                        Text("No flights with this aircraft yet")
                            .font(.system(size: 14))
                            .foregroundStyle(Color.controlTextSecondary)
                    } else {
                        ForEach(summary.flights) { FlightRow(flight: $0) }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 24)
        }
        .navigationTitle("Aircraft")
        .navigationBarTitleDisplayMode(.inline)
    }
}
