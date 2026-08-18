//
//  DrawingView.swift
//  Is This Red?
//
//  Created by 이은지 on 2/13/26.
//

import SwiftUI
import PencilKit

struct DrawingView: UIViewRepresentable {

	// MARK: - Properties

	let canvasView: PKCanvasView
	var onDrawingChange: (() -> Void)?

	// MARK: - UIViewRepresentable

	func makeCoordinator() -> DrawingViewDelegate {
		DrawingViewDelegate(onDrawingChange: onDrawingChange)
	}

	func makeUIView(context: Context) -> PKCanvasView {
		canvasView.drawingPolicy = .anyInput
		canvasView.backgroundColor = .white
		canvasView.delegate = context.coordinator
		return canvasView
	}

	func updateUIView(_ uiView: PKCanvasView, context: Context) {}
}
