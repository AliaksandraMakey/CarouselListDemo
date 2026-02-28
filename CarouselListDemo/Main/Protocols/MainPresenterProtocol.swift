//
//  MainPresenterProtocol.swift
//  CarouselListDemo
//
//  Created by Alexandra Homan
//

 
import UIKit

protocol MainPresenterProtocol: AnyObject {
    func presentCarousel(pages: [CarouselPage], currentPage: Int, shouldScrollToBlock: Bool)
    func presentCarouselLoading()
    func presentCarouselError(_ message: String)
    func presentFilteredList(items: [ListItem], searchText: String)
    func presentStatistics(_ stats: AppStatistics)
    func presentStatisticsCalculating()
}
 
