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
        static let cornerRadius: CGFloat = 16
    }

    // MARK: - Body

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(.white)
            .background(
                RoundedRectangle(cornerRadius: Metric.cornerRadius, style: .continuous)
                    .fill(.white.opacity(configuration.isPressed ? 0.18 : 0.22))
                    .overlay(
                        RoundedRectangle(cornerRadius: Metric.cornerRadius, style: .continuous)
                            .stroke(.white.opacity(0.35), lineWidth: 1)
                    )
                    .shadow(radius: configuration.isPressed ? 2 : 10)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.12), value: configuration.isPressed)
    }
}
