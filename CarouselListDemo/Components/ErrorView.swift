//
//  ErrorView.swift
//  CarouselListDemo
//
//  Created by Alexandra Homan
//

import SwiftUI

struct ErrorView: View {
    private enum Layout {
        static let contentBlockSpacing: CGFloat = 20
        static let mediumSpacing: CGFloat = 8
        static let buttonHorizontalPadding: CGFloat = 24
        static let buttonVerticalPadding: CGFloat = 12
        static let extraLargePadding: CGFloat = 40
        static let largeIconSize: CGFloat = 60
    }

    let message: String
    let retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: Layout.contentBlockSpacing) {
            Image(systemName: AppIcons.exclamationmarkTriangle)
                .font(.system(size: Layout.largeIconSize))
                .foregroundStyle(Color.appError)
            
            VStack(spacing: Layout.mediumSpacing) {
                Text(AppStrings.General.error.localized)
                    .font(.appHeadline)
                    .foregroundStyle(.primary)
                
                Text(message)
                    .font(.appBody)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: retryAction) {
                HStack {
                    Image(systemName: AppIcons.arrowClockwise)
                    Text(AppStrings.General.retry.localized)
                }
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
        .padding(Layout.extraLargePadding)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    ErrorView(
        message: AppStrings.Errors.loadDataFailed.localized,
        retryAction: { print("Retry") }
    )
}
