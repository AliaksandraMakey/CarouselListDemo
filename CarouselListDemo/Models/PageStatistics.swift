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

    var totalPages: Int { pageStats.count }
    var totalItems: Int { pageStats.reduce(0) { $0 + $1.itemCount } }
}
