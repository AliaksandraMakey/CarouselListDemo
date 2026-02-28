//
//  FloatingActionButton.swift
//  CarouselListDemo
//
//  Created by Alexandra Homan
//

import SwiftUI

struct FloatingActionButton: View {
    private enum Layout {
        static let fabSize: CGFloat = 56
        static let fabDotSize: CGFloat = 6
        static let fabDotSpacing: CGFloat = 2
        static let fabShadowRadius: CGFloat = 8
        static let fabShadowY: CGFloat = 4
        static let padding: CGFloat = 16
    }

    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: Layout.fabDotSpacing) {
                ForEach(0..<3, id: \.self) { _ in
                    Circle()
                        .fill(.white)
                        .frame(width: Layout.fabDotSize, height: Layout.fabDotSize)
                }
            }
                .frame(
                    width: Layout.fabSize,
                    height: Layout.fabSize
                )
                .background(
                    Circle()
                        .fill(Color.appAccent)
                        .shadow(
                            color: Color.shadowColor,
                            radius: Layout.fabShadowRadius,
                            x: 0,
                            y: Layout.fabShadowY
                        )
                )
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("fab")
    }
}

#Preview {
    ZStack {
        Color.imagePlaceholderLight
        
        VStack {
            Spacer()
            HStack {
                Spacer()
                FloatingActionButton {
                    print("FAB tapped")
                }
                .padding(16)
            }
        }
    }
}

 
