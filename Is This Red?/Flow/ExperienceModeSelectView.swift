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
					.font(.system(size: 22, weight: .semibold))
					.foregroundColor(AppColor.title)

				Spacer()
					.frame(height: 46)

				Text("Choose Your Experience")
					.font(.system(size: 18, weight: .medium))
					.foregroundColor(AppColor.subtitle)
					.padding(.vertical, 10)

				HStack(spacing: 16) {
					modeButton(
						title: "See Through Their Eyes",
						subtitle: "Simulate how your drawing looks to them"
					) {
						CreateView()
					}

					modeButton(
						title: "Draw As Them",
						subtitle: "Draw with color-vision limits"
					) {
						VisionModeSelectView()
					}
				}
				.padding(.horizontal, 32)
				.padding(.vertical, 10)

				Spacer()
			}
		}
	}

	// MARK: - Subviews

	private func modeButton<Destination: View>(
		title: String,
		subtitle: String,
		destination: @escaping () -> Destination
	) -> some View {
		NavigationLink(destination: destination()) {
			VStack(spacing: 6) {
				Text(title)
					.font(.system(size: 18, weight: .semibold))
					.foregroundColor(AppColor.title)
				Text(subtitle)
					.font(.system(size: 12, weight: .regular))
					.foregroundColor(AppColor.subtitle)
					.multilineTextAlignment(.center)
					.lineLimit(2)
			}
			.frame(width: Metric.buttonWidth)
			.frame(minHeight: Metric.buttonMinHeight)
			.padding(.vertical, 6)
			.background(.white)
			.clipShape(RoundedRectangle(cornerRadius: Metric.cornerRadius, style: .continuous))
			.overlay(
				RoundedRectangle(cornerRadius: Metric.cornerRadius, style: .continuous)
					.stroke(AppColor.cardBorder, lineWidth: 1.5)
			)
			.shadow(color: .white.opacity(0.25), radius: 4, x: 0, y: 2)
		}
		.buttonStyle(.plain)
	}
}
