//
//  ImageLoader.swift
//  CarouselListDemo
//
//  Created by Alexandra Homan
//

import Foundation
import UIKit

enum ImageLoaderError: Error {
    case cancelled
}

private actor CancellationState {
    private var identifiers: Set<String> = []

    func isCancelled(_ id: String) -> Bool {
        identifiers.contains(id)
    }

    func markCancelled(_ id: String) {
        identifiers.insert(id)
    }
}

final class ImageLoader {

    private let networkService: NetworkServiceProtocol
    private let cacheService: ImageCacheService
    private let cancellationState = CancellationState()

    init(networkService: NetworkServiceProtocol, cacheService: ImageCacheService) {
        self.networkService = networkService
        self.cacheService = cacheService
    }

    func loadImage(from url: URL, cancelIdentifier: String? = nil) async throws -> UIImage {
        if let identifier = cancelIdentifier {
            let cancelled = await cancellationState.isCancelled(identifier)
            guard !cancelled else { throw ImageLoaderError.cancelled }
        }

        if let cached = cacheService.getImage(url: url) {
            return cached
        }

        let image = try await networkService.loadImage(from: url)

        if let identifier = cancelIdentifier {
            let cancelled = await cancellationState.isCancelled(identifier)
            guard !cancelled else { throw ImageLoaderError.cancelled }
        }

        cacheService.saveImage(image, url: url)
        return image
    }

    func cancelLoad(identifier: String) {
        Task { await cancellationState.markCancelled(identifier) }
    }
}
