//
//  NetworkServiceProtocol.swift
//  CarouselListDemo
//
//  Created by Alexandra Homan
//

import UIKit

protocol NetworkServiceProtocol: AnyObject {
    func fetchUnsplashPhotos(page: Int, perPage: Int, accessKey: String) async throws -> [UnsplashPhoto]
    func loadImage(from url: URL?) async throws -> UIImage
}
