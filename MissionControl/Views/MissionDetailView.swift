//
//  MissionDetailView.swift
//  MissionControl
//
//  Screen 2: one record for each planned operation - the mission, its
//  inspection, any attached site briefs and the flight that was flown.
//

import SwiftUI

struct MissionDetailView: View {
    @EnvironmentObject var dataStore: DataStore
    let missionID: UUID
    @State private var showingRecordFlight = false

    var body: some View {
        Group {
            if let mission = dataStore.mission(for: missionID) {
                content(for: mission)
            } else {
                EmptyStateView(title: "Mission Not Found", systemImage: "questionmark.folder", message: "Go back to the dashboard and choose another mission.")
                    .padding(20)
            }
        }
        .background(Color.controlBackground.ignoresSafeArea())
    }

    private func content(for mission: Mission) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 6) {
                    SectionHeader(title: mission.name)
                    VStack(spacing: 0) {
                        StatRow(label: "Site", value: mission.site)
                        ControlDivider()
                        StatRow(label: "Scheduled", value: mission.scheduledDate.formatted(date: .abbreviated, time: .shortened))
                        ControlDivider()
                        StatRow(label: "Aircraft", value: dataStore.aircraft(for: mission.aircraftID)?.name ?? "Unknown Aircraft")
                        ControlDivider()
                        StatRow(label: "Status", value: mission.status.rawValue, valueColor: mission.status == .ready ? .green : .controlTextPrimary)
                    }
                    .padding(.horizontal, 14)
                    .controlCard()
                }

                VStack(alignment: .leading, spacing: 12) {
                    SectionHeader(title: "Pre-Flight Inspection")
                    NavigationLink {
                        PreFlightInspectionView(missionID: mission.id)
                    } label: {
                        HStack {
                            Text("\(mission.checksPassed) of \(mission.inspection.count) checks passed")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(Color.controlTextPrimary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(Color.controlTextSecondary)
                        }
                        .padding(14)
                        .controlCard()
                    }
                    .buttonStyle(.plain)
                }

                VStack(alignment: .leading, spacing: 12) {
                    SectionHeader(title: "Site Briefs")
                    if mission.briefs.isEmpty {
                        Text("No site briefs attached. Share a link or note from Safari or Mail to MissionControl.")
                            .font(.system(size: 14))
                            .foregroundStyle(Color.controlTextSecondary)
                    }
                    ForEach(mission.briefs, id: \.self) { brief in
                        Text(brief)
                            .font(.system(size: 13))
                            .foregroundStyle(Color.controlTextPrimary)
                            .lineLimit(3)
                    }
                    if !dataStore.briefs.isEmpty {
                        Menu("Attach a shared brief") {
                            ForEach(dataStore.briefs) { brief in
                                Button(brief.title) { dataStore.attachBrief(brief, to: mission) }
                            }
                        }
                        .foregroundStyle(Color.controlAccent)
                    }
                }

                VStack(alignment: .leading, spacing: 12) {
                    SectionHeader(title: "Flight Record")
                    ForEach(dataStore.flightsForMission(mission.id)) { flight in
                        FlightRow(flight: flight)
                    }
                    switch mission.status {
                    case .ready:
                        Button("Record Flight") { showingRecordFlight = true }
                            .buttonStyle(.borderedProminent)
                    case .planned:
                        Text("Complete the pre-flight inspection to unlock flight recording.")
                            .font(.system(size: 14))
                            .foregroundStyle(Color.controlTextSecondary)
                    case .flown:
                        EmptyView()
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 24)
        }
        .navigationTitle("Mission")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingRecordFlight) {
            RecordFlightView(missionID: mission.id)
        }
    }
}
