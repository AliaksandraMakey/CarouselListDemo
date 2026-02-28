//
//  CarouselCell.swift
//  CarouselListDemo
//
//  Created by Alexandra Homan
//

 
import UIKit

final class CarouselCell: UICollectionViewCell {
    
    static let reuseIdentifier = String(describing: CarouselCell.self)
    
    // MARK: - UI
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .imagePlaceholderBackground
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .label
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    // MARK: - Properties
    
    private var imageLoader: ImageLoader?
    private var cancelIdentifier: String?
    private var currentURL: URL?
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        if let identifier = cancelIdentifier {
            imageLoader?.cancelLoad(identifier: identifier)
        }
        imageView.image = nil
        activityIndicator.stopAnimating()
        currentURL = nil
    }
    
    // MARK: - Configuration
    
    func configure(with imageItem: ImageItem, imageLoader: ImageLoader) {
        self.imageLoader = imageLoader
        let identifier = UUID().uuidString
        cancelIdentifier = identifier
        guard let url = imageItem.thumbnailURL else { return }
        currentURL = url

        activityIndicator.startAnimating()
        Task { @MainActor [weak self] in
            guard let self else { return }
            do {
                let image = try await imageLoader.loadImage(from: url, cancelIdentifier: identifier)
                guard self.currentURL == url else { return }
                self.activityIndicator.stopAnimating()
                self.imageView.image = image
            } catch {
                guard self.currentURL == url else { return }
                self.activityIndicator.stopAnimating()
                self.imageView.backgroundColor = .imagePlaceholderLight
            }
        }
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        contentView.addSubview(imageView)
        contentView.addSubview(activityIndicator)
    }
    
    private func setupConstraint() {
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}
 
