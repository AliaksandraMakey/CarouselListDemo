//
//  EmptyStateView.swift
//  CarouselListDemo
//
//  Created by Alexandra Homan
//

 
import UIKit

final class EmptyStateView: UIView {

    private enum Layout {
        static let buttonHorizontalPadding: CGFloat = 24
        static let buttonVerticalPadding: CGFloat = 12
        static let extraLargePadding: CGFloat = 40
        static let contentBlockSpacing: CGFloat = 20
        static let padding: CGFloat = 16
        static let mediumSpacing: CGFloat = 8
        static let largeIconSize: CGFloat = 60
    }

    var onAction: (() -> Void)?

    // MARK: - UI

    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .secondaryLabel
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .appHeadline
        label.textColor = .label
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.font = .appBody
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var actionButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.baseForegroundColor = .white
        config.background.backgroundColor = .appAccent
        config.cornerStyle = .medium
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { _ in
            var attributes = AttributeContainer()
            attributes.font = .appBody
            return attributes
        }
        config.contentInsets = NSDirectionalEdgeInsets(
            top: Layout.buttonVerticalPadding,
            leading: Layout.buttonHorizontalPadding,
            bottom: Layout.buttonVerticalPadding,
            trailing: Layout.buttonHorizontalPadding
        )
        let button = UIButton(configuration: config, primaryAction: nil)
        button.addTarget(self, action: #selector(actionTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
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

    // MARK: - Configuration

    func configure(icon: String, title: String, message: String, actionTitle: String? = nil) {
        iconImageView.image = UIImage(systemName: icon)
        titleLabel.text = title
        messageLabel.text = message
        if let title = actionTitle {
            actionButton.configuration?.title = title
            actionButton.isHidden = false
        } else {
            actionButton.isHidden = true
        }
    }

    // MARK: - Setup

    private func setupUI() {
        addSubview(iconImageView)
        addSubview(titleLabel)
        addSubview(messageLabel)
        addSubview(actionButton)
        actionButton.isHidden = true
    }

    private func setupConstraint() {
        NSLayoutConstraint.activate([
            // icon
            iconImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconImageView.topAnchor.constraint(equalTo: topAnchor, constant: Layout.extraLargePadding),
            iconImageView.widthAnchor.constraint(equalToConstant: Layout.largeIconSize),
            iconImageView.heightAnchor.constraint(equalToConstant: Layout.largeIconSize),
            // title
            titleLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: Layout.contentBlockSpacing),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Layout.padding),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Layout.padding),
            // message
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Layout.mediumSpacing),
            messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Layout.padding),
            messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Layout.padding),
            // action button
            actionButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: Layout.contentBlockSpacing),
            actionButton.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }

    @objc private func actionTapped() {
        onAction?()
    }
}
 
