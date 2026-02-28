//
//  CarouselPageTests.swift
//  CarouselListDemoTests
//
//  Created by Alexandra Homan
//

import XCTest
@testable import CarouselListDemo

@MainActor
final class CarouselPageTests: XCTestCase {

    private func makeImageItem(id: String) -> ImageItem {
        ImageItem(id: id, author: "A", width: 1, height: 1, downloadURL: "url")
    }

    func testCarouselPage_equatable_sameIdAndItems_areEqual() {
        let item1 = makeImageItem(id: "1")
        let item2 = makeImageItem(id: "2")
        let list1 = ListItem(from: item1)
        let list2 = ListItem(from: item2)
        let pageA = CarouselPage(id: "block1", imageItems: [item1, item2], listItems: [list1, list2])
        let pageB = CarouselPage(id: "block1", imageItems: [item1, item2], listItems: [list1, list2])
        XCTAssertEqual(pageA, pageB)
    }

    func testCarouselPage_equatable_differentIds_notEqual() {
        let item = makeImageItem(id: "1")
        let list = ListItem(from: item)
        let pageA = CarouselPage(id: "a", imageItems: [item], listItems: [list])
        let pageB = CarouselPage(id: "b", imageItems: [item], listItems: [list])
        XCTAssertNotEqual(pageA, pageB)
    }

    func testCarouselPage_equatable_differentImageItems_notEqual() {
        let item1 = makeImageItem(id: "1")
        let item2 = makeImageItem(id: "2")
        let list1 = ListItem(from: item1)
        let list2 = ListItem(from: item2)
        let pageA = CarouselPage(id: "block", imageItems: [item1], listItems: [list1])
        let pageB = CarouselPage(id: "block", imageItems: [item2], listItems: [list2])
        XCTAssertNotEqual(pageA, pageB)
    }

    func testCarouselPage_identifiable() {
        let item = makeImageItem(id: "1")
        let list = ListItem(from: item)
        let page = CarouselPage(id: "page-id", imageItems: [item], listItems: [list])
        XCTAssertEqual(page.id, "page-id")
    }
}
