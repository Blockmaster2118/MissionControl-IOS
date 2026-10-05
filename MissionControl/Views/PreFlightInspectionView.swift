//
//  PreFlightInspectionView.swift
//  MissionControl
//
//  Screen 4: records Pass / Fail / Not checked for each required item. The readiness rules themselves live in CompletePreFlightInspectionUseCase.
//

import SwiftUI

struct PreFlightInspectionView: View {
    @EnvironmentObject var dataStore: DataStore
    @Environment(\.dismiss) private var dismiss

    let missionID: UUID

    @State private var items: [InspectionItem] = []
    @State private var errorMessage: String?

    var body: some View {
        Form {
            ForEach($items) { $item in
                Section(item.checkName) {
                    Picker("Result", selection: $item.result) {
                        ForEach(CheckResult.allCases) { result in
                            Text(result.rawValue).tag(result)
                        }
                    }
                    .pickerStyle(.segmented)

                    if item.result == .fail {
                        TextField("Describe the defect", text: $item.notes)
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color.controlBackground.ignoresSafeArea())
        .navigationTitle("Pre-Flight Inspection")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Complete") { complete() }
            }
        }
        .onAppear {
            if items.isEmpty { items = dataStore.mission(for: missionID)?.inspection ?? [] }
        }
        .alert(
            "Can't Complete Inspection",
            isPresented: Binding(
                get: { errorMessage != nil },
                set: { isPresented in if !isPresented { errorMessage = nil } }
            )
        ) {
            Button("OK", role: .cancel) { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "")
        }
    }

    private func complete() {
        do {
            try dataStore.completeInspection(missionID: missionID, items: items)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
