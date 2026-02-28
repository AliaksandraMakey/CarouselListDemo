//
//  ImageServicesEnvironment.swift
//  CarouselListDemo
//
//  Created by Alexandra Homan
//

import SwiftUI

struct ImageServicesEnvironmentKey: EnvironmentKey {
    static let defaultValue: ImageServices? = nil
}

extension EnvironmentValues {
    var imageServices: ImageServices? {
        get { self[ImageServicesEnvironmentKey.self] }
        set { self[ImageServicesEnvironmentKey.self] = newValue }
    }
}

struct ImageServices {
    let networkService: NetworkServiceProtocol
    let cacheService: ImageCacheService
}
