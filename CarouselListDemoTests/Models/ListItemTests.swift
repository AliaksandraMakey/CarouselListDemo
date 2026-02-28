//
//  ListItemTests.swift
//  CarouselListDemoTests
//
//  Created by Alexandra Homan
//

import XCTest
@testable import CarouselListDemo

@MainActor
final class ListItemTests: XCTestCase {

    func testListItem_initFromImageItem_preservesIdAndThumbnailURL() {
        let imageItem = ImageItem(
            id: "photo-123",
            author: "Jane",
            width: 800,
            height: 600,
            downloadURL: "https://example.com/full.jpg",
            description: "Beautiful landscape",
            thumbnailURL: URL(string: "https://example.com/thumb.jpg")
        )
        let listItem = ListItem(from: imageItem)
        XCTAssertEqual(listItem.id, "photo-123")
        XCTAssertEqual(listItem.thumbnailURL?.absoluteString, "https://example.com/thumb.jpg")
    }

    func testListItem_initFromImageItem_titleContainsAuthor() {
        let imageItem = ImageItem(id: "1", author: "John Smith", width: 100, height: 100, downloadURL: "url")
        let listItem = ListItem(from: imageItem)
        XCTAssertTrue(listItem.title.contains("John Smith"))
    }

    func testListItem_initFromImageItem_withDescription_usesDescriptionAsBody() {
        let imageItem = ImageItem(
            id: "1",
            author: "A",
            width: 100,
            height: 100,
            downloadURL: "url",
            description: "My photo description"
        )
        let listItem = ListItem(from: imageItem)
        XCTAssertEqual(listItem.body, "My photo description")
    }

    func testListItem_initFromImageItem_emptyDescription_usesFallbackFormat() {
        let imageItem = ImageItem(id: "img-99", author: "A", width: 200, height: 150, downloadURL: "url", description: "")
        let listItem = ListItem(from: imageItem)
        XCTAssertTrue(listItem.body.contains("img-99"))
        XCTAssertTrue(listItem.body.contains("200"))
        XCTAssertTrue(listItem.body.contains("150"))
    }

    func testListItem_searchableText_combinesTitleAndBody() {
        let imageItem = ImageItem(id: "1", author: "Test", width: 1, height: 1, downloadURL: "url", description: "Keyword")
        let listItem = ListItem(from: imageItem)
        XCTAssertTrue(listItem.searchableText.contains("keyword"))
    }
}
