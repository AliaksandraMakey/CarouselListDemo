//
//  ObservableImageLoader.swift
//  CarouselListDemo
//
//  Created by Alexandra Homan
//

import Foundation
import Observation
import UIKit

@MainActor
@Observable
final class ObservableImageLoader {

    private(set) var image: UIImage?
    private(set) var isLoading: Bool = false
    private(set) var error: Error?

    private let networkService: NetworkServiceProtocol
    private let cacheService: ImageCacheService

    init(networkService: NetworkServiceProtocol, cacheService: ImageCacheService) {
        self.networkService = networkService
        self.cacheService = cacheService
    }

    func load(url: URL?) async {
        guard let url else {
            image = nil
            isLoading = false
            error = nil
            return
        }

        if let cached = cacheService.getImage(url: url) {
            image = cached
            isLoading = false
            error = nil
            return
        }

        isLoading = true
        error = nil

        do {
            let loaded = try await networkService.loadImage(from: url)
            image = loaded
            cacheService.saveImage(loaded, url: url)
        } catch {
            self.image = nil
            self.error = error
        }
        isLoading = false
    }
}
