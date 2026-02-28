//
//  CarouselTableHeaderView.swift
//  CarouselListDemo
//
//  Created by Alexandra Homan
//

import UIKit

final class CarouselTableHeaderView: UIView {

    private enum Layout {
        static let carouselImageHeight: CGFloat = 280
        static let pageIndicatorHeight: CGFloat = 24
        static let topPadding: CGFloat = 0
        static let bottomPadding: CGFloat = 12
    }

    static var preferredHeight: CGFloat {
        Layout.carouselImageHeight + Layout.pageIndicatorHeight + Layout.bottomPadding
    }

    let carouselView = CarouselView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        carouselView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(carouselView)
        NSLayoutConstraint.activate([
            carouselView.topAnchor.constraint(equalTo: topAnchor, constant: Layout.topPadding),
            carouselView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            carouselView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            carouselView.heightAnchor.constraint(equalToConstant: Layout.carouselImageHeight + Layout.pageIndicatorHeight)
        ])
    }
}
