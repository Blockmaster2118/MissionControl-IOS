//
//  AircraftView.swift
//  MissionControl
//
//  Screen 3: the Aircraft Register - which aircraft can proceed
//  through the readiness workflow and which are grounded.
//

import SwiftUI

struct AircraftView: View {
    @EnvironmentObject var dataStore: DataStore
    @State private var showingRegisterAircraft = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    header

                    if dataStore.aircraft.isEmpty {
                        EmptyStateView(
                            title: "No Aircraft Registered",
                            systemImage: "airplane",
                            message: "Add the aircraft you fly so you can assign one to each mission."
                        )
                    } else {
                        VStack(spacing: 10) {
                            ForEach(dataStore.aircraft) { aircraft in
                                NavigationLink(value: aircraft) {
                                    AircraftRow(aircraft: aircraft)
                                }
                                .buttonStyle(.plain)
                                .contextMenu {
                                    if aircraft.isGrounded {
                                        Button {
                                            dataStore.recordRepair(on: aircraft)
                                        } label: {
                                            Label("Record Repair Completed", systemImage: "wrench.and.screwdriver")
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 24)
            }
            .background(Color.controlBackground.ignoresSafeArea())
            .navigationDestination(for: Aircraft.self) { aircraft in
                AircraftDetailView(aircraftID: aircraft.id)
            }
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $showingRegisterAircraft) {
                AddEditAircraftView()
            }
        }
    }

    private var header: some View {
        HStack {
            Text("Aircraft Register")
                .font(.system(size: 28, weight: .heavy))
                .foregroundStyle(Color.controlTextPrimary)
            Spacer()
            Button {
                showingRegisterAircraft = true
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(Color.controlAccent))
            }
            .accessibilityLabel("Register Aircraft")
        }
    }
}

private struct AircraftRow: View {
    let aircraft: Aircraft

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: aircraft.isGrounded ? "exclamationmark.triangle.fill" : "checkmark.seal.fill")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(aircraft.isGrounded ? Color.orange : Color.green)
                .frame(width: 44, height: 44)
                .background(Circle().fill(Color.controlCardElevated))

            VStack(alignment: .leading, spacing: 3) {
                Text(aircraft.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.controlTextPrimary)
                Text([aircraft.statusLabel, aircraft.serialNumber].filter { !$0.isEmpty }.joined(separator: " • "))
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
}

#Preview {
    AircraftView()
        .environmentObject(DataStore())
}
