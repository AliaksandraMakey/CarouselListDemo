//
//  AppView.swift
//  CarouselListDemo
//
//  Created by Alexandra Homan
//

import SwiftUI

struct AppView: View {
    private enum Layout {
        static let padding: CGFloat = 16
        static let smallPadding: CGFloat = 8
        static let standardSpacing: CGFloat = 12
        static let fabTrailingPadding: CGFloat = 20
        static let fabBottomPadding: CGFloat = 20
    }

    @State private var mainViewModel: MainViewModel
    @State private var statisticsViewModel: StatisticsViewModel

    init() {
        let networkService = NetworkService()
        let cacheService = ImageCacheService()
        let accessKey = APIKeys.unsplashAccessKey ?? ""
        let dataProvider = RemoteDataProvider(networkService: networkService, accessKey: accessKey)
        let main = MainViewModel(
            dataProvider: dataProvider,
            networkService: networkService,
            cacheService: cacheService
        )
        _mainViewModel = State(initialValue: main)
        _statisticsViewModel = State(initialValue: StatisticsViewModel(mainViewModel: main))
    }

    var body: some View {
        @Bindable var main = mainViewModel
        @Bindable var stats = statisticsViewModel

        ZStack(alignment: .top) {
            Color.appBackground
                .ignoresSafeArea()

            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0, pinnedViews: .sectionHeaders) {
                    Section {
                        CarouselView(viewModel: main)
                    }

                    Section {
                        listContent(main: main)
                    } header: {
                        SearchBar(
                            text: $main.searchQuery,
                            onClear: { main.clearSearch() }
                        )
                        .padding(.horizontal, Layout.padding)
                        .padding(.vertical, Layout.smallPadding)
                        .frame(maxWidth: .infinity)
                        .background(Color.appBackground)
                    }
                }
            }
            .environment(\.imageServices, ImageServices(
                networkService: mainViewModel.networkService,
                cacheService: mainViewModel.cacheService
            ))

            VStack {
                Spacer()
                HStack {
                    Spacer()
                    FloatingActionButton {
                        stats.showStatisticsSheet()
                    }
                    .padding(.trailing, Layout.fabTrailingPadding)
                    .padding(.bottom, Layout.fabBottomPadding)
                }
            }
        }
        .sheet(isPresented: $stats.isPresented) {
            StatisticsSheet(viewModel: stats)
        }
        .task {
            await mainViewModel.loadInitialData()
        }
    }

    @ViewBuilder
    private func listContent(main: MainViewModel) -> some View {
        if main.isSearching && main.filteredListItems.isEmpty {
            EmptyStateView(
                icon: AppIcons.magnifyingGlass,
                title: AppStrings.List.noResults.localized,
                message: AppStrings.List.noResultsMessage.localized,
                actionTitle: AppStrings.List.clearSearch.localized,
                action: { main.clearSearch() }
            )
            .frame(maxWidth: .infinity)
            .frame(minHeight: 200)
        } else if !main.filteredListItems.isEmpty {
            LazyVStack(alignment: .leading, spacing: Layout.standardSpacing) {
                ForEach(main.filteredListItems) { item in
                    ListItemRow(item: item)
                        .padding(.horizontal, Layout.padding)
                }

                Color.clear
                    .frame(height: 1)
                    .onAppear {
                        Task { await main.loadMoreIfNeeded() }
                    }
            }
            .padding(.vertical, Layout.smallPadding)
            .frame(maxWidth: .infinity)
        } else {
            defaultEmptyStateView
        }
    }

    private var defaultEmptyStateView: some View {
        EmptyStateView(
            icon: AppIcons.photo,
            title: AppStrings.General.noItems.localized,
            message: AppStrings.General.loadImagesMessage.localized
        )
        .frame(maxWidth: .infinity)
        .frame(minHeight: 200)
    }
}
