//
//  NetworkServiceTests.swift
//  CarouselListDemoTests
//
//  Created by Alexandra Homan
//

import XCTest
import UIKit
@testable import CarouselListDemo

@MainActor
final class NetworkServiceTests: XCTestCase {

    private var session: URLSession!
    private var networkService: NetworkService!

    override func setUp() {
        super.setUp()
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        session = URLSession(configuration: config)
        networkService = NetworkService(session: session)
    }

    override func tearDown() {
        MockURLProtocol.mockResponse = nil
        super.tearDown()
    }

    func testFetch_invalidURL_returnsInvalidURLError() async {
        do {
            _ = try await networkService.fetch([UnsplashPhoto].self, from: nil)
            XCTFail("Expected invalidURL error")
        } catch let error as NetworkError {
            if case .invalidURL = error { /* expected */ } else {
                XCTFail("Expected invalidURL error, got \(error)")
            }
        } catch {
            XCTFail("Expected NetworkError, got \(error)")
        }
    }

    func testFetch_validJSON_decodesSuccessfully() async throws {
        let json = """
        [{"id":"1","width":100,"height":100,"description":"Test","alt_description":"Alt","user":{"name":"Author"},"urls":{"raw":"","full":"","regular":"https://a.com/1.jpg","small":"","thumb":""}}]
        """
        let url = URL(string: "https://api.example.com/photos")!
        MockURLProtocol.mockResponse = (
            data: json.data(using: .utf8),
            response: HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil),
            error: nil
        )

        let photos = try await networkService.fetch([UnsplashPhoto].self, from: url)
        XCTAssertEqual(photos.count, 1)
        XCTAssertEqual(photos[0].id, "1")
        XCTAssertEqual(photos[0].user.name, "Author")
    }

    func testFetch_httpError_returnsHttpError() async {
        let url = URL(string: "https://api.example.com/photos")!
        MockURLProtocol.mockResponse = (
            data: Data(),
            response: HTTPURLResponse(url: url, statusCode: 404, httpVersion: nil, headerFields: nil),
            error: nil
        )

        do {
            _ = try await networkService.fetch([UnsplashPhoto].self, from: url)
            XCTFail("Expected httpError")
        } catch let error as NetworkError {
            if case .httpError(let code) = error {
                XCTAssertEqual(code, 404)
            } else {
                XCTFail("Expected httpError 404, got \(error)")
            }
        } catch {
            XCTFail("Expected NetworkError, got \(error)")
        }
    }

    func testLoadImage_invalidURL_returnsInvalidURLError() async {
        do {
            _ = try await networkService.loadImage(from: nil)
            XCTFail("Expected invalidURL error")
        } catch let error as NetworkError {
            if case .invalidURL = error { /* expected */ } else {
                XCTFail("Expected invalidURL error, got \(error)")
            }
        } catch {
            XCTFail("Expected NetworkError, got \(error)")
        }
    }

    func testLoadImage_validImageData_returnsUIImage() async throws {
        let size = CGSize(width: 1, height: 1)
        UIGraphicsBeginImageContext(size)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        let imageData = image!.pngData()!
        let url = URL(string: "https://example.com/image.png")!
        MockURLProtocol.mockResponse = (
            data: imageData,
            response: HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil),
            error: nil
        )

        let loadedImage = try await networkService.loadImage(from: url)
        XCTAssertNotNil(loadedImage)
    }

    func testLoadImage_invalidData_returnsInvalidResponse() async {
        let url = URL(string: "https://example.com/image.png")!
        MockURLProtocol.mockResponse = (
            data: Data([0x00, 0x01, 0x02]),
            response: HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil),
            error: nil
        )

        do {
            _ = try await networkService.loadImage(from: url)
            XCTFail("Expected invalidResponse")
        } catch let error as NetworkError {
            if case .invalidResponse = error { /* expected */ } else {
                XCTFail("Expected invalidResponse, got \(error)")
            }
        } catch {
            XCTFail("Expected NetworkError, got \(error)")
        }
    }
}
