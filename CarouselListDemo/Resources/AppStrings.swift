//
//  AppStrings.swift
//  CarouselListDemo
//
//  Created by Alexandra Homan
//

import Foundation

enum AppStrings {

    enum General {
        static let retry = "general.retry"
        static let error = "general.error"
        static let noItems = "general.no_items"
        static let loadImagesMessage = "general.load_images_message"
    }

    enum Carousel {
        static let loadingImages = "carousel.loading_images"
        static let photoBy = "carousel.photo_by"
        static let errorLoadImages = "carousel.error_load_images"
        static let errorLoadMore = "carousel.error_load_more"
    }

    enum List {
        static let searchPlaceholder = "list.search_placeholder"
        static let noResults = "list.no_results"
        static let noResultsMessage = "list.no_results_message"
        static let noResultsHint = "list.no_results_hint"
        static let clearSearch = "list.clear_search"
        static let imageIdPrefix = "list.image_id_prefix"
    }

    enum Statistics {
        static let title = "statistics.title"
        static let itemsPerBlock = "statistics.items_per_block"
        static let top3Characters = "statistics.top_3_characters"
        static let page = "statistics.page"
        static let items = "statistics.items"
        static let calculating = "statistics.calculating"
        static let noStatistics = "statistics.no_statistics"
        static let noStatisticsMessage = "statistics.no_statistics_message"
        static let totalPagesLabel = "statistics.total_pages_label"
        static let totalItemsLabel = "statistics.total_items_label"
    }
    
    enum Errors {
        static let networkError = "errors.network_error"
        static let unknownError = "errors.unknown_error"
        static let tryAgain = "errors.try_again"
        static let failedToLoad = "errors.failed_to_load"
        static let loadDataFailed = "errors.load_data_failed"
    }
}
