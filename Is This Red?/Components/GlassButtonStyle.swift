//
//  GlassButtonStyle.swift
//  Is This Red?
//
//  Created by 이은지 on 8/20/26.
//

import SwiftUI

struct GlassButtonStyle: ButtonStyle {

    // MARK: - Constants

    private enum Metric {
        static let cornerRadius: CGFloat = Radius.medium
    }

    // MARK: - Body

    func makeBody(configuration: Configuration) -> some View {
        let shape = RoundedRectangle(cornerRadius: Metric.cornerRadius, style: .continuous)

        return configuration.label
            .foregroundStyle(.white)
            .background(
                // Color.clear로 한 겹 감싸야 그림자가 라벨이 아닌 배경 도형에만 붙습니다.
                Color.clear
                    .glossyElevation(
                        fill: Color.white.opacity(configuration.isPressed ? 0.18 : 0.22),
                        in: shape,
                        pressed: configuration.isPressed
                    )
                    .overlay(shape.stroke(.white.opacity(0.35), lineWidth: 1))
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.12), value: configuration.isPressed)
    }
}
