//
//  StatBoxView.swift
//  MissionControl
//

import SwiftUI

struct StatBoxView: View {
    let value: String
    let caption: String
    var accent: Color = .controlTextPrimary

    var body: some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(accent)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(caption)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(Color.controlTextSecondary)
                .textCase(.uppercase)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .controlCard(cornerRadius: 14, fill: .controlCardElevated)
    }
}

#Preview {
    HStack(spacing: 10) {
        StatBoxView(value: "1", caption: "Min")
        StatBoxView(value: "42", caption: "Sec")
        StatBoxView(value: "311", caption: "Ms")
    }
    .padding()
    .background(Color.controlBackground)
}
