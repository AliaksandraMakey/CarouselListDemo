//
//  FloatingActionButton.swift
//  CarouselListDemo
//
//  Created by Alexandra Homan
//

 
import UIKit

final class FloatingActionButton: UIControl {

    private enum Layout {
        static let fabSize: CGFloat = 56
        static let fabDotSize: CGFloat = 6
        static let fabDotSpacing: CGFloat = 2
        static let fabShadowRadius: CGFloat = 8
        static let fabShadowY: CGFloat = 4
    }

    var onTap: (() -> Void)?

    // MARK: - UI

    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = Layout.fabDotSpacing
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        accessibilityIdentifier = "fab"
        setupUI()
        setupConstraint()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        addTarget(self, action: #selector(tapped), for: .touchUpInside)
    }

    // MARK: - Setup

    private func setupUI() {
        setupDots()
        addSubview(stackView)
        backgroundColor = .appAccent
        layer.cornerRadius = Layout.fabSize / 2
        layer.shadowColor = UIColor.shadowColor.cgColor
        layer.shadowOffset = CGSize(width: 0, height: Layout.fabShadowY)
        layer.shadowRadius = Layout.fabShadowRadius
        layer.shadowOpacity = 1
    }

    private func setupDots() {
        for _ in 0..<3 {
            let dot = UIView()
            dot.backgroundColor = .white
            dot.layer.cornerRadius = Layout.fabDotSize / 2
            dot.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                dot.widthAnchor.constraint(equalToConstant: Layout.fabDotSize),
                dot.heightAnchor.constraint(equalToConstant: Layout.fabDotSize)
            ])
            stackView.addArrangedSubview(dot)
        }
    }

    private func setupConstraint() {
        NSLayoutConstraint.activate([
            // self size
            widthAnchor.constraint(equalToConstant: Layout.fabSize),
            heightAnchor.constraint(equalToConstant: Layout.fabSize),
            // stack (dots)
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    @objc private func tapped() {
        onTap?()
    }
}
 
