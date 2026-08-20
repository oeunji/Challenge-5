//
//  DrawingToolbar.swift
//  Is This Red?
//

import SwiftUI
import PencilKit

/// 두 그리기 화면이 공유하는 도구 상태. 값이 바뀌면 `apply(to:)`로 캔버스에 반영합니다.
struct DrawingTool: Equatable {

	// MARK: - Types

	enum Kind: CaseIterable {
		case pencil, pen, brush, eraser, lasso

		var systemImage: String {
			switch self {
			case .pencil: return "pencil"
			case .pen: return "pencil.tip"
			case .brush: return "paintbrush"
			case .eraser: return "eraser"
			case .lasso: return "lasso"
			}
		}

		var widthRange: ClosedRange<Double>? {
			switch self {
			case .pencil: return 2...10
			case .pen: return 2...12
			case .brush: return 4...18
			case .eraser, .lasso: return nil
			}
		}

		var isInking: Bool {
			widthRange != nil
		}
	}

	// MARK: - Constants

	static let defaultPalette: [Color] = [.black, .red, .yellow, .green, .blue, .purple]

	// MARK: - Properties

	var kind: Kind = .pen
	var color: Color = .black
	private var widths: [Kind: Double] = [.pencil: 4, .pen: 5, .brush: 7]

	var width: Double {
		get { widths[kind] ?? 5 }
		set { widths[kind] = newValue }
	}

	// MARK: - Methods

	func apply(to canvasView: PKCanvasView) {
		switch kind {
		case .pencil:
			canvasView.tool = PKInkingTool(.pencil, color: UIColor(color), width: width)
		case .pen:
			canvasView.tool = PKInkingTool(.pen, color: UIColor(color), width: width)
		case .brush:
			canvasView.tool = PKInkingTool(.marker, color: UIColor(color), width: width)
		case .eraser:
			canvasView.tool = PKEraserTool(.vector)
		case .lasso:
			canvasView.tool = PKLassoTool()
		}
	}

	/// 잉크 도구가 아닐 때 색을 고르면 펜으로 되돌립니다.
	mutating func select(_ color: Color) {
		self.color = color
		if !kind.isInking {
			kind = .pen
		}
	}
}

struct DrawingToolbar: View {

	// MARK: - Constants

	private enum Metric {
		static let itemSpacing: CGFloat = 15
		static let dividerHeight: CGFloat = 20
		static let sliderWidth: CGFloat = 110
		static let swatchSize: CGFloat = 20
		static let selectedSwatchSize: CGFloat = 24
	}

	// MARK: - Properties

	@Binding var tool: DrawingTool
	let canvasView: PKCanvasView
	var palette: [Color] = DrawingTool.defaultPalette
	/// 팔레트 스와치를 이 모드로 왜곡해 보여줍니다. `.normal`이면 실제 색 그대로.
	var simulationMode: VisionMode = .normal

	// MARK: - Body

	var body: some View {
		HStack(spacing: Metric.itemSpacing) {
			Button {
				canvasView.undoManager?.undo()
			} label: {
				Image(systemName: "arrow.uturn.backward")
			}
			Button {
				canvasView.undoManager?.redo()
			} label: {
				Image(systemName: "arrow.uturn.forward")
			}

			divider

			ForEach(DrawingTool.Kind.allCases, id: \.self) { kind in
				Button {
					tool.kind = kind
				} label: {
					Image(systemName: kind.systemImage)
						.foregroundColor(tool.kind == kind ? .blue : .primary)
				}
			}

			divider

			ForEach(palette, id: \.self) { color in
				swatch(color)
			}

			divider

			Slider(value: $tool.width, in: tool.kind.widthRange ?? 2...12, step: 1)
				.tint(.black)
				.frame(width: Metric.sliderWidth)
				.opacity(tool.kind.isInking ? 1 : 0.2)
				.allowsHitTesting(tool.kind.isInking)
		}
		.foregroundColor(.black)
		.padding(8)
		.background(Color(.systemGray6))
		.cornerRadius(10)
		.onAppear { tool.apply(to: canvasView) }
		.onChange(of: tool) { tool.apply(to: canvasView) }
	}

	// MARK: - Subviews

	private var divider: some View {
		Divider().frame(height: Metric.dividerHeight)
	}

	private func swatch(_ color: Color) -> some View {
		let isSelected = tool.color == color
		let size = isSelected ? Metric.selectedSwatchSize : Metric.swatchSize

		return Button {
			tool.select(color)
		} label: {
			Circle()
				.fill(ColorVisionService.simulate(color: color, mode: simulationMode))
				.frame(width: size, height: size)
				.overlay(
					Circle()
						.stroke(.white.opacity(isSelected ? 0.95 : 0), lineWidth: 2)
				)
				.shadow(color: .black.opacity(isSelected ? 0.35 : 0), radius: 6, x: 0, y: 2)
				.animation(.easeInOut(duration: 0.12), value: isSelected)
		}
		.buttonStyle(.plain)
	}
}
