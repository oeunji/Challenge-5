//
//  VisionSimView.swift
//  Is This Red?
//
//  Created by 이은지 on 2/23/26.
//

import SwiftUI
import PencilKit

struct VisionSimView: View {

	private enum Metric {
		static let spacing: CGFloat = 16
		static let horizontalPadding: CGFloat = 16
		static let emptyDrawingSide: CGFloat = 1024
		static let drawingPadding: CGFloat = 24
	}

	let canvasView: PKCanvasView
	var onFinish: (() -> Void)?

	@Environment(\.dismiss) private var dismiss
	@State private var selectedMode: VisionMode = .protanopia
	@State private var normalImage = UIImage()
	@State private var simulatedImage = UIImage()

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
					preview(title: "Normal", image: normalImage, side: max(0, available / 2))
					preview(
						title: selectedMode.rawValue,
						image: simulatedImage,
						side: max(0, available / 2)
					)
				}
				.padding(.horizontal, Metric.horizontalPadding)
			}

			Spacer()

			Button("Finish Your Experience") {
				dismiss()
				DispatchQueue.main.async {
					onFinish?()
				}
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

	private func preview(title: String, image: UIImage, side: CGFloat) -> some View {
		VStack {
			Text(title)
				.font(.caption)
			Image(uiImage: image)
				.resizable()
				.scaledToFit()
				.frame(width: side, height: side)
				.border(Color.gray.opacity(0.3))
		}
	}

	/// 그림이 비어 있으면 정사각형 기본 영역을, 아니면 여백을 둔 그림 영역을 렌더링합니다.
	private var drawingRect: CGRect {
		let bounds = canvasView.drawing.bounds
		guard !bounds.isEmpty else {
			return CGRect(
				x: 0,
				y: 0,
				width: Metric.emptyDrawingSide,
				height: Metric.emptyDrawingSide
			)
		}
		return bounds.insetBy(dx: -Metric.drawingPadding, dy: -Metric.drawingPadding)
	}

	private func updateImages() {
		normalImage = VisionSimulator.render(drawing: canvasView.drawing, rect: drawingRect)
		simulatedImage = VisionSimulator.simulate(image: normalImage, mode: selectedMode)
	}
}
