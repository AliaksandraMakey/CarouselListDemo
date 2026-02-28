//
//  APIEndpoints.swift
//  CarouselListDemo
//
//  Created by Alexandra Homan
//

import Foundation

enum APIEndpoints {

    private static let unsplashBase = "https://api.unsplash.com"

    /// Builds photo list URL with access key passed as parameter. Key is not read from APIKeys.
    static func photoList(page: Int = 1, perPage: Int = 30, accessKey: String) -> URL? {
        var components = URLComponents(string: "\(unsplashBase)/photos")
        let queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per_page", value: "\(min(perPage, 30))"),
            URLQueryItem(name: "client_id", value: accessKey)
        ]
        components?.queryItems = queryItems
        return components?.url
    }
}

