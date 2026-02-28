//
//  MainDisplayLogic.swift
//  CarouselListDemo
//
//  Created by Alexandra Homan
//

 
import UIKit

protocol MainDisplayLogic: AnyObject {
    func displayCarousel(_ viewModel: MainViewModel)
    func displayCarouselLoading()
    func displayCarouselError(_ message: String)
    func displayFilteredList(_ viewModel: MainViewModel)
    func displayStatistics(_ viewModel: StatisticsViewModel)
    func displayStatisticsCalculating()
}
 
