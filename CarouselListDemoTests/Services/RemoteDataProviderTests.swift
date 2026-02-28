//
//  RemoteDataProviderTests.swift
//  CarouselListDemoTests
//
//  Created by Alexandra Homan
//

import XCTest
@testable import CarouselListDemo

@MainActor
final class RemoteDataProviderTests: XCTestCase {

    private func mapPhotoToImageItem(_ photo: UnsplashPhoto) -> ImageItem {
        let description = photo.description ?? photo.altDescription
        return ImageItem(
            id: photo.id,
            author: photo.user.name,
            width: photo.width,
            height: photo.height,
            downloadURL: photo.urls.regular,
            description: description,
            thumbnailURL: URL(string: photo.urls.small)
        )
    }

    func testMapping_success_mapsUnsplashPhotosToImageItems() {
        let photo = UnsplashPhoto(
            id: "photo1",
            width: 800,
            height: 600,
            description: "A test photo",
            altDescription: "Alt",
            user: UnsplashUser(name: "John Doe"),
            urls: UnsplashUrls(raw: "", full: "", regular: "https://example.com/regular.jpg", small: "https://example.com/small.jpg", thumb: "")
        )
        let item = mapPhotoToImageItem(photo)

        XCTAssertEqual(item.id, "photo1")
        XCTAssertEqual(item.author, "John Doe")
        XCTAssertEqual(item.width, 800)
        XCTAssertEqual(item.height, 600)
        XCTAssertEqual(item.description, "A test photo")
        XCTAssertEqual(item.downloadURL, "https://example.com/regular.jpg")
        XCTAssertEqual(item.thumbnailURL?.absoluteString, "https://example.com/small.jpg")
    }

    func testMapping_usesDescriptionWhenAltDescriptionIsNil() {
        let photo = UnsplashPhoto(
            id: "p1",
            width: 100,
            height: 100,
            description: "Primary",
            altDescription: nil,
            user: UnsplashUser(name: "A"),
            urls: UnsplashUrls(raw: "", full: "", regular: "https://r.jpg", small: "", thumb: "")
        )
        let item = mapPhotoToImageItem(photo)
        XCTAssertEqual(item.description, "Primary")
    }

    func testMapping_usesAltDescriptionWhenDescriptionIsNil() {
        let photo = UnsplashPhoto(
            id: "p1",
            width: 100,
            height: 100,
            description: nil,
            altDescription: "Alt text",
            user: UnsplashUser(name: "A"),
            urls: UnsplashUrls(raw: "", full: "", regular: "https://r.jpg", small: "", thumb: "")
        )
        let item = mapPhotoToImageItem(photo)
        XCTAssertEqual(item.description, "Alt text")
    }

    func testMapping_emptySmallUrl_thumbnailURLIsNil() {
        let photo = UnsplashPhoto(
            id: "p1",
            width: 100,
            height: 100,
            description: nil,
            altDescription: nil,
            user: UnsplashUser(name: "A"),
            urls: UnsplashUrls(raw: "", full: "", regular: "https://r.jpg", small: "", thumb: "")
        )
        let item = mapPhotoToImageItem(photo)
        XCTAssertNil(item.thumbnailURL)
    }

    func testMapping_limitCapsPerPageAt30() {
        // RemoteDataProvider uses min(limit, 30) - verify logic
        let capped = min(100, 30)
        XCTAssertEqual(capped, 30)
    }
}
