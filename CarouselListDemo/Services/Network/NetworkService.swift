//
//  NetworkService.swift
//  CarouselListDemo
//
//  Created by Alexandra Homan
//

import Foundation
import UIKit

// MARK: - NetworkError (API Layer)

enum NetworkError: LocalizedError {
    case invalidURL
    case invalidResponse
    case decodingError(Error)
    case networkError(Error)
    case httpError(statusCode: Int)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .decodingError(let error):
            return "Failed to decode data: \(error.localizedDescription)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .httpError(let statusCode):
            return "HTTP error with status code: \(statusCode)"
        }
    }
}

// MARK: - Base API Layer

/// Low-level network layer: generic fetch, image loading, URL request execution.
/// Unsplash-specific API methods are in the extension conforming to NetworkServiceProtocol.
final class NetworkService {

    private let session: URLSession
    private let decoder: JSONDecoder

    init(session: URLSession? = nil, decoder: JSONDecoder = JSONDecoder()) {
        if let session = session {
            self.session = session
        } else {
            let configuration = URLSessionConfiguration.default
            configuration.requestCachePolicy = .returnCacheDataElseLoad
            configuration.urlCache = URLCache(
                memoryCapacity: 20 * 1024 * 1024,
                diskCapacity: 100 * 1024 * 1024
            )
            self.session = URLSession(configuration: configuration)
        }
        self.decoder = decoder
    }

    // MARK: - Generic Fetch (Base API)

    func fetch<T: Decodable>(_ type: T.Type, from url: URL?) async throws -> T {
        guard let url else { throw NetworkError.invalidURL }
        let (data, response) = try await session.data(from: url)
        try validateHTTPResponse(response, data: data)
        return try decoder.decode(T.self, from: data)
    }

    // MARK: - Image Loading (Base API)

    func loadImage(from url: URL?) async throws -> UIImage {
        guard let url else { throw NetworkError.invalidURL }
        let (data, response) = try await session.data(from: url)
        try validateHTTPResponse(response, data: data)
        guard let image = UIImage(data: data) else { throw NetworkError.invalidResponse }
        return image
    }

    // MARK: - Private

    private func validateHTTPResponse(_ response: URLResponse?, data: Data) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.httpError(statusCode: httpResponse.statusCode)
        }
    }
}

// MARK: - NetworkServiceProtocol Conformance (Unsplash API)

extension NetworkService: NetworkServiceProtocol {

    func fetchUnsplashPhotos(page: Int = 1, perPage: Int = 30, accessKey: String) async throws -> [UnsplashPhoto] {
        guard let url = APIEndpoints.photoList(page: page, perPage: perPage, accessKey: accessKey) else {
            throw NetworkError.invalidURL
        }
        return try await fetch([UnsplashPhoto].self, from: url)
    }
}
