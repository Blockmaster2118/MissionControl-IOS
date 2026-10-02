//
//  SharedStore.swift
//  MissionControl
//

import Foundation

struct MissionSnapshot: Codable, Equatable {
    var missionName: String, site: String, scheduledDate: Date, aircraftName: String
    var checksDone: Int, checksTotal: Int, isReady: Bool, updatedAt: Date
    static let sample = MissionSnapshot(missionName: "Roof Inspection", site: "12 Harbour St", scheduledDate: Date().addingTimeInterval(86_400),
                                        aircraftName: "DJI-01", checksDone: 0, checksTotal: 5, isReady: false, updatedAt: Date())
}

struct SharedBrief: Codable, Identifiable, Equatable {
    var id = UUID(); var title: String; var content: String; var receivedAt = Date()
}

enum SharedStore {
    static let groupID = "group.com.example.MissionControl"  
    private static var root: URL { FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupID) ?? FileManager.default.temporaryDirectory }
    private static var snapshotURL: URL { root.appendingPathComponent("next-mission.json") }
    private static var inbox: URL {
        let u = root.appendingPathComponent("Inbox", isDirectory: true)
        try? FileManager.default.createDirectory(at: u, withIntermediateDirectories: true)
        return u
    }

    static func writeSnapshot(_ s: MissionSnapshot?) {
        if let s, let d = try? JSONEncoder().encode(s) { try? d.write(to: snapshotURL, options: .atomic) }
        else { try? FileManager.default.removeItem(at: snapshotURL) }
    }
    static func readSnapshot() -> MissionSnapshot? {
        (try? Data(contentsOf: snapshotURL)).flatMap { try? JSONDecoder().decode(MissionSnapshot.self, from: $0) }
    }

    @discardableResult static func save(_ b: SharedBrief) -> Bool {
        guard !pendingBriefs().contains(where: { $0.content == b.content }), let d = try? JSONEncoder().encode(b) else { return false }
        return (try? d.write(to: inbox.appendingPathComponent("\(b.id).json"), options: .atomic)) != nil
    }
    static func pendingBriefs() -> [SharedBrief] {
        let files = (try? FileManager.default.contentsOfDirectory(at: inbox, includingPropertiesForKeys: nil)) ?? []
        return files.compactMap { try? JSONDecoder().decode(SharedBrief.self, from: Data(contentsOf: $0)) }.sorted { $0.receivedAt > $1.receivedAt }
    }
    static func discard(_ b: SharedBrief) { try? FileManager.default.removeItem(at: inbox.appendingPathComponent("\(b.id).json")) }
}
