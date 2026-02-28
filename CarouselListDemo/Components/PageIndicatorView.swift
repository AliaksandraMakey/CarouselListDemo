//
//  PageIndicatorView.swift
//  CarouselListDemo
//
//  Created by Alexandra Homan
//

 
import UIKit

final class PageIndicatorView: UIView {

    // MARK: - Properties

    private enum Layout {
        static let staticDotsCount = 5
        static let spacing: CGFloat = 8
        static let dotSize: CGFloat = 8
    }

    var currentPage: Int = 0 {
        didSet { updateDots() }
    }

    private var staticDotsCount: Int { Layout.staticDotsCount }

    // MARK: - UI

    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = Layout.spacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraint()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupUI() {
        backgroundColor = .clear
        addSubview(stackView)
    }

    private func setupConstraint() {
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    private func updateDots() {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let activeIndex = currentPage % staticDotsCount

        for i in 0..<staticDotsCount {
            let dot = UIView()
            dot.backgroundColor = i == activeIndex ? .appAccent : .pageIndicatorInactive
            dot.layer.cornerRadius = Layout.dotSize / 2
            dot.translatesAutoresizingMaskIntoConstraints = false
            stackView.addArrangedSubview(dot)

            NSLayoutConstraint.activate([
                dot.widthAnchor.constraint(equalToConstant: Layout.dotSize),
                dot.heightAnchor.constraint(equalToConstant: Layout.dotSize)
            ])
        }
    }
}
 
