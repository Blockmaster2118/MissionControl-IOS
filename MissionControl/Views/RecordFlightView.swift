//
//  RecordFlightView.swift
//  MissionControl
//

import SwiftUI

struct RecordFlightView: View {
    @EnvironmentObject var dataStore: DataStore
    @Environment(\.dismiss) private var dismiss

    let missionID: UUID

    @State private var startTime = Date()
    @State private var minutes = 20
    @State private var outcome = ""
    @State private var observations = ""
    @State private var newDefect = ""
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section("Flight") {
                    DatePicker("Takeoff", selection: $startTime, in: ...Date())
                    Stepper("Time in the air: \(TimeInterval(minutes * 60).formattedTime)", value: $minutes, in: 0...180)
                    TextField("Outcome (e.g. Roof captured, no issues)", text: $outcome)
                }

                Section("Observations") {
                    TextEditor(text: $observations)
                        .frame(minHeight: 60)
                }

                Section("Defects") {
                    TextField("New defect found (leave blank if none)", text: $newDefect)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.controlBackground.ignoresSafeArea())
            .navigationTitle("Record Flight")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save Flight") { save() }
                }
            }
            .alert(
                "Can't Record Flight",
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
    }

    private func save() {
        do {
            try dataStore.recordFlight(
                missionID: missionID,
                startTime: startTime,
                duration: TimeInterval(minutes * 60),
                outcome: outcome,
                observations: observations,
                newDefect: newDefect
            )
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
