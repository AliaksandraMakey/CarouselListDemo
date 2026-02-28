//
//  StatisticsViewModel.swift
//  CarouselListDemo
//
//  Created by Alexandra Homan
//

import Foundation

@MainActor
@Observable
final class StatisticsViewModel {

    var statistics: AppStatistics = .empty
    var isCalculating: Bool = false
    var isPresented: Bool = false

    private weak var mainViewModel: MainViewModel?

    init(mainViewModel: MainViewModel?) {
        self.mainViewModel = mainViewModel
    }

    func calculateStatistics() {
        guard let mainViewModel else {
            statistics = .empty
            return
        }

        let pages = mainViewModel.carouselPages
        guard !pages.isEmpty else {
            statistics = .empty
            return
        }

        isCalculating = true

        Task.detached(priority: .userInitiated) {
            let stats = await CharacterCounter.calculateStatistics(blocks: pages)

            await MainActor.run {
                self.statistics = stats
                self.isCalculating = false
            }
        }
    }

    func showStatisticsSheet() {
        calculateStatistics()
        isPresented = true
    }

    func hideStatisticsSheet() {
        isPresented = false
    }
}
