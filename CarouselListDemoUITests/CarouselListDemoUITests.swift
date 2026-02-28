//
//  CarouselListDemoUITests.swift
//  CarouselListDemoUITests
//
//  Created by Alexandra Homan
//

import XCTest

final class CarouselListDemoUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testAppLaunches() throws {
        let app = XCUIApplication()
        app.launch()
    }

    @MainActor
    func testSearchBarExists() throws {
        let app = XCUIApplication()
        app.launch()
        let searchBar = app.textFields["searchBar"]
        XCTAssertTrue(searchBar.waitForExistence(timeout: 5))
    }

    @MainActor
    func testFABExists() throws {
        let app = XCUIApplication()
        app.launch()
        let fab = app.otherElements["fab"]
        XCTAssertTrue(fab.waitForExistence(timeout: 5))
    }

    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
