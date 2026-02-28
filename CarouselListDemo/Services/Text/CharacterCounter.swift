//
//  CharacterCounter.swift
//  CarouselListDemo
//
//  Created by Alexandra Homan
//

import Foundation

struct CharacterCounter {

    static func countCharacters(in strings: [String]) -> [Character: Int] {
        var characterCounts: [Character: Int] = [:]

        for string in strings {
            for character in string.lowercased() {
                if character.isLetter {
                    characterCounts[character, default: 0] += 1
                }
            }
        }

        return characterCounts
    }

    static func topCharacters(in strings: [String], count: Int = 3) -> [CharacterOccurrence] {
        let characterCounts = countCharacters(in: strings)

        return characterCounts
            .sorted { $0.value > $1.value }
            .prefix(count)
            .map { CharacterOccurrence(character: $0.key, count: $0.value) }
    }

    static func calculateStatistics(blocks: [CarouselPage]) -> AppStatistics {
        var pageStats: [PageStatistics] = []

        for (index, block) in blocks.enumerated() {
            pageStats.append(PageStatistics(
                pageNumber: index + 1,
                itemCount: block.listItems.count,
                blockLabel: block.id
            ))
        }

        let allTitles = blocks.flatMap { $0.listItems.map { $0.title } }
        let topChars = topCharacters(in: allTitles, count: 3)

        return AppStatistics(pageStats: pageStats, topCharacters: topChars)
    }
}
