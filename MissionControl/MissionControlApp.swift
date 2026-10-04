//
//  MissionControlApp.swift
//  MissionControl
//
//  "MissionControl is a workflow application that helps small commercial drone operators plan missions, complete pre-flight inspections, resolve aircraft defects and keep a record of every flight in one place."
//

import SwiftUI
import UIKit

@main
struct MissionControlApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var dataStore = DataStore()

    init() {
        MissionControlApp.configureAppearance()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dataStore)
                .onChange(of: scenePhase) { _, phase in
                    if phase == .active { dataStore.loadAll() }   // picks up briefs imported by the Share Extension
                }
        }
    }

    private static func configureAppearance() {
        let navigationAppearance = UINavigationBarAppearance()
        navigationAppearance.configureWithOpaqueBackground()
        navigationAppearance.backgroundColor = UIColor(Color.controlBackground)
        navigationAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]

        UINavigationBar.appearance().standardAppearance = navigationAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navigationAppearance
        UINavigationBar.appearance().compactAppearance = navigationAppearance
        UINavigationBar.appearance().tintColor = UIColor(Color.controlAccent)
    }
}
