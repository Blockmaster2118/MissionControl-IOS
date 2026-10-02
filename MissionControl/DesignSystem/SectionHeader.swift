//
//  SectionHeader.swift
//  MissionControl
//

import SwiftUI

struct SectionHeader: View {
    let title: String
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(Color.controlTextPrimary)
            Spacer()
            if let actionTitle {
                Button {
                    action?()
                } label: {
                    Text(actionTitle)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.controlAccent)
                }
            }
        }
    }
}
