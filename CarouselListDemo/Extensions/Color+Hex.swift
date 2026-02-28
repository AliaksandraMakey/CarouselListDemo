//
//  Color+Hex.swift
//  CarouselListDemo
//
//  Created by Alexandra Homan
//

import Foundation
import SwiftUI

// MARK: - Color Extensions

extension Color {
    // App palette
    static let appBackground = Color(hex: "F4FBF8")
    static let cardBackground = Color(hex: "CDE8E1")
    static let searchBar = Color(hex: "E5EBEA")
    static let separator = Color(hex: "9A9A9A")

    // Semantic colors
    static let appAccent = Color.blue
    static let appError = Color.red
    static let imagePlaceholderBackground = Color.gray.opacity(0.2)
    static let imagePlaceholderLight = Color.gray.opacity(0.1)
    static let pageIndicatorInactive = Color.gray.opacity(0.4)
    static let progressBarTrack = Color.gray.opacity(0.2)
    static let shadowColor = Color.black.opacity(0.3)
    static let highlightBackground = Color.blue.opacity(0.1)

    /// Create color from hex string
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

 
