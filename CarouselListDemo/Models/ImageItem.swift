//
//  ImageItem.swift
//  CarouselListDemo
//
//  Created by Alexandra Homan
//

import Foundation

struct ImageItem: Identifiable, Hashable {
    let id: String
    let author: String
    let width: Int
    let height: Int
    /// Full-size image URL. Used for download tracking (Unsplash) or full-screen display.
    let downloadURL: String
    let description: String?

    var thumbnailURL: URL?

    init(
        id: String,
        author: String,
        width: Int,
        height: Int,
        downloadURL: String,
        description: String? = nil,
        thumbnailURL: URL? = nil
    ) {
        self.id = id
        self.author = author
        self.width = width
        self.height = height
        self.downloadURL = downloadURL
        self.description = description
        self.thumbnailURL = thumbnailURL
    }
}
