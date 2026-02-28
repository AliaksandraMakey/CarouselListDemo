//
//  StatisticsSheet.swift
//  CarouselListDemo
//
//  Created by Alexandra Homan
//

import SwiftUI

struct StatisticsSheet: View {
    private enum Layout {
        static let sectionSpacing: CGFloat = 24
        static let largeSpacing: CGFloat = 16
        static let progressViewScale: CGFloat = 1.5
        static let extraLargePadding: CGFloat = 40
        static let padding: CGFloat = 16
        static let standardSpacing: CGFloat = 12
        static let mediumSpacing: CGFloat = 8
        static let smallPadding: CGFloat = 8
        static let mediumPadding: CGFloat = 12
        static let smallCornerRadius: CGFloat = 8
        static let cornerRadius: CGFloat = 12
        static let progressBarCornerRadius: CGFloat = 4
    }
    private enum Statistics {
        static let characterFontSize: CGFloat = 24
        static let characterColumnWidth: CGFloat = 40
        static let progressBarHeight: CGFloat = 8
    }

    @Bindable var viewModel: StatisticsViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Layout.sectionSpacing) {
                    if viewModel.isCalculating {
                        VStack(spacing: Layout.largeSpacing) {
                            ProgressView()
                                .scaleEffect(Layout.progressViewScale)
                            Text(AppStrings.Statistics.calculating.localized)
                                .font(.appCaption)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(Layout.extraLargePadding)
                    } else if !viewModel.statistics.blockStats.isEmpty {
                        itemsPerBlockSection
                        Divider()
                            .padding(.horizontal, Layout.padding)
                        topCharactersSection
                        Divider()
                            .padding(.horizontal, Layout.padding)
                        summarySection
                    } else {
                        EmptyStateView(
                            icon: AppIcons.chartBarFill,
                            title: AppStrings.Statistics.noStatistics.localized,
                            message: AppStrings.Statistics.noStatisticsMessage.localized
                        )
                    }
                }
                .padding(.vertical, Layout.padding)
            }
            .background(Color.appBackground)
            .navigationTitle(AppStrings.Statistics.title.localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.hideStatisticsSheet()
                    } label: {
                        Image(systemName: AppIcons.xmarkCircleFill)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    private var itemsPerBlockSection: some View {
        VStack(alignment: .leading, spacing: Layout.standardSpacing) {
            Text(AppStrings.Statistics.itemsPerBlock.localized)
                .font(.appHeadline)
                .foregroundStyle(.primary)

            VStack(spacing: Layout.mediumSpacing) {
                ForEach(viewModel.statistics.blockStats) { stat in
                    HStack(alignment: .top, spacing: Layout.standardSpacing) {
                        Text("\(AppStrings.Statistics.page.localized) \(stat.pageNumber) (\(stat.authorName))")
                            .font(.appBody)
                            .foregroundStyle(.primary)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)

                        Spacer(minLength: Layout.standardSpacing)

                        Text("\(stat.itemCount) \(AppStrings.Statistics.items.localized)")
                            .font(.appBody)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                            .layoutPriority(1)
                    }
                    .padding(.vertical, Layout.smallPadding)
                    .padding(.horizontal, Layout.mediumPadding)
                    .background(Color.cardBackground)
                    .cornerRadius(Layout.smallCornerRadius)
                }
            }
        }
        .padding(.horizontal, Layout.padding)
    }

    private var topCharactersSection: some View {
        VStack(alignment: .leading, spacing: Layout.standardSpacing) {
            Text(AppStrings.Statistics.top3Characters.localized)
                .font(.appHeadline)
                .foregroundStyle(.primary)

            VStack(spacing: Layout.mediumSpacing) {
                ForEach(viewModel.statistics.topCharacters) { char in
                    HStack {
                        Text(String(char.character).uppercased())
                            .font(.system(size: Statistics.characterFontSize, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.appAccent)
                            .frame(width: Statistics.characterColumnWidth)

                        Text("=")
                            .font(.appBody)
                            .foregroundStyle(.secondary)

                        Text("\(char.count)")
                            .font(.appBody)
                            .fontWeight(.semibold)
                            .foregroundStyle(.primary)

                        Spacer()

                        GeometryReader { geometry in
                            let maxCount = viewModel.statistics.topCharacters.first?.count ?? 1
                            let percentage = CGFloat(char.count) / CGFloat(maxCount)
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: Layout.progressBarCornerRadius)
                                    .fill(Color.progressBarTrack)
                                RoundedRectangle(cornerRadius: Layout.progressBarCornerRadius)
                                    .fill(Color.appAccent)
                                    .frame(width: geometry.size.width * percentage)
                            }
                        }
                        .frame(height: Statistics.progressBarHeight)
                    }
                    .padding(.vertical, Layout.mediumPadding)
                    .padding(.horizontal, Layout.mediumPadding)
                    .background(Color.cardBackground)
                    .cornerRadius(Layout.smallCornerRadius)
                }
            }
        }
        .padding(.horizontal, Layout.padding)
    }

    private var summarySection: some View {
        VStack(spacing: Layout.mediumSpacing) {
            HStack {
                Text(AppStrings.Statistics.totalPagesLabel.localized)
                    .foregroundStyle(.secondary)
                    .lineLimit(nil)
                Spacer()
                Text("\(viewModel.statistics.totalPages)")
                    .fontWeight(.semibold)
                    .layoutPriority(1)
            }

            HStack {
                Text(AppStrings.Statistics.totalItemsLabel.localized)
                    .foregroundStyle(.secondary)
                    .lineLimit(nil)
                Spacer()
                Text("\(viewModel.statistics.totalItems)")
                    .fontWeight(.semibold)
                    .layoutPriority(1)
            }
        }
        .font(.appBody)
        .padding(Layout.padding)
        .background(Color.highlightBackground)
        .cornerRadius(Layout.cornerRadius)
        .padding(.horizontal, Layout.padding)
    }
}

 
