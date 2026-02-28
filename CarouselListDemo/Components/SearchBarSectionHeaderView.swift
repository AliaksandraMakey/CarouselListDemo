//
//  SearchBarSectionHeaderView.swift
//  CarouselListDemo
//
//  Created by Alexandra Homan
//

import UIKit

final class SearchBarSectionHeaderView: UIView {

    private enum Layout {
        static let height: CGFloat = 44
        static let horizontalPadding: CGFloat = 16
        static let topPadding: CGFloat = 0
        static let bottomPadding: CGFloat = 12
    }

    static var preferredHeight: CGFloat {
        Layout.height + Layout.topPadding + Layout.bottomPadding
    }

    let searchBarView = SearchBarView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .appBackground
        searchBarView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(searchBarView)
        NSLayoutConstraint.activate([
            searchBarView.topAnchor.constraint(equalTo: topAnchor, constant: Layout.topPadding),
            searchBarView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Layout.horizontalPadding),
            searchBarView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Layout.horizontalPadding),
            searchBarView.heightAnchor.constraint(equalToConstant: Layout.height)
        ])
    }
}
