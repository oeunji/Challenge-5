//
//  DrawingTool.swift
//  Is This Red?
//
//  Created by 이은지 on 8/20/26.
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
