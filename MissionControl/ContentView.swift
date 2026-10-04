//
//  ContentView.swift
//  MissionControl
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab: MainTab = .dashboard
    @State private var showingPlanMission = false

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.controlBackground.ignoresSafeArea()

            Group {
                switch selectedTab {
                case .dashboard:
                    DashboardView()
                case .aircraft:
                    AircraftView()
                case .history:
                    FlightHistoryView()
                }
            }
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 66)
            }

            ControlTabBar(selectedTab: $selectedTab) {
                showingPlanMission = true
            }
        }
        .preferredColorScheme(.dark)
        .tint(Color.controlAccent)
        .sheet(isPresented: $showingPlanMission) {
            PlanMissionView()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(DataStore())
}
