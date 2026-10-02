//
//  EmptyStateView.swift
//  MissionControl
//

import SwiftUI

struct EmptyStateView: View {
    let title: String
    let systemImage: String
    let message: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.system(size: 36))
                .foregroundStyle(Color.controlAccent)
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.controlTextPrimary)
            Text(message)
                .font(.system(size: 13))
                .foregroundStyle(Color.controlTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
        }
        .padding(.vertical, 32)
        .frame(maxWidth: .infinity)
        .controlCard(cornerRadius: 20)
    }
}

#Preview {
    EmptyStateView(
        title: "No Aircraft",
        systemImage: "airplane",
        message: "Add an aircraft to get started."
    )
    .padding()
    .background(Color.controlBackground)
}
