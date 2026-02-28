//
//  MainViewModel.swift
//  CarouselListDemo
//
//  Created by Alexandra Homan
//

 
import Foundation

struct MainViewModel {
    let carouselPages: [CarouselPage]
    let currentPageIndex: Int
    let listItems: [ListItem]
    let searchText: String
    let isCarouselLoading: Bool
    let carouselErrorMessage: String?
    let isListEmpty: Bool
    let isSearching: Bool
    let shouldScrollToBlock: Bool
}
 
