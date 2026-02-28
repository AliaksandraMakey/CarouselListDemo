//
//  UnsplashModelsTests.swift
//  CarouselListDemoTests
//
//  Created by Alexandra Homan
//

import XCTest
@testable import CarouselListDemo

@MainActor
final class UnsplashModelsTests: XCTestCase {

    func testUnsplashPhoto_decodesFromJSON() throws {
        let json = """
        {"id":"abc","width":1080,"height":720,"description":"Photo","alt_description":"Alt","user":{"name":"Photographer"},"urls":{"raw":"","full":"","regular":"https://r.jpg","small":"https://s.jpg","thumb":""}}
        """
        let data = json.data(using: .utf8)!
        let photo = try JSONDecoder().decode(UnsplashPhoto.self, from: data)
        XCTAssertEqual(photo.id, "abc")
        XCTAssertEqual(photo.width, 1080)
        XCTAssertEqual(photo.height, 720)
        XCTAssertEqual(photo.description, "Photo")
        XCTAssertEqual(photo.altDescription, "Alt")
        XCTAssertEqual(photo.user.name, "Photographer")
        XCTAssertEqual(photo.urls.regular, "https://r.jpg")
        XCTAssertEqual(photo.urls.small, "https://s.jpg")
    }

    func testUnsplashPhoto_altDescriptionMapping() throws {
        let json = """
        {"id":"1","width":1,"height":1,"description":null,"alt_description":"snake_case","user":{"name":"U"},"urls":{"raw":"","full":"","regular":"r","small":"s","thumb":""}}
        """
        let data = json.data(using: .utf8)!
        let photo = try JSONDecoder().decode(UnsplashPhoto.self, from: data)
        XCTAssertEqual(photo.altDescription, "snake_case")
    }
}
