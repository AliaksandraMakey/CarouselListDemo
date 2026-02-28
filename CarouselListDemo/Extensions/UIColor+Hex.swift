//
//  UIColor+Hex.swift
//  CarouselListDemo
//
//   Created by Alexandra Homan
//

 
import UIKit

extension UIColor {

    // MARK: - App Palette

    static let appBackground = UIColor(hex: "F4FBF8")
    static let cardBackground = UIColor(hex: "CDE8E1")
    static let searchBar = UIColor(hex: "E5EBEA")
    static let separator = UIColor(hex: "9A9A9A")

    // MARK: - Semantic Colors

    static let appAccent = UIColor.systemBlue
    static let appError = UIColor.systemRed
    static let imagePlaceholderBackground = UIColor.gray.withAlphaComponent(0.2)
    static let imagePlaceholderLight = UIColor.gray.withAlphaComponent(0.1)
    static let pageIndicatorInactive = UIColor.gray.withAlphaComponent(0.4)
    static let progressBarTrack = UIColor.gray.withAlphaComponent(0.2)
    static let shadowColor = UIColor.black.withAlphaComponent(0.3)
    static let summaryBackground = UIColor(hex: "E1F5FE")
    static let statisticsRowBackground = UIColor(hex: "E8F5E9")

    // MARK: - Hex Init

    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            red: CGFloat(r) / 255,
            green: CGFloat(g) / 255,
            blue: CGFloat(b) / 255,
            alpha: CGFloat(a) / 255
        )
    }
}
 
