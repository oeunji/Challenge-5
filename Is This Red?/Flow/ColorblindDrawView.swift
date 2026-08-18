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
		static let fallbackCanvasSide: CGFloat = 1024
	}

	// MARK: - Types

	enum RevealSelection: String, CaseIterable {
		case simulated = "Simulated"
		case normal = "Normal"
	}

	// MARK: - Properties

	private static let missions: [String] = [
		"Draw a ripe apple.",
		"Design a traffic light.",
		"Draw a rainbow.",
		"Create a red and green warning sign.",
		"Draw a watermelon.",
		"Design a health bar (red to green)."
	]

	let selectedMode: VisionMode

	@State private var canvasView = PKCanvasView()
	@State private var tool = DrawingTool()
	@State private var palette = [Color.black] + DrawingTool.defaultPalette.dropFirst().shuffled()
	@State private var missionText = Self.missions.randomElement() ?? ""
	@State private var normalImage: UIImage?
	@State private var simulatedImage: UIImage?
	@State private var renderSize: CGSize = .zero
	@State private var isRevealActive = false
	@State private var revealSelection: RevealSelection = .simulated
	@State private var showRevealAlert = false

	// MARK: - Body

	var body: some View {
		VStack(spacing: Metric.stackSpacing) {
			DrawingToolbar(
				tool: $tool,
				canvasView: canvasView,
				palette: palette,
				simulationMode: effectiveMode
			)
			.padding(.horizontal)

			canvasLayers

			revealButton
		}
		.navigationTitle("Mode: \(selectedMode.rawValue)")
		.navigationBarTitleDisplayMode(.inline)
		.alert("Reveal Reality?", isPresented: $showRevealAlert) {
			Button("Cancel", role: .cancel) {}
			Button("Reveal") {
				withAnimation(.easeInOut(duration: 0.2)) {
					isRevealActive = true
					revealSelection = .normal
				}
				renderAndSimulate()
			}
		} message: {
			Text("This will show the normal view so you can compare it with the simulated vision.")
		}
	}

	// MARK: - Subviews

	private var canvasLayers: some View {
		GeometryReader { geo in
			ZStack(alignment: .topLeading) {
				if let displayedImage {
					Image(uiImage: displayedImage)
						.resizable()
						.scaledToFit()
						.frame(maxWidth: .infinity, maxHeight: .infinity)
						.allowsHitTesting(false)
				}

				DrawingView(canvasView: canvasView) {
					renderAndSimulate()
				}
				.opacity(Metric.canvasOpacity)
				.ignoresSafeArea(edges: .bottom)

				missionCard
					.padding(Metric.overlayPadding)
					.allowsHitTesting(false)

				if isRevealActive {
					revealPicker
						.padding(Metric.overlayPadding)
						.transition(.opacity)
						.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
				}
			}
			.onAppear {
				renderSize = geo.size
				renderAndSimulate()
			}
			.onChange(of: geo.size) { _, newSize in
				renderSize = newSize
			}
		}
	}

	private var missionCard: some View {
		VStack(alignment: .leading, spacing: 8) {
			Text("Mission")
				.font(.caption)
				.foregroundStyle(.secondary)

			Text(missionText)
				.font(.system(size: 14, weight: .semibold, design: .rounded))
				.foregroundStyle(.primary)
		}
		.padding(Metric.cardPadding)
		.background(.ultraThinMaterial)
		.cornerRadius(Metric.cardPadding)
		.shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 4)
	}

	private var revealPicker: some View {
		Picker("Reveal", selection: $revealSelection) {
			ForEach(RevealSelection.allCases, id: \.self) { option in
				Text(option.rawValue).tag(option)
			}
		}
		.pickerStyle(.segmented)
		.frame(width: 220)
	}

	private var revealButton: some View {
		Button {
			showRevealAlert = true
		} label: {
			Text("Reveal Reality")
				.font(.system(size: 16, weight: .semibold, design: .rounded))
				.foregroundColor(isRevealActive ? .white : .black)
				.frame(maxWidth: .infinity, minHeight: 44)
		}
		.buttonStyle(.bordered)
		.disabled(isRevealActive)
		.padding(.horizontal)
		.padding(.bottom, 16)
	}

	// MARK: - Computed Values

	/// Reveal 중 "Normal"을 고르면 실제 색을, 그 외에는 선택한 색각 모드를 적용합니다.
	private var effectiveMode: VisionMode {
		isShowingNormal ? .normal : selectedMode
	}

	private var displayedImage: UIImage? {
		isShowingNormal ? normalImage : simulatedImage
	}

	private var isShowingNormal: Bool {
		isRevealActive && revealSelection == .normal
	}

	// MARK: - Methods

	private func renderAndSimulate() {
		let size = renderSize == .zero
			? CGSize(width: Metric.fallbackCanvasSide, height: Metric.fallbackCanvasSide)
			: renderSize
		let rect = CGRect(origin: .zero, size: size)
		normalImage = VisionSimulator.render(drawing: canvasView.drawing, rect: rect)
		simulatedImage = VisionSimulator.simulate(image: normalImage ?? UIImage(), mode: selectedMode)
	}
}
