//
//  CardBackground.swift
//  MissionControl
//

import SwiftUI

private struct ControlCardBackground: ViewModifier {
    var cornerRadius: CGFloat
    var fill: Color

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(fill)
            )
    }
}

extension View {
    func controlCard(cornerRadius: CGFloat = 18, fill: Color = .controlCard) -> some View {
        modifier(ControlCardBackground(cornerRadius: cornerRadius, fill: fill))
    }
}
