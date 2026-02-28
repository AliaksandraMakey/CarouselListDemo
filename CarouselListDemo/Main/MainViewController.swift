//
//  MainViewController.swift
//  CarouselListDemo
//
//  Created by Alexandra Homan
//

import UIKit

final class MainViewController: UIViewController {

    // MARK: - State

    private var currentPageIndex: Int = 0
    private var listItems: [ListItem] = []
    private var searchText: String = ""
    private var isCarouselLoading: Bool = false
    private var carouselErrorMessage: String?
    private var isSearching: Bool = false

    // MARK: - Dependencies

    private let interactor: MainInteractorProtocol
    private let imageLoader: ImageLoader

    // MARK: - UI

    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.backgroundColor = .appBackground
        table.separatorStyle = .none
        table.translatesAutoresizingMaskIntoConstraints = false
        table.isDirectionalLockEnabled = true
        return table
    }()

    private lazy var carouselHeaderView: CarouselTableHeaderView = {
        let header = CarouselTableHeaderView()
        let width = view.bounds.width > 0 ? view.bounds.width : UIScreen.main.bounds.width
        header.frame = CGRect(
            x: 0,
            y: 0,
            width: max(width, 1),
            height: CarouselTableHeaderView.preferredHeight
        )
        return header
    }()

    private lazy var searchBarHeaderView: SearchBarSectionHeaderView = {
        SearchBarSectionHeaderView()
    }()

    private let floatingActionButton = FloatingActionButton()
    private let emptyStateView = EmptyStateView()

    private var carouselView: CarouselView { carouselHeaderView.carouselView }
    private var searchBarView: SearchBarView { searchBarHeaderView.searchBarView }

    private var showEmptyState: Bool {
        (isSearching && listItems.isEmpty) || (!isSearching && listItems.isEmpty && !isCarouselLoading && carouselErrorMessage == nil)
    }

    // MARK: - Init

    init(interactor: MainInteractorProtocol, imageLoader: ImageLoader) {
        self.interactor = interactor
        self.imageLoader = imageLoader
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupDelegates()
        setupConstraint()
        bind()
        interactor.loadData()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let header = tableView.tableHeaderView, abs(header.bounds.width - tableView.bounds.width) > 1 {
            var frame = header.frame
            frame.size.width = tableView.bounds.width
            header.frame = frame
            tableView.tableHeaderView = header
        }
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = .appBackground

        carouselView.imageLoader = imageLoader
        carouselView.delegate = self
        floatingActionButton.translatesAutoresizingMaskIntoConstraints = false
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateView.backgroundColor = .appBackground
        emptyStateView.isHidden = true

        tableView.tableHeaderView = carouselHeaderView
        view.addSubview(tableView)
        view.addSubview(emptyStateView)
        view.addSubview(floatingActionButton)
    }

    private func setupDelegates() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ListItemCell.self, forCellReuseIdentifier: ListItemCell.reuseIdentifier)
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.estimatedRowHeight = 88
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedSectionHeaderHeight = SearchBarSectionHeaderView.preferredHeight
        tableView.sectionHeaderTopPadding = 0
    }

    private func bind() {
        carouselView.onRetry = { [weak self] in
            self?.interactor.loadData()
        }
        searchBarView.onTextChange = { [weak self] text in
            self?.interactor.handleSearchTextChanged(text)
        }
        searchBarView.onClear = { [weak self] in
            self?.interactor.handleSearchTextChanged("")
        }
        floatingActionButton.onTap = { [weak self] in
            self?.interactor.handleFabTapped()
        }
    }

    private func setupConstraint() {
        enum Layout {
            static let padding: CGFloat = 16
            static let fabTrailingPadding: CGFloat = 20
            static let fabBottomPadding: CGFloat = 20
        }

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Layout.padding),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Layout.padding),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            emptyStateView.topAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Layout.padding),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Layout.padding),
            emptyStateView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            floatingActionButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Layout.fabTrailingPadding),
            floatingActionButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Layout.fabBottomPadding)
        ])
    }

    // MARK: - Content Updates

    private func refreshContent() {
        tableView.reloadData()
        updateEmptyState()
    }

    private func updateEmptyState() {
        emptyStateView.isHidden = !showEmptyState
        guard showEmptyState else { return }
        if isSearching {
            emptyStateView.configure(
                icon: AppIcons.magnifyingGlass,
                title: AppStrings.List.noResultsMessage.localized,
                message: AppStrings.List.noResultsHint.localized,
                actionTitle: AppStrings.List.clearSearch.localized
            )
            emptyStateView.onAction = { [weak self] in
                self?.searchBarView.text = ""
                self?.interactor.handleSearchTextChanged("")
            }
        } else {
            emptyStateView.configure(
                icon: AppIcons.photo,
                title: AppStrings.General.noItems.localized,
                message: AppStrings.General.loadImagesMessage.localized,
                actionTitle: nil
            )
        }
    }
}

// MARK: - MainDisplayLogic

extension MainViewController: MainDisplayLogic {

    func displayCarousel(_ viewModel: MainViewModel) {
        currentPageIndex = viewModel.currentPageIndex
        carouselView.carouselPages = viewModel.carouselPages
        carouselView.currentPageIndex = currentPageIndex
        carouselView.isLoading = false
        carouselView.errorMessage = nil

        if viewModel.shouldScrollToBlock {
            carouselView.scrollToPage(viewModel.currentPageIndex, animated: true)
        }
        refreshContent()
    }

    func displayCarouselLoading() {
        isCarouselLoading = true
        carouselView.isLoading = true
        carouselView.errorMessage = nil
        refreshContent()
    }

    func displayCarouselError(_ message: String) {
        isCarouselLoading = false
        carouselView.isLoading = false
        carouselView.errorMessage = message
        carouselErrorMessage = message
        refreshContent()
    }

    func displayFilteredList(_ viewModel: MainViewModel) {
        listItems = viewModel.listItems
        searchText = viewModel.searchText
        isSearching = viewModel.isSearching
        searchBarView.text = searchText
        refreshContent()
    }

    func displayStatistics(_ viewModel: StatisticsViewModel) {
        if let navigationController = presentedViewController as? UINavigationController,
           let statisticsSheet = navigationController.viewControllers.first as? StatisticsBottomSheet {
            statisticsSheet.configure(with: viewModel)
        } else {
            let statisticsSheet = StatisticsBottomSheet()
            statisticsSheet.configure(with: viewModel)
            presentSheet(statisticsSheet)
        }
    }

    func displayStatisticsCalculating() {
        let statisticsSheet = StatisticsBottomSheet()
        statisticsSheet.showCalculating()
        presentSheet(statisticsSheet)
    }

    // MARK: - Private

    private func presentSheet(_ sheet: StatisticsBottomSheet) {
        if let presentationController = sheet.sheetPresentationController {
            presentationController.detents = [.medium(), .large()]
            presentationController.prefersGrabberVisible = true
        }
        let navigationController = UINavigationController(rootViewController: sheet)
        present(navigationController, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension MainViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if showEmptyState { return 0 }
        return listItems.count + 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == listItems.count {
            let cell = UITableViewCell()
            cell.backgroundColor = .clear
            cell.selectionStyle = .none
            cell.contentView.backgroundColor = .clear
            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: ListItemCell.reuseIdentifier, for: indexPath) as! ListItemCell
        guard indexPath.row < listItems.count else { return cell }
        cell.configure(with: listItems[indexPath.row], imageLoader: imageLoader)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension MainViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        searchBarHeaderView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        SearchBarSectionHeaderView.preferredHeight
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == listItems.count {
            interactor.handleLoadMoreIfNeeded()
        }
    }
}

// MARK: - CarouselViewDelegate

extension MainViewController: CarouselViewDelegate {

    func carouselView(_ view: CarouselView, didChangePageTo index: Int) {
        interactor.handleCarouselPageChanged(index: index)
    }
}
