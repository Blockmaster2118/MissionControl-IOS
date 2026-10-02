//
//  PlanMissionView.swift
//  MissionControl
//

import SwiftUI

struct PlanMissionView: View {
    @EnvironmentObject var dataStore: DataStore
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var site = ""
    @State private var date = Date()
    @State private var selectedAircraftID: UUID?
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section("Mission") {
                    TextField("Name (e.g. Roof Inspection)", text: $name)
                    TextField("Site location", text: $site)
                    DatePicker("Scheduled", selection: $date)
                }

                Section("Aircraft") {
                    if dataStore.aircraft.isEmpty {
                        Text("Register an aircraft before planning a mission.")
                            .foregroundStyle(.secondary)
                    } else {
                        Picker("Aircraft", selection: $selectedAircraftID) {
                            Text("Choose an aircraft").tag(nil as UUID?)
                            ForEach(dataStore.aircraft) { aircraft in
                                Text(aircraft.name).tag(aircraft.id as UUID?)
                            }
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.controlBackground.ignoresSafeArea())
            .navigationTitle("Plan Mission")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save Mission") { save() }
                }
            }
            .alert(
                "Can't Plan Mission",
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
            try dataStore.planMission(name: name, site: site, date: date, aircraftID: selectedAircraftID)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    PlanMissionView()
        .environmentObject(DataStore())
}
