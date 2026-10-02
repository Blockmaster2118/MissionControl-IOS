//
//  Theme.swift
//  MissionControl
//

import SwiftUI

extension Color {
    init(hex: String) {
        let sanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")
        let value = UInt64(sanitized, radix: 16) ?? 0
        let red = Double((value & 0xFF0000) >> 16) / 255
        let green = Double((value & 0x00FF00) >> 8) / 255
        let blue = Double(value & 0x0000FF) / 255
        self.init(red: red, green: green, blue: blue)
    }

    // MARK: Control palette

    static let controlBackground = Color(hex: "0A0C13")
    static let controlCard = Color(hex: "151926")
    static let controlCardElevated = Color(hex: "1E2333")
    static let controlAccent = Color(hex: "2D9CFF")
    static let controlTextPrimary = Color.white
    static let controlTextSecondary = Color(hex: "8B90A3")
    static let controlDivider = Color(hex: "262B3D")
}

extension LinearGradient {
    static let controlHero = LinearGradient(
        colors: [Color(hex: "10243A"), Color(hex: "0E1420")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
