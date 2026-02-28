//
//  MainInteractorProtocol.swift
//  CarouselListDemo
//
//  Created by Alexandra Homan
//

 
import UIKit

protocol MainInteractorProtocol: AnyObject {
    func loadData()
    func handleCarouselPageChanged(index: Int)
    func handleSearchTextChanged(_ text: String)
    func handleFabTapped()
    func handleLoadMoreIfNeeded()
}
 
