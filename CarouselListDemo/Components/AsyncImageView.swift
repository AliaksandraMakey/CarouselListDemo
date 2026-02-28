//
//  AsyncImageView.swift
//  CarouselListDemo
//
//  Created by Alexandra Homan
//

import SwiftUI

struct AsyncImageView: View {
    let url: URL?
    let contentMode: ContentMode
    var networkService: (any NetworkServiceProtocol)?
    var cacheService: ImageCacheService?

    @Environment(\.imageServices) private var imageServices

    var body: some View {
        AsyncImageViewContent(
            url: url,
            contentMode: contentMode,
            networkService: networkService ?? imageServices?.networkService,
            cacheService: cacheService ?? imageServices?.cacheService
        )
    }
}

private struct AsyncImageViewContent: View {
    let url: URL?
    let contentMode: ContentMode
    let networkService: (any NetworkServiceProtocol)?
    let cacheService: ImageCacheService?

    @State private var loader: ObservableImageLoader?

    init(url: URL?, contentMode: ContentMode, networkService: (any NetworkServiceProtocol)?, cacheService: ImageCacheService?) {
        self.url = url
        self.contentMode = contentMode
        self.networkService = networkService
        self.cacheService = cacheService
        if let net = networkService, let cache = cacheService {
            self._loader = State(initialValue: ObservableImageLoader(networkService: net, cacheService: cache))
        } else {
            self._loader = State(initialValue: nil)
        }
    }

    var body: some View {
        Group {
            if let loader {
                LoaderDrivenView(loader: loader, contentMode: contentMode)
                    .task(id: url) {
                        await loader.load(url: url)
                    }
            } else {
                Color.imagePlaceholderBackground
            }
        }
    }
}

private struct LoaderDrivenView: View {
    @Bindable var loader: ObservableImageLoader
    let contentMode: ContentMode

    var body: some View {
        Group {
            if let image = loader.image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                    .clipped()
            } else if loader.isLoading {
                ZStack {
                    Color.imagePlaceholderBackground
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(Color.appAccent)
                }
            } else if loader.error != nil {
                ZStack {
                    Color.imagePlaceholderLight
                    VStack(spacing: 8) {
                        Image(systemName: AppIcons.exclamationmarkTriangle)
                            .font(.title)
                            .foregroundStyle(Color.appError)
                        Text(AppStrings.Errors.failedToLoad.localized)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            } else {
                ZStack {
                    Color.imagePlaceholderBackground
                    Image(systemName: AppIcons.photo)
                        .font(.largeTitle)
                        .foregroundStyle(Color.secondary)
                }
            }
        }
    }
}

 
