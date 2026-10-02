//
//  AddEditAircraftView.swift
//  MissionControl
//

import SwiftUI

struct AddEditAircraftView: View {
    @EnvironmentObject var dataStore: DataStore
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var serialNumber = ""
    @State private var notes = ""
    @State private var errorMessage: String?

    private var isNameValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Aircraft") {
                    TextField("Name (e.g. DJI-03)", text: $name)
                    TextField("Serial number", text: $serialNumber)
                }

                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 80)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.controlBackground.ignoresSafeArea())
            .navigationTitle("Register Aircraft")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Register") { save() }
                        .disabled(!isNameValid)
                }
            }
            .alert(
                "Can't Register Aircraft",
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
            try dataStore.registerAircraft(name: name, serialNumber: serialNumber, notes: notes)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    AddEditAircraftView()
        .environmentObject(DataStore())
}
