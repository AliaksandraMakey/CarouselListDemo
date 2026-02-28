//
//  StatisticsViewModel.swift
//  CarouselListDemo
//
//  Created by Alexandra Homan
//

 
import Foundation

struct StatisticsViewModel {
    let pageStats: [(page: Int, count: Int, blockLabel: String?)]
    let topCharacters: [(character: Character, count: Int)]
    let totalPages: Int
    let totalItems: Int
    let isCalculating: Bool
}
 
