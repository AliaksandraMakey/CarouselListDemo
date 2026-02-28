//
//  APIKeys.swift
//  CarouselListDemo
//
//  Created by Alexandra Homan
//

import Foundation

enum APIKeys {

    /// Unsplash API Access Key
    static var unsplashAccessKey: String? {
        Bundle.main.object(forInfoDictionaryKey: "UNSPLASH_ACCESS_KEY") as? String
    }
}
