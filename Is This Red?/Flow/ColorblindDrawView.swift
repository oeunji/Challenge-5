//
//  ColorblindDrawView.swift
//  Is This Red?
//
//  Created by 이은지 on 2/23/26.
//

import SwiftUI
import PencilKit

struct ColorblindDrawView: View {

	// MARK: - Constants

	private enum Metric {
		static let stackSpacing: CGFloat = 12
		static let overlayPadding: CGFloat = 14
		static let cardPadding: CGFloat = 12
		/// 캔버스는 거의 투명하게 두고, 그 아래 시뮬레이션된 이미지를 대신 보여줍니다.
		static let canvasOpacity: Double = 0.02
		static let pickerWidth: CGFloat = 220
	}

	// MARK: - Properties

	@State private var viewModel: ColorblindDrawViewModel
	@State private var canvasView = PKCanvasView()
	@State private var tool = DrawingTool()

	// MARK: - Initialize

	init(selectedMode: VisionMode) {
		_viewModel = State(initialValue: ColorblindDrawViewModel(selectedMode: selectedMode))
	}

	// MARK: - Body

	var body: some View {
		@Bindable var viewModel = viewModel

		return VStack(spacing: Metric.stackSpacing) {
			DrawingToolbar(
				tool: $tool,
				canvasView: canvasView,
				palette: viewModel.palette,
				simulationMode: viewModel.effectiveMode
			)
			.padding(.horizontal)

			canvasLayers

			revealButton
		}
		.navigationTitle("Mode: \(viewModel.selectedMode.rawValue)")
		.navigationBarTitleDisplayMode(.inline)
		.alert("Reveal Reality?", isPresented: $viewModel.showRevealAlert) {
			Button("Cancel", role: .cancel) {}
			Button("Reveal") {
				withAnimation(.easeInOut(duration: 0.2)) {
					viewModel.revealDidConfirm()
				}
				viewModel.render(canvasView.drawing)
			}
		} message: {
			Text("This will show the normal view so you can compare it with the simulated vision.")
		}
	}

	// MARK: - Subviews

	private var canvasLayers: some View {
		GeometryReader { geo in
			ZStack(alignment: .topLeading) {
				if let displayedImage = viewModel.displayedImage {
					Image(uiImage: displayedImage)
						.resizable()
						.scaledToFit()
						.frame(maxWidth: .infinity, maxHeight: .infinity)
						.allowsHitTesting(false)
				}

				DrawingView(canvasView: canvasView) {
					viewModel.render(canvasView.drawing)
				}
				.opacity(Metric.canvasOpacity)
				.ignoresSafeArea(edges: .bottom)

				missionCard
					.padding(Metric.overlayPadding)
					.allowsHitTesting(false)

				if viewModel.isRevealActive {
					revealPicker
						.padding(Metric.overlayPadding)
						.transition(.opacity)
						.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
				}
			}
			.onAppear {
				viewModel.renderSize = geo.size
				viewModel.render(canvasView.drawing)
			}
			.onChange(of: geo.size) { _, newSize in
				viewModel.renderSize = newSize
			}
		}
	}

	private var missionCard: some View {
		VStack(alignment: .leading, spacing: 8) {
			Text("Mission")
				.font(.caption)
				.foregroundStyle(.secondary)

			Text(viewModel.missionText)
				.font(.system(size: 14, weight: .semibold, design: .rounded))
				.foregroundStyle(.primary)
		}
		.padding(Metric.cardPadding)
		.background(.ultraThinMaterial)
		.cornerRadius(Metric.cardPadding)
		.shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 4)
	}

	private var revealPicker: some View {
		@Bindable var viewModel = viewModel

		return Picker("Reveal", selection: $viewModel.revealSelection) {
			ForEach(ColorblindDrawViewModel.RevealSelection.allCases, id: \.self) { option in
				Text(option.rawValue).tag(option)
			}
		}
		.pickerStyle(.segmented)
		.frame(width: Metric.pickerWidth)
	}

	private var revealButton: some View {
		Button {
			viewModel.showRevealAlert = true
		} label: {
			Text("Reveal Reality")
				.font(.system(size: 16, weight: .semibold, design: .rounded))
				.foregroundColor(viewModel.isRevealActive ? .white : .black)
				.frame(maxWidth: .infinity, minHeight: 44)
		}
		.buttonStyle(.bordered)
		.disabled(viewModel.isRevealActive)
		.padding(.horizontal)
		.padding(.bottom, 16)
	}
}
