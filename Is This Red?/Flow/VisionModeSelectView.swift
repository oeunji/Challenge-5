//
//  VisionModeSelectView.swift
//  Is This Red?
//

import SwiftUI

struct VisionModeSelectView: View {

	private enum Metric {
		static let cardSpacing: CGFloat = 14
		static let cornerRadius: CGFloat = 14
		static let cardMaxWidth: CGFloat = 400
		static let cardMinHeight: CGFloat = 200
	}

	private static let modes: [(mode: VisionMode, subtitle: String)] = [
		(.protanopia, "Reduced sensitivity to red."),
		(.deuteranopia, "Reduced sensitivity to green."),
		(.tritanopia, "Reduced sensitivity to blue."),
		(.achromatopsia, "No color perception.")
	]

	var body: some View {
		ZStack {
			GridBackground()
			VStack(spacing: 18) {
				Spacer()

				Text("Choose a Vision Mode")
					.font(.system(size: 32, weight: .semibold, design: .rounded))
					.padding(.top, 12)

				Spacer()

				VStack(spacing: Metric.cardSpacing) {
					ForEach(0..<2, id: \.self) { row in
						HStack(spacing: Metric.cardSpacing) {
							modeCard(Self.modes[row * 2])
							modeCard(Self.modes[row * 2 + 1])
						}
					}
				}
				.padding(.horizontal, 20)

				Spacer()
			}
		}
	}

	private func modeCard(_ item: (mode: VisionMode, subtitle: String)) -> some View {
		NavigationLink(destination: ColorblindDrawView(selectedMode: item.mode)) {
			VStack(alignment: .center, spacing: 10) {
				Text(item.mode.rawValue)
					.font(.system(size: 24, weight: .semibold))
					.foregroundColor(AppColor.title)
					.multilineTextAlignment(.center)
				Text(item.subtitle)
					.font(.system(size: 18, weight: .regular))
					.foregroundColor(AppColor.subtitle)
					.multilineTextAlignment(.center)
			}
			.frame(maxWidth: Metric.cardMaxWidth, minHeight: Metric.cardMinHeight)
			.padding(.horizontal, 12)
			.background(Color.white)
			.clipShape(RoundedRectangle(cornerRadius: Metric.cornerRadius, style: .continuous))
			.overlay(
				RoundedRectangle(cornerRadius: Metric.cornerRadius, style: .continuous)
					.stroke(AppColor.cardBorder, lineWidth: 1.5)
			)
		}
		.buttonStyle(.plain)
	}
}
