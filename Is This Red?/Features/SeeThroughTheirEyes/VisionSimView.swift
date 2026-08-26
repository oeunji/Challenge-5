//
//  VisionSimView.swift
//  Is This Red?
//
//  Created by 이은지 on 2/23/26.
//

import SwiftUI
import PencilKit

struct VisionSimView: View {

	// MARK: - Constants

	private enum Metric {
		static let spacing: CGFloat = Spacing.x16
		static let horizontalPadding: CGFloat = Spacing.x16
		static let drawingPadding: CGFloat = Spacing.x24
	}

	// MARK: - Properties

	@Environment(AppCoordinator.self) private var coordinator
	@Environment(DrawingSession.self) private var session
	@State private var selectedMode: VisionMode = .protanopia

	// MARK: - Body

	var body: some View {
		VStack {
			Picker("Mode", selection: $selectedMode) {
				ForEach(VisionMode.allCases.filter { $0 != .normal }, id: \.self) { mode in
					Text(mode.rawValue).tag(mode)
				}
			}
			.pickerStyle(.segmented)
			.padding()

			Divider()

			GeometryReader { geo in
				let available = geo.size.width - Metric.horizontalPadding * 2 - Metric.spacing
				HStack(spacing: Metric.spacing) {
					preview(title: "Normal", image: session.normalImage, side: max(0, available / 2))
					preview(
						title: selectedMode.rawValue,
						image: session.simulatedImage,
						side: max(0, available / 2)
					)
				}
				.padding(.horizontal, Metric.horizontalPadding)
			}

			Spacer()

			Button("Finish Your Experience") {
				coordinator.popToRoot()
			}
			.padding()
			.foregroundColor(.black)
		}
		.navigationTitle("See Through Their Eyes")
		.navigationBarTitleDisplayMode(.inline)
		.onAppear {
			updateImages()
		}
		.onChange(of: selectedMode) {
			updateImages()
		}
	}

	// MARK: - Methods

	private func updateImages() {
		session.render(.fittingDrawing(padding: Metric.drawingPadding), mode: selectedMode)
	}
}

// MARK: - Subviews

extension VisionSimView {

    private func preview(title: String, image: UIImage?, side: CGFloat) -> some View {
        VStack {
            Text(title)
                .font(Typography.caption1)
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: side, height: side)
                    .border(Color.gray.opacity(0.3))
            }
        }
    }
}
