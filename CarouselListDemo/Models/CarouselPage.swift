//
//  CarouselPage.swift
//  CarouselListDemo
//
//  Created by Alexandra Homan
//

import Foundation

struct CarouselPage: Identifiable, Equatable {
    let id: String
    let imageItems: [ImageItem]
    let listItems: [ListItem]

    static func == (lhs: CarouselPage, rhs: CarouselPage) -> Bool {
        lhs.id == rhs.id && lhs.imageItems.map(\.id) == rhs.imageItems.map(\.id)
    }
}
