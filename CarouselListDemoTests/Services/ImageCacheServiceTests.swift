//
//  ImageCacheServiceTests.swift
//  CarouselListDemoTests
//
//  Created by Alexandra Homan
//

import XCTest
@testable import CarouselListDemo

@MainActor
final class ImageCacheServiceTests: XCTestCase {

    private var cacheService: ImageCacheService!

    override func setUp() {
        super.setUp()
        cacheService = ImageCacheService()
    }

    func testGetImage_emptyCache_returnsNil() {
        let url = URL(string: "https://example.com/image.jpg")!
        let image = cacheService.getImage(url: url)
        XCTAssertNil(image)
    }

    func testSaveAndGetImage_returnsSavedImage() {
        let url = URL(string: "https://example.com/photo.png")!
        let size = CGSize(width: 10, height: 10)
        UIGraphicsBeginImageContext(size)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        cacheService.saveImage(image!, url: url)

        let cached = cacheService.getImage(url: url)
        XCTAssertNotNil(cached)
    }

    func testClearAllCaches_removesSavedImages() {
        let url = URL(string: "https://example.com/img.jpg")!
        let size = CGSize(width: 1, height: 1)
        UIGraphicsBeginImageContext(size)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        cacheService.saveImage(image!, url: url)
        cacheService.clearAllCaches()

        let cached = cacheService.getImage(url: url)
        XCTAssertNil(cached)
    }
}
