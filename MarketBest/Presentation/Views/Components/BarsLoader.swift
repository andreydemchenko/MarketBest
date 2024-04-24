//
//  BarsLoader.swift
//  MarketBest
//
//  Created by Macbook Pro on 13.04.2024.
//

import Foundation
import SwiftUI

struct BarsLoader: View {
    @Binding var isAnimating: Bool
    var color: Color = Color.primaryColor
    var count: UInt = 5
    var spacing: CGFloat = 4
    var cornerRadius: CGFloat = 4
    var scaleRange: ClosedRange<Double> = 0.5...1
    var opacityRange: ClosedRange<Double> = 0.5...1

    var body: some View {
        GeometryReader { geometry in
            ForEach(0..<Int(count)) { index in
                item(forIndex: index, in: geometry.size)
            }
        }
        .aspectRatio(contentMode: .fit)
    }

    private var scale: CGFloat { CGFloat(isAnimating ? scaleRange.lowerBound : scaleRange.upperBound) }
    private var opacity: Double { isAnimating ? opacityRange.lowerBound : opacityRange.upperBound }

    private func size(count: UInt, geometry: CGSize) -> CGFloat {
        (geometry.width/CGFloat(count)) - (spacing-2)
    }

    private func item(forIndex index: Int, in geometrySize: CGSize) -> some View {
        RoundedRectangle(cornerRadius: cornerRadius,  style: .continuous)
            .frame(width: size(count: count, geometry: geometrySize), height: geometrySize.height)
            .foregroundStyle(color)
            .scaleEffect(x: 1, y: scale, anchor: .center)
            .opacity(opacity)
            .animation(
                Animation
                    .default
                    .repeatCount(isAnimating ? .max : 1, autoreverses: true)
                    .delay(Double(index) / Double(count) / 2),
                value: isAnimating
            )
            .offset(x: CGFloat(index) * (size(count: count, geometry: geometrySize) + spacing))
    }
}
