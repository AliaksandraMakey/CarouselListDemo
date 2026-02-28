//
//  RemoteDataProvider.swift
//  CarouselListDemo
//
//  Created by Alexandra Homan
//

import Foundation

final class RemoteDataProvider: DataProviderProtocol {

    private let networkService: NetworkServiceProtocol
    private let accessKey: String

    init(networkService: NetworkServiceProtocol, accessKey: String) {
        self.networkService = networkService
        self.accessKey = accessKey
    }

    func fetchImages(page: Int, limit: Int) async throws -> [ImageItem] {
        guard !accessKey.isEmpty, accessKey != "YOUR_UNSPLASH_ACCESS_KEY" else {
            throw URLError(.userAuthenticationRequired, userInfo: [NSLocalizedDescriptionKey: "Add your Unsplash API key to Info.plist (UNSPLASH_ACCESS_KEY). Get one at https://unsplash.com/oauth/applications"])
        }
        let perPage = min(limit, 30)
        let photos = try await networkService.fetchUnsplashPhotos(page: page, perPage: perPage, accessKey: accessKey)
        return photos.map { photo in
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
    }
}
