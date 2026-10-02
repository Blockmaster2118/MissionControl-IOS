import SwiftUI

struct ContentView: View {
    @EnvironmentObject var dataStore: DataStore

    var body: some View {
        NavigationStack {
            List {
                Section("Aircraft") {
                    ForEach(dataStore.aircraft) { aircraft in
                        VStack(alignment: .leading) {
                            Text(aircraft.name)
                            Text(aircraft.statusLabel)
                                .font(.caption)
                        }
                    }
                }

                Section("Missions") {
                    ForEach(dataStore.missions) { mission in
                        VStack(alignment: .leading) {
                            Text(mission.name)
                            Text(mission.status.rawValue)
                                .font(.caption)
                        }
                    }
                }

                Section("Flights") {
                    ForEach(dataStore.flights) { flight in
                        VStack(alignment: .leading) {
                            Text(flight.eventSummary(
                                missionName: dataStore.mission(for: flight.missionID)?.name ?? "Unknown Mission",
                                aircraftName: dataStore.aircraft(for: flight.aircraftID)?.name ?? "Unknown Aircraft"
                            ))
                            Text(flight.eventDate.formatted())
                                .font(.caption)
                        }
                    }
                }

                Section("Business Logic") {
                    Text("Aircraft: \(dataStore.aircraft.count)")
                    Text("Missions awaiting inspection: \(dataStore.awaitingInspection.count)")
                    Text("Grounded aircraft: \(dataStore.groundedAircraft.count)")
                    Text("Recorded flights: \(dataStore.flights.count)")
                }
            }
            .navigationTitle("MissionControl")
        }
    }
}
