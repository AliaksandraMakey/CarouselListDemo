//
//  CarouselView.swift
//  CarouselListDemo
//
//  Created by Alexandra Homan
//

 
import UIKit

protocol CarouselViewDelegate: AnyObject {
    func carouselView(_ view: CarouselView, didChangePageTo index: Int)
}

final class CarouselView: UIView {

    private enum Layout {
        static let imageHeight: CGFloat = 280
        static let pageIndicatorHeight: CGFloat = 24
        static let cornerRadius: CGFloat = 12
        static let largeSpacing: CGFloat = 16
    }

    weak var delegate: CarouselViewDelegate?

    var carouselPages: [CarouselPage] = [] {
        didSet {
            guard carouselPages != oldValue else { return }
            collectionView.reloadData()
        }
    }

    var currentPageIndex: Int = 0 {
        didSet {
            pageIndicatorView.currentPage = currentPageIndex
        }
    }

    var isLoading: Bool = false {
        didSet {
            loadingView.isHidden = !isLoading
            if isLoading {
                activityIndicator.startAnimating()
            } else {
                activityIndicator.stopAnimating()
            }
        }
    }

    var errorMessage: String? {
        didSet {
            errorView.isHidden = errorMessage == nil
            errorView.message = errorMessage ?? ""
        }
    }

    var onRetry: (() -> Void)?

    // MARK: - UI

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.sectionInset = .zero

        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.isPagingEnabled = true
        collection.showsHorizontalScrollIndicator = false
        collection.backgroundColor = .clear
        collection.layer.cornerRadius = Layout.cornerRadius
        collection.clipsToBounds = true
        collection.delegate = self
        collection.dataSource = self
        collection.register(CarouselCell.self, forCellWithReuseIdentifier: CarouselCell.reuseIdentifier)
        collection.translatesAutoresizingMaskIntoConstraints = false
        return collection
    }()

    private let pageIndicatorView = PageIndicatorView()

    private let loadingView: UIView = {
        let view = UIView()
        view.backgroundColor = .imagePlaceholderBackground
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .label
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    private let loadingLabel: UILabel = {
        let label = UILabel()
        label.text = AppStrings.Carousel.loadingImages.localized
        label.font = .appCaption
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var errorView: ErrorView = {
        let view = ErrorView()
        view.isHidden = true
        view.onRetry = { [weak self] in self?.onRetry?() }
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - Dependencies

    var imageLoader: ImageLoader?

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
        addSubview(collectionView)
        addSubview(pageIndicatorView)
        addSubview(loadingView)
        loadingView.addSubview(activityIndicator)
        loadingView.addSubview(loadingLabel)
        addSubview(errorView)

        pageIndicatorView.translatesAutoresizingMaskIntoConstraints = false
    }

    private func setupConstraint() {
        NSLayoutConstraint.activate([
            // collection
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: Layout.imageHeight),
            // page Indicator
            pageIndicatorView.topAnchor.constraint(equalTo: collectionView.bottomAnchor),
            pageIndicatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            pageIndicatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            pageIndicatorView.heightAnchor.constraint(equalToConstant: Layout.pageIndicatorHeight),
            // loading
            loadingView.topAnchor.constraint(equalTo: topAnchor),
            loadingView.leadingAnchor.constraint(equalTo: leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: trailingAnchor),
            loadingView.heightAnchor.constraint(equalToConstant: Layout.imageHeight),
            // activity Indicator
            activityIndicator.centerXAnchor.constraint(equalTo: loadingView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: loadingView.centerYAnchor, constant: -20),
            // loading Label
            loadingLabel.topAnchor.constraint(equalTo: activityIndicator.bottomAnchor, constant: Layout.largeSpacing),
            loadingLabel.centerXAnchor.constraint(equalTo: loadingView.centerXAnchor),
            // error View
            errorView.topAnchor.constraint(equalTo: topAnchor),
            errorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            errorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            errorView.heightAnchor.constraint(equalToConstant: Layout.imageHeight)
        ])
    }

    // MARK: - Public

    func scrollToPage(_ index: Int, animated: Bool) {
        guard index >= 0, index < carouselPages.count else { return }
        currentPageIndex = index
        let indexPath = IndexPath(item: index, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: animated)
    }
}

// MARK: - UICollectionViewDataSource

extension CarouselView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        carouselPages.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CarouselCell.reuseIdentifier, for: indexPath) as! CarouselCell
        guard indexPath.item < carouselPages.count,
              let firstImage = carouselPages[indexPath.item].imageItems.first,
              let loader = imageLoader else { return cell }
        cell.configure(with: firstImage, imageLoader: loader)
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension CarouselView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        collectionView.bounds.size
    }
}

// MARK: - UIScrollViewDelegate

extension CarouselView: UIScrollViewDelegate {

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            notifyPageChanged(scrollView: scrollView)
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        notifyPageChanged(scrollView: scrollView)
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        notifyPageChanged(scrollView: scrollView)
    }

    private func notifyPageChanged(scrollView: UIScrollView) {
        let pageWidth = scrollView.bounds.width
        guard pageWidth > 0, !carouselPages.isEmpty else { return }

        let rawIndex = scrollView.contentOffset.x / pageWidth
        let blockIndex = Int(round(rawIndex))
        let clampedIndex = min(max(0, blockIndex), carouselPages.count - 1)

        currentPageIndex = clampedIndex
        delegate?.carouselView(self, didChangePageTo: clampedIndex)
    }
}
 
