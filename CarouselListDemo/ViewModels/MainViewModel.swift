//
//  MainViewModel.swift
//  CarouselListDemo
//
//  Created by Alexandra Homan
//

import Foundation

@MainActor
@Observable
final class MainViewModel {

    // MARK: - Carousel State

    var carouselPages: [CarouselPage] = []
    var currentPageIndex: Int = 0
    var currentBlockAuthorId: String = ""
    var isLoading: Bool = false
    var errorMessage: String?

    // MARK: - List State

    var searchQuery: String = "" {
        didSet { filterListItems() }
    }
    var filteredListItems: [ListItem] = []

    // MARK: - Statistics

    var isStatisticsPresented: Bool = false

    // MARK: - Dependencies

    private let dataProvider: DataProviderProtocol
    let networkService: NetworkServiceProtocol
    let cacheService: ImageCacheService

    // MARK: - Private State

    private var allImages: [ImageItem] = []
    private var loadedPageCount: Int = 0
    private var lastLoadMoreTime: Date = .distantPast
    private var isLoadingMore: Bool = false
    private enum Carousel {
        static let maxBlocks = 10
        static let minPhotosPerBlock = 3
        static let initialPagesToLoad = 6
        static let initialLimitPerPage = 30
        static let imagesPerPage = 10
    }
    private static let throttleInterval: TimeInterval = 1.0

    private let maxCarouselBlocks = Carousel.maxBlocks
    private let minPhotosPerBlock = Carousel.minPhotosPerBlock
    private let initialPagesToLoad = Carousel.initialPagesToLoad
    private let initialLimitPerPage = Carousel.initialLimitPerPage
    private let imagesPerPage = Carousel.imagesPerPage

    // MARK: - Initialization

    init(
        dataProvider: DataProviderProtocol,
        networkService: NetworkServiceProtocol,
        cacheService: ImageCacheService
    ) {
        self.dataProvider = dataProvider
        self.networkService = networkService
        self.cacheService = cacheService
    }

    // MARK: - Public: Initial Load

    func loadInitialData() async {
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil
        allImages = []
        loadedPageCount = 0
        carouselPages = []
        currentPageIndex = 0
        currentBlockAuthorId = ""

        do {
            var accumulated: [ImageItem] = []
            var lastLoadedPage = 0

            // Load all initial pages before showing carousel to avoid partial-load desync
            for page in 1...initialPagesToLoad {
                let newItems = try await dataProvider.fetchImages(page: page, limit: initialLimitPerPage)
                let existingIds = Set(accumulated.map(\.id))
                accumulated.append(contentsOf: newItems.filter { !existingIds.contains($0.id) })
                lastLoadedPage = page
                allImages = accumulated
                rebuildCarouselPages()

                let blockCount = Dictionary(grouping: allImages) { $0.author }
                    .filter { $0.value.count >= minPhotosPerBlock }.count
                if blockCount >= maxCarouselBlocks { break }
            }

            loadedPageCount = lastLoadedPage

            if !carouselPages.isEmpty {
                resetToFirstPage()
                filterListItems()
                prefetchFirstCarouselImages()
            } else if errorMessage == nil, !allImages.isEmpty {
                errorMessage = AppStrings.Carousel.errorLoadImages.localized(with: "No blocks formed (need ≥\(minPhotosPerBlock) photos per author)")
            }
        } catch {
            errorMessage = AppStrings.Carousel.errorLoadImages.localized(with: error.localizedDescription)
        }

        isLoading = false
    }

    // MARK: - Public: Load More

    func loadMoreIfNeeded() async {
        guard !isLoadingMore, !isLoading else { return }
        guard carouselPages.count < maxCarouselBlocks else { return }

        let now = Date()
        guard now.timeIntervalSince(lastLoadMoreTime) >= Self.throttleInterval else { return }

        isLoadingMore = true
        lastLoadMoreTime = now

        let nextPage = loadedPageCount + 1

        do {
            let newItems = try await dataProvider.fetchImages(page: nextPage, limit: imagesPerPage)
            addImagesDeduplicated(newItems)
            loadedPageCount = nextPage
            rebuildCarouselPages()
            restoreCurrentPageIndex()
            filterListItems()
        } catch {
            errorMessage = AppStrings.Carousel.errorLoadMore.localized(with: error.localizedDescription)
        }

        isLoadingMore = false
    }

    // MARK: - Public: Retry

    func retry() async {
        await loadInitialData()
    }

    // MARK: - Public: Carousel Page Change

    func setCurrentPageIndex(_ index: Int) {
        guard (0..<carouselPages.count).contains(index) else { return }
        currentPageIndex = index
        currentBlockAuthorId = carouselPages[index].id
        filterListItems()
    }

    // MARK: - Public: Search

    func clearSearch() {
        searchQuery = ""
    }

    func showStatistics() {
        isStatisticsPresented = true
    }

    func hideStatistics() {
        isStatisticsPresented = false
    }

    // MARK: - Private: Deduplication & Blocks

    private func addImagesDeduplicated(_ newItems: [ImageItem]) {
        let existingIds = Set(allImages.map(\.id))
        let toAdd = newItems.filter { !existingIds.contains($0.id) }
        allImages.append(contentsOf: toAdd)
    }

    private func rebuildCarouselPages() {
        let grouped = Dictionary(grouping: allImages) { $0.author }
        let blocks = grouped
            .filter { $0.value.count >= minPhotosPerBlock }
            .map { (author: $0.key, items: $0.value) }
            .sorted { $0.author.lowercased() < $1.author.lowercased() }
            .prefix(maxCarouselBlocks)
            .map { CarouselPage(
                id: $0.author,
                imageItems: $0.items,
                listItems: $0.items.map { ListItem(from: $0) }
            ) }
        carouselPages = Array(blocks)
    }

    /// Resets to first page. Use during initial load so user always sees page 1.
    private func resetToFirstPage() {
        currentPageIndex = 0
        if let first = carouselPages.first {
            currentBlockAuthorId = first.id
        }
    }

    /// Restores current page by author id when blocks are rebuilt (e.g. load more). Preserves user's selection.
    private func restoreCurrentPageIndex() {
        if currentBlockAuthorId.isEmpty, let first = carouselPages.first {
            currentBlockAuthorId = first.id
            currentPageIndex = 0
        } else if let idx = carouselPages.firstIndex(where: { $0.id == currentBlockAuthorId }) {
            currentPageIndex = idx
        } else {
            currentPageIndex = min(currentPageIndex, max(0, carouselPages.count - 1))
            if let page = carouselPages[safe: currentPageIndex] {
                currentBlockAuthorId = page.id
            }
        }
    }

    /// Filters list items within the current carousel block (1 collection).
    /// Matches by: author name (title) and description (body).
    /// Supports multi-word search: all words must be present in title or body.
    private func filterListItems() {
        let baseItems = currentListItemsForCurrentBlock
        let trimmed = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            filteredListItems = baseItems
        } else {
            let words = trimmed.lowercased()
                .components(separatedBy: .whitespaces)
                .filter { !$0.isEmpty }
            filteredListItems = baseItems.filter { item in
                let text = item.searchableText
                return words.allSatisfy { text.contains($0) }
            }
        }
    }

    private func prefetchFirstCarouselImages() {
        let urlsToPrefetch: [URL] = carouselPages.prefix(3).compactMap { page in
            guard let item = page.imageItems.first else { return nil }
            return item.thumbnailURL ?? URL(string: item.downloadURL)
        }.filter { url in
            cacheService.getImage(url: url) == nil
        }

        for url in urlsToPrefetch {
            Task {
                do {
                    let image = try await networkService.loadImage(from: url)
                    cacheService.saveImage(image, url: url)
                } catch { /* Prefetch failed, image will load on demand */ }
            }
        }
    }

    // MARK: - Computed

    private var currentListItemsForCurrentBlock: [ListItem] {
        guard (0..<carouselPages.count).contains(currentPageIndex) else { return [] }
        return carouselPages[currentPageIndex].listItems
    }

    var hasCarouselPages: Bool {
        !carouselPages.isEmpty
    }

    var isSearching: Bool {
        !searchQuery.isEmpty
    }

    var hasError: Bool {
        errorMessage != nil
    }

    var totalListItemsInAllBlocks: Int {
        carouselPages.reduce(0) { $0 + $1.listItems.count }
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
