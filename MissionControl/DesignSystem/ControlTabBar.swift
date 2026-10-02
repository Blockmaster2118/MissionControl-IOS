//
//  ControlTabBar.swift
//  MissionControl
//

import SwiftUI

enum MainTab {
    case dashboard, aircraft, history
}

struct ControlTabBar: View {
    @Binding var selectedTab: MainTab
    var onPlanMission: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            tabButton(.dashboard, icon: "gauge.with.dots.needle.33percent", label: "Dashboard")
            tabButton(.aircraft, icon: "airplane", label: "Aircraft")
            tabButton(nil, icon: "plus.circle.fill", label: "Plan Mission")
            tabButton(.history, icon: "clock.arrow.circlepath", label: "Flights")
        }
        .padding(.horizontal, 12)
        .padding(.top, 14)
        .padding(.bottom, 30)
        .frame(maxWidth: .infinity)
        .background(
            RoundedCorner(radius: 28, corners: [.topLeft, .topRight])
                .fill(Color.controlCard)
                .ignoresSafeArea(edges: .bottom)
        )
    }

    private func tabButton(_ tab: MainTab?, icon: String, label: String) -> some View {
        Button {
            if let tab {
                selectedTab = tab
            } else {
                onPlanMission()
            }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 19, weight: .medium))
                Text(label)
                    .font(.system(size: 10, weight: .medium))
            }
            .foregroundStyle(tab != nil && selectedTab == tab ? Color.controlAccent : Color.controlTextSecondary)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(tab == nil ? "Plan New Mission" : label)
    }
}
