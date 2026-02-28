//
//  CarouselView.swift
//  CarouselListDemo
//
//  Created by Alexandra Homan
//

import SwiftUI

struct CarouselView: View {
    private enum Layout {
        static let imageHeight: CGFloat = 280
        static let pageIndicatorHeight: CGFloat = 24
        static let horizontalPadding: CGFloat = 16
        static let cornerRadius: CGFloat = 12
        static let largeSpacing: CGFloat = 16
        static let progressViewScale: CGFloat = 1.5
    }

    @Bindable var viewModel: MainViewModel
    @State private var scrollPosition: Int? = 0
    @State private var canSyncScrollToViewModel = false

    var body: some View {
        VStack(spacing: 0) {
            if !viewModel.hasCarouselPages && viewModel.errorMessage == nil {
                loadingView
            } else if viewModel.hasCarouselPages {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top, spacing: 0) {
                        ForEach(Array(viewModel.carouselPages.enumerated()), id: \.element.id) { index, page in
                            pageView(for: page)
                                .id(index)
                                .containerRelativeFrame(.horizontal)
                        }
                    }
                    .scrollTargetLayout()
                }
                .scrollTargetBehavior(.paging)
                .frame(height: Layout.imageHeight)
                .scrollPosition(id: $scrollPosition)
                .onChange(of: scrollPosition) { _, newValue in
                    guard canSyncScrollToViewModel, let idx = newValue, (0..<viewModel.carouselPages.count).contains(idx) else { return }
                    viewModel.setCurrentPageIndex(idx)
                }
                .onChange(of: viewModel.currentPageIndex) { _, newValue in
                    scrollPosition = newValue
                }
                .onAppear {
                    scrollPosition = viewModel.currentPageIndex
                    Task { @MainActor in
                        try? await Task.sleep(for: .milliseconds(150))
                        canSyncScrollToViewModel = true
                    }
                }

                PageIndicatorView(
                    currentPage: viewModel.currentPageIndex,
                    totalPages: viewModel.carouselPages.count
                )
                .padding(.vertical, Layout.pageIndicatorHeight / 2)
            } else if viewModel.isLoading {
                loadingView
            } else if viewModel.hasError, let message = viewModel.errorMessage {
                ErrorView(message: message) {
                    Task { await viewModel.retry() }
                }
                .frame(height: Layout.imageHeight)
            }
        }
    }

    private func pageView(for page: CarouselPage) -> some View {
        let firstImage = page.imageItems.first
        let carouselHeight = Layout.imageHeight
        return Group {
            if let imageItem = firstImage {
                AsyncImageView(
                    url: imageItem.thumbnailURL ?? URL(string: imageItem.downloadURL),
                    contentMode: .fill
                )
            } else {
                Color.imagePlaceholderBackground
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .frame(height: carouselHeight)
        .clipped()
        .cornerRadius(Layout.cornerRadius)
        .padding(.horizontal, Layout.horizontalPadding)
    }

    private var loadingView: some View {
        ZStack {
            Color.imagePlaceholderBackground
            VStack(spacing: Layout.largeSpacing) {
                ProgressView()
                    .scaleEffect(Layout.progressViewScale)
                Text(AppStrings.Carousel.loadingImages.localized)
                    .font(.appCaption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(height: Layout.imageHeight)
    }
}
