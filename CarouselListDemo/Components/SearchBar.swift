//
//  SearchBar.swift
//  CarouselListDemo
//
//  Created by Alexandra Homan
//

import SwiftUI

struct SearchBar: View {
    private enum Layout {
        static let standardSpacing: CGFloat = 12
        static let horizontalPadding: CGFloat = 12
        static let verticalPadding: CGFloat = 10
        static let smallCornerRadius: CGFloat = 8
        static let padding: CGFloat = 16
    }

    @Binding var text: String
    var placeholder: String = AppStrings.List.searchPlaceholder.localized
    var onClear: (() -> Void)?
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack(spacing: Layout.standardSpacing) {
            Image(systemName: AppIcons.magnifyingGlass)
                .foregroundStyle(.secondary)
            
            TextField(placeholder, text: $text)
                .focused($isFocused)
                .textFieldStyle(.plain)
                .accessibilityIdentifier("searchBar")
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
            
            if !text.isEmpty {
                Button {
                    text = ""
                    onClear?()
                } label: {
                    Image(systemName: AppIcons.xmarkCircleFill)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, Layout.horizontalPadding)
        .padding(.vertical, Layout.verticalPadding)
        .background(Color.searchBar)
        .cornerRadius(Layout.smallCornerRadius)
    }
}

#Preview {
    VStack {
        SearchBar(text: .constant(""))
        SearchBar(text: .constant("Search text"))
    }
    .padding(16)
}

 
