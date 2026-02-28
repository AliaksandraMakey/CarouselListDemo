//
//  ImageItemTests.swift
//  CarouselListDemoTests
//
//  Created by Alexandra Homan
//

import XCTest
@testable import CarouselListDemo

@MainActor
final class ImageItemTests: XCTestCase {

    func testImageItem_propertiesAreStored() {
        let item = ImageItem(
            id: "img1",
            author: "Photographer",
            width: 1920,
            height: 1080,
            downloadURL: "https://example.com/full.jpg",
            description: "A sunset",
            thumbnailURL: URL(string: "https://example.com/thumb.jpg")
        )
        XCTAssertEqual(item.id, "img1")
        XCTAssertEqual(item.author, "Photographer")
        XCTAssertEqual(item.width, 1920)
        XCTAssertEqual(item.height, 1080)
        XCTAssertEqual(item.downloadURL, "https://example.com/full.jpg")
        XCTAssertEqual(item.description, "A sunset")
        XCTAssertEqual(item.thumbnailURL?.absoluteString, "https://example.com/thumb.jpg")
    }

    func testImageItem_optionalDescriptionDefaultsToNil() {
        let item = ImageItem(
            id: "1",
            author: "A",
            width: 100,
            height: 100,
            downloadURL: "https://a.com/1.jpg"
        )
        XCTAssertNil(item.description)
        XCTAssertNil(item.thumbnailURL)
    }

    func testImageItem_conformsToIdentifiable() {
        let item = ImageItem(id: "x", author: "A", width: 1, height: 1, downloadURL: "url")
        XCTAssertEqual(item.id, "x")
    }

    func testImageItem_hashable_distinctItemsHaveDifferentHashes() {
        let a = ImageItem(id: "1", author: "A", width: 1, height: 1, downloadURL: "u1")
        let b = ImageItem(id: "2", author: "B", width: 1, height: 1, downloadURL: "u2")
        XCTAssertNotEqual(a.hashValue, b.hashValue)
    }
}
