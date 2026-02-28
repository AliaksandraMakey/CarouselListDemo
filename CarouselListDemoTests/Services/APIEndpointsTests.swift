//
//  APIEndpointsTests.swift
//  CarouselListDemoTests
//
//  Created by Alexandra Homan
//

import XCTest
@testable import CarouselListDemo

@MainActor
final class APIEndpointsTests: XCTestCase {

    let testAccessKey = "test_key_12345"

    func testPhotoListURL_containsCorrectPath() {
        let url = APIEndpoints.photoList(page: 1, perPage: 30, accessKey: testAccessKey)
        XCTAssertNotNil(url)
        XCTAssertTrue(url?.absoluteString.contains("/photos") ?? false)
        XCTAssertTrue(url?.absoluteString.contains("api.unsplash.com") ?? false)
    }

    func testPhotoListURL_containsPageAndPerPageParams() {
        let url = APIEndpoints.photoList(page: 2, perPage: 15, accessKey: testAccessKey)
        XCTAssertNotNil(url)
        let components = URLComponents(url: url!, resolvingAgainstBaseURL: false)
        let queryItems = components?.queryItems ?? []
        XCTAssertTrue(queryItems.contains { $0.name == "page" && $0.value == "2" })
        XCTAssertTrue(queryItems.contains { $0.name == "per_page" && $0.value == "15" })
    }

    func testPhotoListURL_capsPerPageAt30() {
        let url = APIEndpoints.photoList(page: 1, perPage: 100, accessKey: testAccessKey)
        XCTAssertNotNil(url)
        let components = URLComponents(url: url!, resolvingAgainstBaseURL: false)
        let perPageItem = components?.queryItems?.first { $0.name == "per_page" }
        XCTAssertEqual(perPageItem?.value, "30")
    }

    func testPhotoListURL_containsClientIdParam() {
        let url = APIEndpoints.photoList(page: 1, perPage: 30, accessKey: testAccessKey)
        XCTAssertNotNil(url)
        let components = URLComponents(url: url!, resolvingAgainstBaseURL: false)
        let clientIdItem = components?.queryItems?.first { $0.name == "client_id" }
        XCTAssertEqual(clientIdItem?.value, testAccessKey)
    }
}
