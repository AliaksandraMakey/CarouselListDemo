//
//  ImageCacheService.swift
//  CarouselListDemo
//
//  Created by Alexandra Homan
//

import Foundation
import UIKit

final class ImageCacheService {

    private let memoryCache = NSCache<NSString, UIImage>()

    init() {
        memoryCache.countLimit = 100
        memoryCache.totalCostLimit = 50 * 1024 * 1024

        NotificationCenter.default.addObserver(
            forName: UIApplication.didReceiveMemoryWarningNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.memoryCache.removeAllObjects()
        }
    }

    private func cacheKey(for url: URL) -> String {
        url.absoluteString
    }

    func getImage(url: URL) -> UIImage? {
        let key = cacheKey(for: url)
        return memoryCache.object(forKey: key as NSString)
    }

    func saveImage(_ image: UIImage, url: URL) {
        let key = cacheKey(for: url)
        let cost = image.jpegData(compressionQuality: 1.0)?.count ?? 0
        memoryCache.setObject(image, forKey: key as NSString, cost: cost)
    }

    func clearAllCaches() {
        memoryCache.removeAllObjects()
    }
}
