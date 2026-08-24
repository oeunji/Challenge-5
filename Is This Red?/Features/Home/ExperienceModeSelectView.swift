//
//  ExperienceModeSelectView.swift
//  Is This Red?
//
//  Created by 이은지 on 2/25/26.
//

import SwiftUI

struct ExperienceModeSelectView: View {

	// MARK: - Constants

	private enum Metric {
		static let cornerRadius: CGFloat = 24
		static let buttonWidth: CGFloat = 400
		static let buttonMinHeight: CGFloat = 64
	}

	// MARK: - Properties

	@Environment(AppCoordinator.self) private var coordinator

	// MARK: - Body

	var body: some View {
		ZStack {
			GridBackground()
			VStack(spacing: 16) {
				Spacer()

				Image("logo")
					.resizable()
					.scaledToFit()
					.frame(maxWidth: 520, maxHeight: 140)

				Text("The color you see isn’t the color everyone sees.")
					.font(Typography.title2.weight(.semibold))
					.foregroundColor(AppColor.title)

				Spacer()
					.frame(height: 46)

				Text("Choose Your Experience")
					.font(Typography.body.weight(.medium))
					.foregroundColor(AppColor.subtitle)
					.padding(.vertical, 10)

				HStack(spacing: 16) {
					modeButton(
						title: "See Through Their Eyes",
						subtitle: "Simulate how your drawing looks to them",
						route: .create
					)

					modeButton(
						title: "Draw As Them",
						subtitle: "Draw with color-vision limits",
						route: .visionModeSelect
					)
				}
				.padding(.horizontal, 32)
				.padding(.vertical, 10)

				Spacer()
			}
		}
	}
}

// MARK: - Subviews

extension ExperienceModeSelectView {
    
    private func modeButton(title: String, subtitle: String, route: Route) -> some View {
        Button {
            coordinator.push(route)
        } label: {
            VStack(spacing: 6) {
                Text(title)
                    .font(Typography.headline)
                    .foregroundColor(AppColor.title)
                Text(subtitle)
                    .font(Typography.caption1)
                    .foregroundColor(AppColor.subtitle)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(width: Metric.buttonWidth)
            .frame(minHeight: Metric.buttonMinHeight)
            .padding(.vertical, 6)
            .cardSurface(cornerRadius: Metric.cornerRadius)
        }
        .buttonStyle(.plain)
    }
}
