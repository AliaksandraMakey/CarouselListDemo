//
//  MockNetworkService.swift
//  CarouselListDemoTests
//
//  Created by Alexandra Homan
//

import Foundation
import UIKit
@testable import CarouselListDemo

@MainActor
final class MockNetworkService: NetworkServiceProtocol {

    var fetchUnsplashPhotosResult: Result<[UnsplashPhoto], Error>?
    var fetchUnsplashPhotosCallCount = 0

    func fetchUnsplashPhotos(page: Int, perPage: Int, accessKey: String) async throws -> [UnsplashPhoto] {
        fetchUnsplashPhotosCallCount += 1
        if let result = fetchUnsplashPhotosResult {
            switch result {
            case .success(let photos):
                return photos
            case .failure(let error):
                throw error
            }
        }
        return []
    }

    func loadImage(from url: URL?) async throws -> UIImage {
        // Not used in RemoteDataProvider tests
        throw NetworkError.invalidURL
    }
}
