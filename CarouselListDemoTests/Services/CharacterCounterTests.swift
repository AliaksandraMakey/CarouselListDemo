//
//  CharacterCounterTests.swift
//  CarouselListDemoTests
//
//  Created by Alexandra Homan
//

import XCTest
@testable import CarouselListDemo

@MainActor
final class CharacterCounterTests: XCTestCase {


    func testCountCharacters_ignoresNonLetters() {
        let result = CharacterCounter.countCharacters(in: ["Hi 123!"])
        XCTAssertEqual(result["h"], 1)
        XCTAssertEqual(result["i"], 1)
        XCTAssertEqual(result.count, 2)
    }

    func testCountCharacters_isCaseInsensitive() {
        let result = CharacterCounter.countCharacters(in: ["AaA"])
        XCTAssertEqual(result["a"], 3)
    }

    func testTopCharacters_returnsSortedByCount() {
        let result = CharacterCounter.topCharacters(in: ["aaa", "bb", "c"], count: 3)
        XCTAssertEqual(result.count, 3)
        XCTAssertEqual(result[0].character, "a")
        XCTAssertEqual(result[0].count, 3)
        XCTAssertEqual(result[1].character, "b")
        XCTAssertEqual(result[1].count, 2)
        XCTAssertEqual(result[2].character, "c")
        XCTAssertEqual(result[2].count, 1)
    }

    func testTopCharacters_respectsCountLimit() {
        let result = CharacterCounter.topCharacters(in: ["aaa", "bb", "c", "d"], count: 2)
        XCTAssertEqual(result.count, 2)
    }

    func testTopCharacters_emptyInput_returnsEmpty() {
        let result = CharacterCounter.topCharacters(in: [], count: 3)
        XCTAssertTrue(result.isEmpty)
    }

    func testCalculateStatistics_producesCorrectStructure() {
        let imageItem = ImageItem(
            id: "1",
            author: "Test",
            width: 100,
            height: 100,
            downloadURL: "https://example.com/1.jpg",
            description: "Desc",
            thumbnailURL: nil
        )
        let listItem = ListItem(from: imageItem)
        let block = CarouselPage(
            id: "block1",
            imageItems: [imageItem],
            listItems: [listItem]
        )
        let blocks: [CarouselPage] = [block]

        let stats = CharacterCounter.calculateStatistics(blocks: blocks)

        XCTAssertEqual(stats.pageStats.count, 1)
        XCTAssertEqual(stats.pageStats[0].pageNumber, 1)
        XCTAssertEqual(stats.pageStats[0].itemCount, 1)
        XCTAssertEqual(stats.pageStats[0].blockLabel, "block1")
    }
}
