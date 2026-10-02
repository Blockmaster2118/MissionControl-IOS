//
//  Mission.swift
//  MissionControl
//

import Foundation

enum MissionStatus: String, Codable, CaseIterable, Identifiable, Hashable {
    case planned = "In preparation"
    case ready = "Ready to fly"
    case flown = "Flown"

    var id: String { rawValue }
}

enum CheckResult: String, Codable, CaseIterable, Identifiable, Hashable {
    case pass = "Pass"
    case fail = "Fail"
    case notChecked = "Not checked"

    var id: String { rawValue }
}

/// One line of a pre-flight inspection. Mandatory items must have a result before the inspection can be completed.
struct InspectionItem: Codable, Identifiable, Hashable {
    let id: UUID
    var checkName: String
    var isMandatory: Bool
    var result: CheckResult
    var notes: String

    init(id: UUID = UUID(), checkName: String, isMandatory: Bool = true, result: CheckResult = .notChecked, notes: String = "") {
        self.id = id
        self.checkName = checkName
        self.isMandatory = isMandatory
        self.result = result
        self.notes = notes
    }

    static var standardChecklist: [InspectionItem] {
        ["Battery charge", "Propellers", "Airframe condition", "Gimbal and camera", "Remote controller link"]
            .map { InspectionItem(checkName: $0) }
    }
}

/// **Business rules** (enforced by `PlanMissionUseCase` when a mission is planned and `CompletePreFlightInspectionUseCase` when it is inspected):
/// A mission must have a site, a scheduled date that hasn't already passed and an aircraft that is registered in MissionControl.
/// A mission only becomes `.ready` once every mandatory inspection item has a result, none failed and its aircraft has no unresolved defect.

struct Mission: PersistableEntity {
    let id: UUID
    var name: String
    var site: String
    var scheduledDate: Date
    var aircraftID: UUID
    var status: MissionStatus
    var inspection: [InspectionItem]
    var briefs: [String]

    init(
        id: UUID = UUID(),
        name: String,
        site: String,
        scheduledDate: Date,
        aircraftID: UUID,
        status: MissionStatus = .planned,
        inspection: [InspectionItem] = InspectionItem.standardChecklist,
        briefs: [String] = []
    ) {
        self.id = id
        self.name = name
        self.site = site
        self.scheduledDate = scheduledDate
        self.aircraftID = aircraftID
        self.status = status
        self.inspection = inspection
        self.briefs = briefs
    }

    var checksPassed: Int {
        inspection.filter { $0.result == .pass }.count
    }
}
