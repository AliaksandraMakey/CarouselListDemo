//
//  StatisticsTests.swift
//  CarouselListDemoTests
//
//  Created by Alexandra Homan
//

import XCTest
@testable import CarouselListDemo

@MainActor
final class StatisticsTests: XCTestCase {

    func testPageStatistics_init() {
        let stats = PageStatistics(pageNumber: 2, itemCount: 5, blockLabel: "author-1")
        XCTAssertEqual(stats.pageNumber, 2)
        XCTAssertEqual(stats.itemCount, 5)
        XCTAssertEqual(stats.blockLabel, "author-1")
    }

    func testPageStatistics_identifiable() {
        let stats = PageStatistics(pageNumber: 1, itemCount: 3)
        XCTAssertNotNil(stats.id)
    }

    func testCharacterOccurrence_init() {
        let occ = CharacterOccurrence(character: "a", count: 10)
        XCTAssertEqual(occ.character, "a")
        XCTAssertEqual(occ.count, 10)
    }

    func testAppStatistics_empty() {
        let empty = AppStatistics.empty
        XCTAssertTrue(empty.pageStats.isEmpty)
        XCTAssertTrue(empty.topCharacters.isEmpty)
    }

    func testAppStatistics_init() {
        let pageStats = [PageStatistics(pageNumber: 1, itemCount: 5)]
        let topChars = [CharacterOccurrence(character: "e", count: 3)]
        let stats = AppStatistics(pageStats: pageStats, topCharacters: topChars)
        XCTAssertEqual(stats.pageStats.count, 1)
        XCTAssertEqual(stats.topCharacters.count, 1)
        XCTAssertEqual(stats.topCharacters[0].character, "e")
        XCTAssertEqual(stats.topCharacters[0].count, 3)
    }
}
