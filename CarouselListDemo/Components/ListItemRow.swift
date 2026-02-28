//
//  ListItemRow.swift
//  CarouselListDemo
//
//  Created by Alexandra Homan
//

import SwiftUI

struct ListItemRow: View {
    private enum Layout {
        static let thumbnailSize: CGFloat = 56
        static let standardSpacing: CGFloat = 12
        static let tightSpacing: CGFloat = 4
        static let mediumPadding: CGFloat = 12
        static let smallCornerRadius: CGFloat = 8
        static let cornerRadius: CGFloat = 12
    }

    let item: ListItem
    var onTap: (() -> Void)?
    
    var body: some View {
        Button(action: { onTap?() }) {
            HStack(spacing: Layout.standardSpacing) {
                AsyncImageView(
                    url: item.thumbnailURL,
                    contentMode: .fill
                )
                .frame(width: Layout.thumbnailSize, height: Layout.thumbnailSize)
                .cornerRadius(Layout.smallCornerRadius)
                
                VStack(alignment: .leading, spacing: Layout.tightSpacing) {
                    Text(item.title)
                        .font(.appHeadline)
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                    
                    Text(item.body)
                        .font(.appCaption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
            }
            .padding(Layout.mediumPadding)
            .background(
                RoundedRectangle(cornerRadius: Layout.cornerRadius)
                    .fill(Color.cardBackground)
            )
        }
        .buttonStyle(.plain)
    }
}

 
