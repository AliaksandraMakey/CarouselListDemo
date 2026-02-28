//
//  ErrorView.swift
//  CarouselListDemo
//
//  Created by Alexandra Homan
//

 
import UIKit

final class ErrorView: UIView {

    private enum Layout {
        static let extraLargePadding: CGFloat = 40
        static let contentBlockSpacing: CGFloat = 20
        static let padding: CGFloat = 16
        static let mediumSpacing: CGFloat = 8
        static let largeIconSize: CGFloat = 60
    }

    var message: String = "" {
        didSet { messageLabel.text = message }
    }

    var onRetry: (() -> Void)?

    // MARK: - UI

    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: AppIcons.exclamationmarkTriangle)
        imageView.tintColor = .appError
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let errorTitleLabel: UILabel = {
        let label = UILabel()
        label.text = AppStrings.General.error.localized
        label.font = .appHeadline
        label.textColor = .label
        label.textAlignment = .center
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

    private lazy var retryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(AppStrings.General.retry.localized, for: .normal)
        button.setImage(UIImage(systemName: AppIcons.arrowClockwise), for: .normal)
        button.titleLabel?.font = .appBody
        button.addTarget(self, action: #selector(retryTapped), for: .touchUpInside)
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

    // MARK: - Setup

    private func setupUI() {
        backgroundColor = .imagePlaceholderBackground
        addSubview(iconImageView)
        addSubview(errorTitleLabel)
        addSubview(messageLabel)
        addSubview(retryButton)
    }

    private func setupConstraint() {
        NSLayoutConstraint.activate([
            // icon
            iconImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconImageView.topAnchor.constraint(equalTo: topAnchor, constant: Layout.extraLargePadding),
            iconImageView.widthAnchor.constraint(equalToConstant: Layout.largeIconSize),
            iconImageView.heightAnchor.constraint(equalToConstant: Layout.largeIconSize),
            // error title
            errorTitleLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: Layout.contentBlockSpacing),
            errorTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Layout.padding),
            errorTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Layout.padding),
            // message
            messageLabel.topAnchor.constraint(equalTo: errorTitleLabel.bottomAnchor, constant: Layout.mediumSpacing),
            messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Layout.padding),
            messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Layout.padding),
            // retry button
            retryButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: Layout.contentBlockSpacing),
            retryButton.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }

    @objc private func retryTapped() {
        onRetry?()
    }
}
 
