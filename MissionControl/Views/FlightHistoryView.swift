//
//  FlightHistoryView.swift
//  MissionControl
//
//  Screen 5: an accessible history of previous operations.
//

import SwiftUI

struct FlightHistoryView: View {
    @EnvironmentObject var dataStore: DataStore

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Flight History")
                        .font(.system(size: 28, weight: .heavy))
                        .foregroundStyle(Color.controlTextPrimary)

                    if dataStore.flights.isEmpty {
                        EmptyStateView(
                            title: "No Flights Recorded",
                            systemImage: "clock.arrow.circlepath",
                            message: "Once you record a flown mission, its outcome and any follow-up maintenance appear here."
                        )
                    } else {
                        VStack(spacing: 10) {
                            ForEach(dataStore.flights) { flight in
                                FlightRow(flight: flight)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 24)
            }
            .background(Color.controlBackground.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

#Preview {
    FlightHistoryView()
        .environmentObject(DataStore())
}
