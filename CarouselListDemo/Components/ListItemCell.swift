//
//  ListItemCell.swift
//  CarouselListDemo
//
//  Created by Alexandra Homan
//

 
import UIKit

final class ListItemCell: UITableViewCell {

    private enum Layout {
        static let smallCornerRadius: CGFloat = 8
        static let cornerRadius: CGFloat = 12
        static let smallPadding: CGFloat = 8
        static let mediumPadding: CGFloat = 12
        static let standardSpacing: CGFloat = 12
        static let tightSpacing: CGFloat = 4
        static let thumbnailSize: CGFloat = 56
    }

    static let reuseIdentifier = String(describing: ListItemCell.self)

    // MARK: - UI

    private let thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .imagePlaceholderBackground
        imageView.layer.cornerRadius = Layout.smallCornerRadius
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = .label
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .appHeadline
        label.textColor = .label
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let bodyLabel: UILabel = {
        let label = UILabel()
        label.font = .appCaption
        label.textColor = .secondaryLabel
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .cardBackground
        view.layer.cornerRadius = Layout.cornerRadius
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - Properties

    private var imageLoader: ImageLoader?
    private var cancelIdentifier: String?
    private var currentURL: URL?

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupConstraint()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        if let id = cancelIdentifier {
            imageLoader?.cancelLoad(identifier: id)
        }
        thumbnailImageView.image = nil
        activityIndicator.stopAnimating()
        currentURL = nil
    }

    // MARK: - Configuration

    func configure(with item: ListItem, imageLoader: ImageLoader) {
        self.imageLoader = imageLoader
        let identifier = UUID().uuidString
        cancelIdentifier = identifier

        titleLabel.text = item.title
        bodyLabel.text = item.body

        guard let url = item.thumbnailURL else { return }
        currentURL = url

        activityIndicator.startAnimating()
        Task { @MainActor [weak self] in
            guard let self else { return }
            do {
                let image = try await imageLoader.loadImage(from: url, cancelIdentifier: identifier)
                guard self.currentURL == url else { return }
                self.activityIndicator.stopAnimating()
                self.thumbnailImageView.image = image
            } catch {
                guard self.currentURL == url else { return }
                self.activityIndicator.stopAnimating()
                self.thumbnailImageView.backgroundColor = .imagePlaceholderLight
            }
        }
    }

    // MARK: - Setup

    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        contentView.backgroundColor = .clear

        contentView.addSubview(containerView)
        containerView.addSubview(thumbnailImageView)
        containerView.addSubview(activityIndicator)
        containerView.addSubview(titleLabel)
        containerView.addSubview(bodyLabel)
    }

    private func setupConstraint() {
        let minContainerHeight = Layout.mediumPadding + Layout.thumbnailSize + Layout.mediumPadding

        NSLayoutConstraint.activate([
            // container
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Layout.smallPadding),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Layout.smallPadding),
            containerView.heightAnchor.constraint(greaterThanOrEqualToConstant: minContainerHeight),
            // thumbnail
            thumbnailImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: Layout.mediumPadding),
            thumbnailImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Layout.mediumPadding),
            thumbnailImageView.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -Layout.mediumPadding),
            thumbnailImageView.widthAnchor.constraint(equalToConstant: Layout.thumbnailSize),
            thumbnailImageView.heightAnchor.constraint(equalToConstant: Layout.thumbnailSize),
            // activity indicator (centered on thumbnail)
            activityIndicator.centerXAnchor.constraint(equalTo: thumbnailImageView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: thumbnailImageView.centerYAnchor),
            // title
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: Layout.mediumPadding),
            titleLabel.leadingAnchor.constraint(equalTo: thumbnailImageView.trailingAnchor, constant: Layout.standardSpacing),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Layout.mediumPadding),
            // body — required bottom drives cell height for 2 lines
            bodyLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Layout.tightSpacing),
            bodyLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            bodyLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            bodyLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -Layout.mediumPadding)
        ])
    }
}
 
