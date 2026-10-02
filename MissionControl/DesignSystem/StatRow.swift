//
//  StatRow.swift
//  MissionControl
//

import SwiftUI

struct StatRow: View {
    let label: String
    let value: String
    var valueColor: Color = .controlTextPrimary

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 14))
                .foregroundStyle(Color.controlTextSecondary)
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(valueColor)
        }
        .padding(.vertical, 10)
    }
}

/// A thin divider matching the control palette, for separating rows within a card without using a full Section/List.
struct ControlDivider: View {
    var body: some View {
        Rectangle()
            .fill(Color.controlDivider)
            .frame(height: 1)
    }
}
