//
//  VisionModeSelectView.swift
//  Is This Red?
//

import SwiftUI

struct VisionModeSelectView: View {

	// MARK: - Constants

	private enum Metric {
		static let cardSpacing: CGFloat = Spacing.x12
		static let cornerRadius: CGFloat = 14
		static let cardMaxWidth: CGFloat = 400
		static let cardMinHeight: CGFloat = 200
	}

	// MARK: - Properties

	@Environment(AppCoordinator.self) private var coordinator

	private static let modes: [(mode: VisionMode, subtitle: String)] = [
		(.protanopia, "Reduced sensitivity to red."),
		(.deuteranopia, "Reduced sensitivity to green."),
		(.tritanopia, "Reduced sensitivity to blue."),
		(.achromatopsia, "No color perception.")
	]

	// MARK: - Body

	var body: some View {
		ZStack {
			GridBackground()
			VStack(spacing: Spacing.x16) {
				Spacer()

				Text("Choose a Vision Mode")
					.font(Typography.largeTitle.weight(.semibold))
					.fontDesign(.rounded)
					.padding(.top, Spacing.x12)

				Spacer()

				VStack(spacing: Metric.cardSpacing) {
					ForEach(0..<2, id: \.self) { row in
						HStack(spacing: Metric.cardSpacing) {
							modeCard(Self.modes[row * 2])
							modeCard(Self.modes[row * 2 + 1])
						}
					}
				}
				.padding(.horizontal, Spacing.x24)

				Spacer()
			}
		}
	}
}

// MARK: - Subviews

extension VisionModeSelectView {
    
    private func modeCard(_ item: (mode: VisionMode, subtitle: String)) -> some View {
        Button {
            coordinator.push(.colorblindDraw(item.mode))
        } label: {
            VStack(alignment: .center, spacing: Spacing.x12) {
                Text(item.mode.rawValue)
                    .font(Typography.title2.weight(.semibold))
                    .foregroundColor(AppColor.title)
                    .multilineTextAlignment(.center)
                Text(item.subtitle)
                    .font(Typography.body)
                    .foregroundColor(AppColor.subtitle)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: Metric.cardMaxWidth, minHeight: Metric.cardMinHeight)
            .padding(.horizontal, Spacing.x12)
            .cardSurface(cornerRadius: Metric.cornerRadius)
        }
        .buttonStyle(.plain)
    }
}
