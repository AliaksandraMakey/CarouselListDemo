//
//  UnsplashPhoto.swift
//  CarouselListDemo
//
//  Created by Alexandra Homan
//

import Foundation

/// DTO for Unsplash API photo response
struct UnsplashPhoto: Decodable {
    let id: String
    let width: Int
    let height: Int
    let description: String?
    let altDescription: String?
    let user: UnsplashUser
    let urls: UnsplashUrls

    enum CodingKeys: String, CodingKey {
        case id
        case width
        case height
        case description
        case altDescription = "alt_description"
        case user
        case urls
    }
}

struct UnsplashUser: Decodable {
    let name: String
}

struct UnsplashUrls: Decodable {
    let raw: String
    let full: String
    let regular: String
    let small: String
    let thumb: String
}
