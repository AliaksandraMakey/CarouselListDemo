//
//  NetworkServiceTests.swift
//  CarouselListDemoTests
//
//  Created by Alexandra Homan
//

import XCTest
@testable import CarouselListDemo

@MainActor
final class NetworkServiceTests: XCTestCase {

    private var mockConfig: URLSessionConfiguration!

    override func setUp() {
        super.setUp()
        mockConfig = URLSessionConfiguration.ephemeral
        mockConfig.protocolClasses = [MockURLProtocol.self]
    }

    override func tearDown() {
        MockURLProtocol.mockResponse = nil
        super.tearDown()
    }

    func testFetch_invalidURL_throwsInvalidURL() async {
        let session = URLSession(configuration: mockConfig)
        let service = NetworkService(session: session)

        do {
            _ = try await service.fetch([UnsplashPhoto].self, from: nil)
            XCTFail("Expected NetworkError.invalidURL")
        } catch let error as NetworkError {
            if case .invalidURL = error { return }
        } catch {}
        XCTFail("Expected NetworkError.invalidURL")
    }

    func testLoadImage_invalidURL_throwsInvalidURL() async {
        let session = URLSession(configuration: mockConfig)
        let service = NetworkService(session: session)

        do {
            _ = try await service.loadImage(from: nil)
            XCTFail("Expected NetworkError.invalidURL")
        } catch let error as NetworkError {
            if case .invalidURL = error { return }
        } catch {}
        XCTFail("Expected NetworkError.invalidURL")
    }

    func testLoadImage_validImageData_returnsUIImage() async throws {
        let image = createTestImage(width: 10, height: 10)
        let imageData = image.pngData()!
        let url = URL(string: "https://example.com/image.png")!

        MockURLProtocol.mockResponse = (
            data: imageData,
            response: HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil),
            error: nil
        )

        let session = URLSession(configuration: mockConfig)
        let service = NetworkService(session: session)

        let result = try await service.loadImage(from: url)
        XCTAssertNotNil(result)
    }

    func testLoadImage_nonImageData_throwsInvalidResponse() async {
        let url = URL(string: "https://example.com/bad.png")!
        MockURLProtocol.mockResponse = (
            data: Data([0x00, 0x01, 0x02]),
            response: HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil),
            error: nil
        )

        let session = URLSession(configuration: mockConfig)
        let service = NetworkService(session: session)

        do {
            _ = try await service.loadImage(from: url)
            XCTFail("Expected invalidResponse")
        } catch let error as NetworkError {
            if case .invalidResponse = error { return }
        } catch {}
        XCTFail("Expected NetworkError.invalidResponse")
    }

    func testLoadImage_httpError_throwsHttpError() async {
        let url = URL(string: "https://example.com/404.png")!
        MockURLProtocol.mockResponse = (
            data: Data(),
            response: HTTPURLResponse(url: url, statusCode: 404, httpVersion: nil, headerFields: nil),
            error: nil
        )

        let session = URLSession(configuration: mockConfig)
        let service = NetworkService(session: session)

        do {
            _ = try await service.loadImage(from: url)
            XCTFail("Expected httpError")
        } catch let error as NetworkError {
            if case .httpError(let code) = error {
                XCTAssertEqual(code, 404)
                return
            }
        } catch {}
        XCTFail("Expected NetworkError.httpError(404)")
    }

    private func createTestImage(width: Int, height: Int) -> UIImage {
        let size = CGSize(width: width, height: height)
        UIGraphicsBeginImageContext(size)
        defer { UIGraphicsEndImageContext() }
        return UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
    }
}
