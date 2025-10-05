//
//  SheetImageView.swift
//  MusicLessonApp
//
//  Created by Yuusuke Imai on 2025/09/04.
//

import SwiftUI

struct SheetImageView: View {
    let name: String
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero

    var body: some View {
        GeometryReader { geo in
            Image(name)
                .resizable()
                .scaledToFit()
                .offset(offset)
                .scaleEffect(scale)
                .gesture(
                    DragGesture().onChanged { v in
                        offset = CGSize(width: lastOffset.width + v.translation.width,
                                        height: lastOffset.height + v.translation.height)
                    }.onEnded { _ in
                        lastOffset = offset
                    }
                )
                .gesture(
                    MagnificationGesture().onChanged { value in
                        scale = min(max(1.0, value), 4.0)
                    }
                )
                .frame(width: geo.size.width, height: geo.size.height)
                .background(Color(.secondarySystemBackground))
        }
    }
}
