//
//  PageIndicatorView.swift
//  CarouselListDemo
//
//  Created by Alexandra Homan
//

import SwiftUI

struct PageIndicatorView: View {
    private enum Layout {
        static let dotCount = 5
        static let spacing: CGFloat = 8
        static let dotSize: CGFloat = 8
    }

    let currentPage: Int
    let totalPages: Int

    private var activeDotIndex: Int {
        totalPages <= Layout.dotCount ? currentPage : currentPage % Layout.dotCount
    }

    var body: some View {
        HStack(spacing: Layout.spacing) {
            ForEach(0..<min(totalPages, Layout.dotCount), id: \.self) { index in
                Circle()
                    .fill(index == activeDotIndex ? Color.appAccent : Color.pageIndicatorInactive)
                    .frame(
                        width: Layout.dotSize,
                        height: Layout.dotSize
                    )
            }
        }
    }
}

 
