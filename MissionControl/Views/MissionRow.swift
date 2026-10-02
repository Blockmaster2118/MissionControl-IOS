//
//  MissionRow.swift
//  MissionControl
//

import SwiftUI

struct MissionRow: View {
    @EnvironmentObject var dataStore: DataStore
    let mission: Mission

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(mission.status == .ready ? Color.green : Color.controlAccent)
                .frame(width: 44, height: 44)
                .background(Circle().fill(Color.controlCardElevated))

            VStack(alignment: .leading, spacing: 3) {
                Text(mission.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.controlTextPrimary)
                Text("\(mission.site) • \(dataStore.aircraft(for: mission.aircraftID)?.name ?? "Unknown Aircraft")")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.controlTextSecondary)
                Text("\(mission.scheduledDate.formatted(date: .abbreviated, time: .shortened)) • \(mission.status.rawValue)")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.controlTextSecondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.controlTextSecondary)
        }
        .padding(14)
        .controlCard()
    }

    private var icon: String {
        switch mission.status {
        case .planned: return "checklist"
        case .ready: return "checkmark.seal.fill"
        case .flown: return "airplane.arrival"
        }
    }
}
