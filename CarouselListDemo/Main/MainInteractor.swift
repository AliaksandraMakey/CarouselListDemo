//
//  MainInteractor.swift
//  CarouselListDemo
//
//  Created by Alexandra Homan
//

 
import UIKit

final class MainInteractor: MainInteractorProtocol {

    private enum Carousel {
        static let maxBlocks = 10
        static let minPhotosPerBlock = 3
        static let initialPagesToLoad = 6
        static let initialLimitPerPage = 30
        static let imagesPerPage = 10
    }

    private let presenter: MainPresenterProtocol

    private let dataProvider: DataProviderProtocol
    private let itemsPerPage: Int

    private var images: [ImageItem] = []
    private var carouselPages: [CarouselPage] = []
    private var currentPageIndex: Int = 0
    /// Author id of the current block — preserved when rebuildCarouselPages shifts indices after load more.
    private var currentBlockAuthorId: String?
    private var searchText: String = ""
    private var isLoading: Bool = false
    private var lastLoadMoreTime: CFAbsoluteTime = 0
    private var nextPageToFetch: Int = 1

    init(
        dataProvider: DataProviderProtocol,
        presenter: MainPresenterProtocol,
        itemsPerPage: Int = Carousel.imagesPerPage
    ) {
        self.dataProvider = dataProvider
        self.presenter = presenter
        self.itemsPerPage = itemsPerPage
    }

    // MARK: - Public

    func loadData() {
        guard !isLoading else { return }
        isLoading = true

        presenter.presentCarouselLoading()

        Task { @MainActor in
            await loadDataAsync()
        }
    }

    private func loadDataAsync() async {
        var accumulated: [ImageItem] = []
        var lastError: Error?
        var lastLoadedPage = 0
        let maxBlocks = Carousel.maxBlocks
        let minPhotos = Carousel.minPhotosPerBlock
        let maxInitialPages = Carousel.initialPagesToLoad

        func blockCount(from images: [ImageItem]) -> Int {
            let grouped = Dictionary(grouping: images, by: { $0.author })
            return grouped.keys.filter { (grouped[$0]?.count ?? 0) >= minPhotos }.count
        }

        for page in 1...maxInitialPages {
            do {
                let newItems = try await dataProvider.fetchImages(page: page, limit: Carousel.initialLimitPerPage)
                let existingIds = Set(accumulated.map(\.id))
                accumulated.append(contentsOf: newItems.filter { !existingIds.contains($0.id) })
                lastLoadedPage = page
                if blockCount(from: accumulated) >= maxBlocks { break }
            } catch {
                lastError = error
            }
        }

        nextPageToFetch = lastLoadedPage + 1
        finishLoadData(images: accumulated, error: lastError)
    }

    private func finishLoadData(images: [ImageItem], error: Error?) {
        isLoading = false

        if images.isEmpty, let err = error {
            let message = AppStrings.Carousel.errorLoadImages.localized(with: err.localizedDescription)
            presenter.presentCarouselError(message)
            return
        }

        self.images = images
        rebuildCarouselPages()
        restoreCurrentPageIndex()
        presenter.presentCarousel(
            pages: carouselPages,
            currentPage: currentPageIndex,
            shouldScrollToBlock: true
        )
        presenter.presentFilteredList(
            items: filterItems(),
            searchText: searchText
        )
    }

    func handleCarouselPageChanged(index: Int) {
        currentPageIndex = min(max(0, index), max(0, carouselPages.count - 1))
        currentBlockAuthorId = currentPageIndex < carouselPages.count ? carouselPages[currentPageIndex].id : nil
        presenter.presentFilteredList(items: filterItems(), searchText: searchText)
    }

    func handleSearchTextChanged(_ text: String) {
        searchText = text
        presenter.presentFilteredList(items: filterItems(), searchText: searchText)
    }

    func handleFabTapped() {
        presenter.presentStatisticsCalculating()

        Task { @MainActor [weak self] in
            guard let self else { return }
            let stats = CharacterCounter.calculateStatistics(blocks: carouselPages)
            presenter.presentStatistics(stats)
        }
    }

    func handleLoadMoreIfNeeded() {
        guard !images.isEmpty, !isLoading else { return }
        let now = CFAbsoluteTimeGetCurrent()
        guard now - lastLoadMoreTime > 1.0 else { return }
        lastLoadMoreTime = now
        loadMoreImages()
    }

    // MARK: - Private

    private func rebuildCarouselPages() {
        let grouped = Dictionary(grouping: images, by: { $0.author })
        let orderedAuthors = grouped.keys.sorted(by: { $0.lowercased() < $1.lowercased() })
        let minPhotos = Carousel.minPhotosPerBlock
        let maxBlocks = Carousel.maxBlocks
        carouselPages = orderedAuthors
            .compactMap { author -> CarouselPage? in
                guard let items = grouped[author], items.count >= minPhotos else { return nil }
                return CarouselPage(
                    id: author,
                    imageItems: items,
                    listItems: items.map { ListItem(from: $0) }
                )
            }
            .prefix(maxBlocks)
            .map { $0 }
    }

    private func restoreCurrentPageIndex() {
        if let authorId = currentBlockAuthorId,
           let index = carouselPages.firstIndex(where: { $0.id == authorId }) {
            currentPageIndex = index
        } else {
            currentPageIndex = min(currentPageIndex, max(0, carouselPages.count - 1))
        }
        if currentPageIndex < carouselPages.count {
            currentBlockAuthorId = carouselPages[currentPageIndex].id
        }
    }

    private func filterItems() -> [ListItem] {
        guard currentPageIndex < carouselPages.count else { return [] }
        let blockItems = carouselPages[currentPageIndex].listItems
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return blockItems
        }
        let words = trimmed.lowercased().split(separator: " ").map(String.init)
        return blockItems.filter { item in
            let searchable = item.searchableText
            return words.allSatisfy { searchable.contains($0) }
        }
    }

    private func loadMoreImages() {
        guard !isLoading else { return }
        isLoading = true

        let page = nextPageToFetch
        Task { @MainActor in
            do {
                let newImages = try await dataProvider.fetchImages(page: page, limit: itemsPerPage)
                let existingIds = Set(images.map(\.id))
                let uniqueNew = newImages.filter { !existingIds.contains($0.id) }
                guard !uniqueNew.isEmpty else {
                    nextPageToFetch = page + 1
                    isLoading = false
                    return
                }
                images.append(contentsOf: uniqueNew)
                nextPageToFetch = page + 1
                rebuildCarouselPages()
                restoreCurrentPageIndex()
                presenter.presentCarousel(
                    pages: carouselPages,
                    currentPage: currentPageIndex,
                    shouldScrollToBlock: false
                )
                presenter.presentFilteredList(
                    items: filterItems(),
                    searchText: searchText
                )
            } catch {
                // Load more failed silently (throttle will allow retry)
            }
            isLoading = false
        }
    }
}
 
