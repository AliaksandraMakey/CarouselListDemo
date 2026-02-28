//
//  StatisticsBottomSheet.swift
//  CarouselListDemo
//
//  Created by Alexandra Homan
//

 
import UIKit

final class StatisticsBottomSheet: UIViewController {

    private enum Layout {
        static let sectionSpacing: CGFloat = 24
        static let extraLargePadding: CGFloat = 40
        static let largeSpacing: CGFloat = 16
        static let padding: CGFloat = 16
        static let dividerHeight: CGFloat = 1
        static let cornerRadius: CGFloat = 12
        static let mediumSpacing: CGFloat = 8
        static let standardSpacing: CGFloat = 12
        static let smallCornerRadius: CGFloat = 8
        static let mediumPadding: CGFloat = 12
    }
    private enum Statistics {
        static let characterFontSize: CGFloat = 24
        static let progressBarCornerRadius: CGFloat = 4
        static let progressBarHeight: CGFloat = 8
        static let characterColumnWidth: CGFloat = 40
        static let characterRowVerticalPadding: CGFloat = 14
    }

    // MARK: - Properties

    private var viewModel: StatisticsViewModel?

    // MARK: - UI

    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        return scroll
    }()

    private let contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = Layout.sectionSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    private let calculatingLabel: UILabel = {
        let label = UILabel()
        label.text = AppStrings.Statistics.calculating.localized
        label.font = .appCaption
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let emptyView = EmptyStateView()

    // MARK: - Init

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraint()
    }

    // MARK: - Configuration

    func configure(with viewModel: StatisticsViewModel) {
        self.viewModel = viewModel
        updateContent()
    }

    func showCalculating() {
        contentStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let container = UIView()
        container.addSubview(activityIndicator)
        container.addSubview(calculatingLabel)
        activityIndicator.startAnimating()

        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            activityIndicator.topAnchor.constraint(equalTo: container.topAnchor, constant: Layout.extraLargePadding),
            calculatingLabel.topAnchor.constraint(equalTo: activityIndicator.bottomAnchor, constant: Layout.largeSpacing),
            calculatingLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            calculatingLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -Layout.extraLargePadding)
        ])
        contentStack.addArrangedSubview(container)
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = AppStrings.Statistics.title.localized

        let closeImage = UIImage(systemName: AppIcons.xmark)?
            .withTintColor(.secondaryLabel, renderingMode: .alwaysOriginal)
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: closeImage,
            style: .plain,
            target: self,
            action: #selector(dismissTapped)
        )

        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)
    }

    private func setupConstraint() {
        NSLayoutConstraint.activate([
            // scroll view
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            // content stack
            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
    }

    private func updateContent() {
        contentStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        guard let viewModel = viewModel else { return }

        if viewModel.isCalculating {
            showCalculating()
            return
        }

        if viewModel.pageStats.isEmpty {
            emptyView.configure(
                icon: AppIcons.chartBarFill,
                title: AppStrings.Statistics.noStatistics.localized,
                message: AppStrings.Statistics.noStatisticsMessage.localized
            )
            contentStack.addArrangedSubview(emptyView)
            return
        }

        let pageStatsSection = makePageStatsSection(viewModel)
        contentStack.addArrangedSubview(pageStatsSection)

        contentStack.addArrangedSubview(makeDivider())

        let topCharsSection = makeTopCharactersSection(viewModel)
        contentStack.addArrangedSubview(topCharsSection)

        let summarySection = makeSummarySection(viewModel)
        let summaryWrapper = makeSummaryWrapper(summarySection)
        contentStack.addArrangedSubview(summaryWrapper)

        contentStack.setCustomSpacing(Layout.padding, after: pageStatsSection)
        contentStack.setCustomSpacing(Layout.padding, after: topCharsSection)
    }

    private func makeDivider() -> UIView {
        let line = UIView()
        line.backgroundColor = .separator
        line.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            line.heightAnchor.constraint(equalToConstant: Layout.dividerHeight)
        ])
        return line
    }

    private func makeSummaryWrapper(_ summarySection: UIView) -> UIView {
        let wrapper = UIView()
        summarySection.translatesAutoresizingMaskIntoConstraints = false
        wrapper.addSubview(summarySection)
        NSLayoutConstraint.activate([
            summarySection.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor, constant: Layout.padding),
            summarySection.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor, constant: -Layout.padding),
            summarySection.topAnchor.constraint(equalTo: wrapper.topAnchor),
            summarySection.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor)
        ])
        return wrapper
    }

    private func makePageStatsSection(_ viewModel: StatisticsViewModel) -> UIView {
        let container = UIView()
        let titleLabel = UILabel()
        titleLabel.text = AppStrings.Statistics.itemsPerBlock.localized
        titleLabel.font = .appHeadline
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = Layout.mediumSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false

        for stat in viewModel.pageStats {
            let leftText: String
            if let label = stat.blockLabel, !label.isEmpty {
                leftText = "\(AppStrings.Statistics.page.localized) \(stat.page) (\(label))"
            } else {
                leftText = "\(AppStrings.Statistics.page.localized) \(stat.page)"
            }
            let row = makeStatRow(
                left: leftText,
                right: "\(stat.count) \(AppStrings.Statistics.items.localized)"
            )
            stack.addArrangedSubview(row)
        }

        container.addSubview(titleLabel)
        container.addSubview(stack)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: Layout.padding),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -Layout.padding),
            stack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Layout.standardSpacing),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: Layout.padding),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -Layout.padding),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        return container
    }

    private func makeTopCharactersSection(_ viewModel: StatisticsViewModel) -> UIView {
        let container = UIView()
        let titleLabel = UILabel()
        titleLabel.text = AppStrings.Statistics.top3Characters.localized
        titleLabel.font = .appHeadline
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = Layout.mediumSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false

        let maxCount = viewModel.topCharacters.first?.count ?? 1
        for charStat in viewModel.topCharacters {
            let row = makeCharacterRow(character: charStat.character, count: charStat.count, maxCount: maxCount)
            stack.addArrangedSubview(row)
        }

        container.addSubview(titleLabel)
        container.addSubview(stack)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: Layout.padding),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -Layout.padding),
            stack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Layout.standardSpacing),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: Layout.padding),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -Layout.padding),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        return container
    }

    private func makeSummarySection(_ viewModel: StatisticsViewModel) -> UIView {
        let container = UIView()
        container.backgroundColor = .summaryBackground
        container.layer.cornerRadius = Layout.cornerRadius

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = Layout.mediumSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false

        stack.addArrangedSubview(makeSummaryRow(
            left: AppStrings.Statistics.totalPagesLabel.localized,
            right: "\(viewModel.totalPages)"
        ))
        stack.addArrangedSubview(makeSummaryRow(
            left: AppStrings.Statistics.totalItemsLabel.localized,
            right: "\(viewModel.totalItems)"
        ))

        container.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: container.topAnchor, constant: Layout.padding),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: Layout.padding),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -Layout.padding),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -Layout.padding)
        ])
        return container
    }

    private func makeStatRow(left: String, right: String) -> UIView {
        let row = UIView()
        row.backgroundColor = .statisticsRowBackground
        row.layer.cornerRadius = Layout.smallCornerRadius

        let leftLabel = UILabel()
        leftLabel.text = left
        leftLabel.font = .appBody
        leftLabel.textColor = .label
        leftLabel.numberOfLines = 0
        leftLabel.translatesAutoresizingMaskIntoConstraints = false

        let rightLabel = UILabel()
        rightLabel.text = right
        rightLabel.font = .appBody
        rightLabel.textColor = .secondaryLabel
        rightLabel.translatesAutoresizingMaskIntoConstraints = false

        rightLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        leftLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)

        row.addSubview(leftLabel)
        row.addSubview(rightLabel)

        NSLayoutConstraint.activate([
            leftLabel.leadingAnchor.constraint(equalTo: row.leadingAnchor, constant: Layout.mediumPadding),
            leftLabel.topAnchor.constraint(equalTo: row.topAnchor, constant: Layout.mediumSpacing),
            leftLabel.bottomAnchor.constraint(equalTo: row.bottomAnchor, constant: -Layout.mediumSpacing),
            rightLabel.leadingAnchor.constraint(greaterThanOrEqualTo: leftLabel.trailingAnchor, constant: Layout.mediumSpacing),
            rightLabel.trailingAnchor.constraint(equalTo: row.trailingAnchor, constant: -Layout.mediumPadding),
            rightLabel.centerYAnchor.constraint(equalTo: row.centerYAnchor)
        ])
        return row
    }

    private func makeSummaryRow(left: String, right: String) -> UIView {
        let row = UIView()
        row.backgroundColor = .clear

        let leftLabel = UILabel()
        leftLabel.text = left
        leftLabel.font = .appBody
        leftLabel.textColor = .label
        leftLabel.translatesAutoresizingMaskIntoConstraints = false

        let rightLabel = UILabel()
        rightLabel.text = right
        rightLabel.font = .appBody
        rightLabel.textColor = .label
        rightLabel.translatesAutoresizingMaskIntoConstraints = false

        row.addSubview(leftLabel)
        row.addSubview(rightLabel)

        leftLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        rightLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        NSLayoutConstraint.activate([
            leftLabel.leadingAnchor.constraint(equalTo: row.leadingAnchor, constant: Layout.padding),
            leftLabel.topAnchor.constraint(equalTo: row.topAnchor, constant: Layout.mediumSpacing),
            leftLabel.bottomAnchor.constraint(equalTo: row.bottomAnchor, constant: -Layout.mediumSpacing),
            rightLabel.trailingAnchor.constraint(equalTo: row.trailingAnchor, constant: -Layout.padding),
            rightLabel.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            rightLabel.leadingAnchor.constraint(greaterThanOrEqualTo: leftLabel.trailingAnchor, constant: Layout.mediumSpacing)
        ])
        return row
    }

    private func makeCharacterRow(character: Character, count: Int, maxCount: Int) -> UIView {
        let row = UIView()
        row.backgroundColor = .statisticsRowBackground
        row.layer.cornerRadius = Layout.smallCornerRadius

        let charLabel = UILabel()
        charLabel.text = String(character).uppercased()
        charLabel.font = .systemFont(ofSize: Statistics.characterFontSize, weight: .bold)
        charLabel.textColor = .appAccent
        charLabel.translatesAutoresizingMaskIntoConstraints = false

        let countLabel = UILabel()
        countLabel.text = "= \(count)"
        countLabel.font = .appBody
        countLabel.textColor = .label
        countLabel.translatesAutoresizingMaskIntoConstraints = false

        let progressTrack = UIView()
        progressTrack.backgroundColor = .progressBarTrack
        progressTrack.layer.cornerRadius = Statistics.progressBarCornerRadius
        progressTrack.translatesAutoresizingMaskIntoConstraints = false

        let progressFill = UIView()
        progressFill.backgroundColor = .appAccent
        progressFill.layer.cornerRadius = Statistics.progressBarCornerRadius
        progressFill.translatesAutoresizingMaskIntoConstraints = false

        row.addSubview(charLabel)
        row.addSubview(countLabel)
        row.addSubview(progressTrack)
        progressTrack.addSubview(progressFill)

        let progressWidth: CGFloat = 120
        let progressHeight = Statistics.progressBarHeight
        let fraction = maxCount > 0 ? CGFloat(count) / CGFloat(maxCount) : 0

        NSLayoutConstraint.activate([
            charLabel.leadingAnchor.constraint(equalTo: row.leadingAnchor, constant: Layout.mediumPadding),
            charLabel.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            charLabel.widthAnchor.constraint(equalToConstant: Statistics.characterColumnWidth),
            countLabel.leadingAnchor.constraint(equalTo: charLabel.trailingAnchor, constant: Layout.mediumSpacing),
            countLabel.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            progressTrack.leadingAnchor.constraint(greaterThanOrEqualTo: countLabel.trailingAnchor, constant: Layout.mediumSpacing),
            progressTrack.trailingAnchor.constraint(equalTo: row.trailingAnchor, constant: -Layout.mediumPadding),
            progressTrack.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            progressTrack.widthAnchor.constraint(equalToConstant: progressWidth),
            progressTrack.heightAnchor.constraint(equalToConstant: progressHeight),
            progressTrack.topAnchor.constraint(equalTo: row.topAnchor, constant: Statistics.characterRowVerticalPadding),
            progressTrack.bottomAnchor.constraint(equalTo: row.bottomAnchor, constant: -Statistics.characterRowVerticalPadding),
            progressFill.leadingAnchor.constraint(equalTo: progressTrack.leadingAnchor),
            progressFill.topAnchor.constraint(equalTo: progressTrack.topAnchor),
            progressFill.bottomAnchor.constraint(equalTo: progressTrack.bottomAnchor),
            progressFill.widthAnchor.constraint(equalTo: progressTrack.widthAnchor, multiplier: max(fraction, 0.01))
        ])

        return row
    }

    @objc private func dismissTapped() {
        dismiss(animated: true)
    }
}
 
