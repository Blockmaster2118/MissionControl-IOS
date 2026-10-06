//
//  DashboardView.swift
//  MissionControl
//
//  Screen 1: what needs attention next - today's outstanding missions, missions still awaiting inspection, grounded aircraft and recently flown missions.
//
//  The readiness summary is broken into stat boxes - the same visual language of a timing screen - so the operator can see how many missions are waiting, how many aircraft are grounded and how much time has been flown at a glance.
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var dataStore: DataStore

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    header

                    HStack(spacing: 10) {
                        StatBoxView(value: "\(dataStore.awaitingInspection.count)", caption: "To Inspect", accent: .controlAccent)
                        StatBoxView(value: "\(dataStore.groundedAircraft.count)", caption: "Grounded", accent: dataStore.groundedAircraft.isEmpty ? .controlTextPrimary : .orange)
                        StatBoxView(value: FlightSummary(flights: dataStore.flights).totalFlightTime.formattedTime, caption: "Flown", accent: .controlTextPrimary)
                    }

                    missionSection(title: "Today: Still To Fly", emptyMessage: "Nothing left to fly today. Tap Plan Mission below to schedule one.", missions: dataStore.outstandingToday)
                    missionSection(title: "Awaiting Pre-Flight Inspection", emptyMessage: "Every planned mission has been inspected.", missions: dataStore.awaitingInspection)

                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader(title: "Aircraft With Open Defects")
                        if dataStore.groundedAircraft.isEmpty {
                            Text("No grounded aircraft. Your fleet is clear.")
                                .font(.system(size: 14))
                                .foregroundStyle(Color.controlTextSecondary)
                        } else {
                            ForEach(dataStore.groundedAircraft) { aircraft in
                                Label("\(aircraft.name): \(aircraft.openDefects.joined(separator: ", "))", systemImage: "exclamationmark.triangle.fill")
                                    .font(.system(size: 14))
                                    .foregroundStyle(.orange)
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader(title: "Shared Briefs Waiting")
                        if dataStore.briefs.isEmpty {
                            Text("Nothing shared yet. Share a link from Safari to MissionControl.")
                                .font(.system(size: 14))
                                .foregroundStyle(Color.controlTextSecondary)
                        } else {
                            ForEach(dataStore.briefs) { brief in
                                Label(brief.title, systemImage: "link")
                                    .font(.system(size: 14))
                                    .foregroundStyle(Color.controlTextPrimary)
                                    .lineLimit(1)
                            }
                            Text("Open a mission and choose Attach a shared brief.")
                                .font(.system(size: 12))
                                .foregroundStyle(Color.controlTextSecondary)
                        }
                    }

                    missionSection(title: "Recently Flown", emptyMessage: "No flights yet. Fly a mission and it will appear here.", missions: dataStore.recentlyFlown)
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 24)
            }
            .background(Color.controlBackground.ignoresSafeArea())
            .navigationDestination(for: Mission.self) { mission in
                MissionDetailView(missionID: mission.id)
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("MissionControl")
                    .font(.system(size: 28, weight: .heavy))
                    .foregroundStyle(Color.controlTextPrimary)
                Text("Know what needs attention next")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.controlTextSecondary)
            }
            Spacer()
            Image(systemName: "airplane.circle.fill")
                .font(.system(size: 34))
                .foregroundStyle(Color.controlAccent)
        }
    }

    private func missionSection(title: String, emptyMessage: String, missions: [Mission]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: title)

            if missions.isEmpty {
                Text(emptyMessage)
                    .font(.system(size: 14))
                    .foregroundStyle(Color.controlTextSecondary)
                    .padding(.vertical, 4)
            } else {
                VStack(spacing: 10) {
                    ForEach(missions) { mission in
                        NavigationLink(value: mission) {
                            MissionRow(mission: mission)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

#Preview {
    DashboardView()
        .environmentObject(DataStore())
}
