//
//  MissionControlWidget.swift
//  MissionControl
//

import WidgetKit
import SwiftUI

struct MissionEntry: TimelineEntry { let date: Date; let snapshot: MissionSnapshot? }

struct MissionProvider: TimelineProvider {
    func placeholder(in context: Context) -> MissionEntry { MissionEntry(date: .now, snapshot: .sample) }
    func getSnapshot(in context: Context, completion: @escaping (MissionEntry) -> Void) {
        completion(MissionEntry(date: .now, snapshot: SharedStore.readSnapshot() ?? (context.isPreview ? .sample : nil)))
    }
    func getTimeline(in context: Context, completion: @escaping (Timeline<MissionEntry>) -> Void) {
        completion(Timeline(entries: [MissionEntry(date: .now, snapshot: SharedStore.readSnapshot())], policy: .after(.now.addingTimeInterval(1800))))
    }
}

struct MissionWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: MissionEntry
    var body: some View {
        if let s = entry.snapshot {
            VStack(alignment: .leading, spacing: 4) {
                Text("Next mission").font(.caption).foregroundStyle(.secondary)
                Text(s.missionName).font(.headline).lineLimit(1)
                Text(s.scheduledDate.formatted(date: .abbreviated, time: .shortened)).font(.caption)
                Text(s.scheduledDate.formatted(.relative(presentation: .named))).font(.caption).foregroundStyle(.secondary)   // e.g. "tomorrow", "in 3 weeks"
                if family == .systemMedium {
                    Text("Aircraft: \(s.aircraftName)").font(.caption)
                    Text(s.isReady ? "Pre-flight complete, ready to fly" : "Pre-flight: \(s.checksDone) of \(s.checksTotal) checks recorded").font(.caption)
                }
                Spacer(minLength: 0)
                Text("Updated \(s.updatedAt.formatted(date: .omitted, time: .shortened))").font(.caption2).foregroundStyle(.secondary)
            }.frame(maxWidth: .infinity, alignment: .leading)
        } else {
            Text(SharedStore.isConfigured ? "No mission scheduled.\nPlan one in Mission Control." : "App Group not set up.\nCheck SharedStore.groupID.").font(.caption)
        }
    }
}

@main struct MissionControlWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "NextMission", provider: MissionProvider()) { entry in
            MissionWidgetView(entry: entry).containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Next Mission")
        .description("Your next mission, its aircraft and pre-flight progress.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
