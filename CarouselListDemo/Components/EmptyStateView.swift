//
//  EmptyStateView.swift
//  CarouselListDemo
//
//  Created by Alexandra Homan
//

import SwiftUI

struct EmptyStateView: View {
    private enum Layout {
        static let contentBlockSpacing: CGFloat = 20
        static let mediumSpacing: CGFloat = 8
        static let buttonHorizontalPadding: CGFloat = 24
        static let buttonVerticalPadding: CGFloat = 12
        static let extraLargePadding: CGFloat = 40
        static let largeIconSize: CGFloat = 60
    }

    let icon: String
    let title: String
    let message: String
    var actionTitle: String?
    var action: (() -> Void)?
    
    var body: some View {
        VStack(spacing: Layout.contentBlockSpacing) {
            Image(systemName: icon)
                .font(.system(size: Layout.largeIconSize))
                .foregroundStyle(.secondary)
            
            VStack(spacing: Layout.mediumSpacing) {
                Text(title)
                    .font(.appHeadline)
                    .foregroundStyle(.primary)
                
                Text(message)
                    .font(.appBody)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.appBody)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .padding(.horizontal, Layout.buttonHorizontalPadding)
                        .padding(.vertical, Layout.buttonVerticalPadding)
                        .background(
                            Capsule()
                                .fill(Color.appAccent)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(Layout.extraLargePadding)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    EmptyStateView(
        icon: AppIcons.magnifyingGlass,
        title: AppStrings.List.noResults.localized,
        message: AppStrings.List.noResultsMessage.localized,
        actionTitle: AppStrings.List.clearSearch.localized,
        action: { print("Clear") }
    )
}
