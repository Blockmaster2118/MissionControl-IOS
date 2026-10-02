//
//  Protocols.swift
//  MissionControl
//

import Foundation

// MARK: - PersistableEntity

protocol PersistableEntity: Codable, Identifiable, Hashable {
    var id: UUID { get }
}

// MARK: - TimeFormattable

/// Formats a duration (in seconds) the way an operator expects to see it in a flight log: hours and minutes. Flight time is essentially never shown as raw seconds.
protocol TimeFormattable {
    var formattedTime: String { get }
}

extension TimeInterval: TimeFormattable {
    var formattedTime: String {
        let totalMinutes = Int((self / 60).rounded())
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        return hours > 0 ? String(format: "%dh %02dm", hours, minutes) : "\(minutes)m"
    }
}

// MARK: - FlightStatisticsProviding

protocol FlightStatisticsProviding {
    var flights: [FlightRecord] { get }
}

extension FlightStatisticsProviding {
    var flightCount: Int {
        flights.count
    }

    var longestFlight: FlightRecord? {
        flights.max { $0.duration < $1.duration }
    }

    var totalFlightTime: TimeInterval {
        flights.reduce(0) { $0 + $1.duration }
    }

    var averageFlightTime: TimeInterval? {
        guard !flights.isEmpty else { return nil }
        return totalFlightTime / Double(flights.count)
    }
}

/// A plain bundle of flights (for one aircraft, one mission, or the whole operation) that can report the same statistics.
struct FlightSummary: FlightStatisticsProviding {
    let flights: [FlightRecord]
}

// MARK: - MissionEventRecord

protocol MissionEventRecord {
    var eventDate: Date { get }

    func eventSummary(missionName: String, aircraftName: String) -> String
}

// MARK: - PersistenceStore

protocol PersistenceStore {
    associatedtype Entity: PersistableEntity
    func loadAll() -> [Entity]
    func save(_ items: [Entity])
}
