//
//  ListItem.swift
//  CarouselListDemo
//
//  Created by Alexandra Homan
//

import Foundation

struct ListItem: Identifiable, Hashable {
    let id: String
    let title: String
    let body: String
    let thumbnailURL: URL?

    /// Combined text for search: author name (title) + description (body).
    /// Used to filter items within the current carousel collection.
    var searchableText: String {
        "\(title) \(body)".lowercased()
    }

    init(from imageItem: ImageItem) {
        self.id = imageItem.id
        self.title = "\(AppStrings.Carousel.photoBy.localized) \(imageItem.author)"
        if let desc = imageItem.description, !desc.isEmpty {
            self.body = desc
        } else {
            self.body = "\(AppStrings.List.imageIdPrefix.localized) \(imageItem.id) • \(imageItem.width)×\(imageItem.height)"
        }
        self.thumbnailURL = imageItem.thumbnailURL
    }
}

