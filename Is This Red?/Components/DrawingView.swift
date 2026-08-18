//
//  DrawingView.swift
//  Is This Red?
//
//  Created by 이은지 on 2/13/26.
//

import SwiftUI
import PencilKit

struct DrawingView: UIViewRepresentable {

	let canvasView: PKCanvasView
	var onDrawingChange: (() -> Void)?

	func makeCoordinator() -> Coordinator {
		Coordinator(onDrawingChange: onDrawingChange)
	}

	func makeUIView(context: Context) -> PKCanvasView {
		canvasView.drawingPolicy = .anyInput
		canvasView.backgroundColor = .white
		canvasView.delegate = context.coordinator
		return canvasView
	}

	func updateUIView(_ uiView: PKCanvasView, context: Context) {}

	final class Coordinator: NSObject {
		private let onDrawingChange: (() -> Void)?

		init(onDrawingChange: (() -> Void)?) {
			self.onDrawingChange = onDrawingChange
		}
	}
}

// MARK: - PKCanvasViewDelegate

extension DrawingView.Coordinator: PKCanvasViewDelegate {

	func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
		onDrawingChange?()
	}
}
