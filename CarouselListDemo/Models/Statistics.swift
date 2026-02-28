//
//  Statistics.swift
//  CarouselListDemo
//
//  Created by Alexandra Homan
//

import Foundation

struct PageStatistics: Identifiable {
    let id = UUID()
    let pageNumber: Int
    let itemCount: Int
    let blockLabel: String?

    /// Alias for SwiftUI: author name of the block.
    var authorName: String { blockLabel ?? "" }

    init(pageNumber: Int, itemCount: Int, blockLabel: String? = nil) {
        self.pageNumber = pageNumber
        self.itemCount = itemCount
        self.blockLabel = blockLabel
    }
}

struct CharacterOccurrence: Identifiable {
    let id = UUID()
    let character: Character
    let count: Int
}

struct AppStatistics {
    let pageStats: [PageStatistics]
    let topCharacters: [CharacterOccurrence]

    static var empty: AppStatistics {
        AppStatistics(pageStats: [], topCharacters: [])
    }

    // MARK: - SwiftUI conveniences
    /// Alias for pageStats (block = carousel page).
    var blockStats: [PageStatistics] { pageStats }
    var totalPages: Int { pageStats.count }
    var totalItems: Int { pageStats.reduce(0) { $0 + $1.itemCount } }
}
