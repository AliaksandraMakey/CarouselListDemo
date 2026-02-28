//
//  MainPresenter.swift
//  CarouselListDemo
//
//  Created by Alexandra Homan
//

 
import UIKit

final class MainPresenter: MainPresenterProtocol {

    weak var viewController: MainDisplayLogic?

    func presentCarousel(pages: [CarouselPage], currentPage: Int, shouldScrollToBlock: Bool) {
        let blockIndex = min(max(0, currentPage), max(0, pages.count - 1))

        let vm = MainViewModel(
            carouselPages: pages,
            currentPageIndex: blockIndex,
            listItems: [],
            searchText: "",
            isCarouselLoading: false,
            carouselErrorMessage: nil,
            isListEmpty: false,
            isSearching: false,
            shouldScrollToBlock: shouldScrollToBlock
        )
        viewController?.displayCarousel(vm)
    }

    func presentCarouselLoading() {
        viewController?.displayCarouselLoading()
    }

    func presentCarouselError(_ message: String) {
        viewController?.displayCarouselError(message)
    }

    func presentFilteredList(items: [ListItem], searchText: String) {
        let vm = MainViewModel(
            carouselPages: [],
            currentPageIndex: 0,
            listItems: items,
            searchText: searchText,
            isCarouselLoading: false,
            carouselErrorMessage: nil,
            isListEmpty: items.isEmpty && searchText.isEmpty,
            isSearching: !searchText.isEmpty,
            shouldScrollToBlock: false
        )
        viewController?.displayFilteredList(vm)
    }

    func presentStatistics(_ stats: AppStatistics) {
        let pageStats = stats.pageStats.map { ($0.pageNumber, $0.itemCount, $0.blockLabel) }
        let topChars = stats.topCharacters.map { ($0.character, $0.count) }
        let totalPages = stats.pageStats.count
        let totalItems = stats.pageStats.reduce(0) { $0 + $1.itemCount }

        let vm = StatisticsViewModel(
            pageStats: pageStats,
            topCharacters: topChars,
            totalPages: totalPages,
            totalItems: totalItems,
            isCalculating: false
        )
        viewController?.displayStatistics(vm)
    }

    func presentStatisticsCalculating() {
        viewController?.displayStatisticsCalculating()
    }
}
 
