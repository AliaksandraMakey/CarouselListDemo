//
//  DataProviderProtocol.swift
//  CarouselListDemo
//
//  Created by Alexandra Homan
//

import Foundation

protocol DataProviderProtocol {
    func fetchImages(page: Int, limit: Int) async throws -> [ImageItem]
}
