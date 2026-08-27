//
//  DrawingViewDelegate.swift
//  Is This Red?
//
//  Created by 이은지 on 8/18/26.
//

import PencilKit

final class DrawingViewDelegate: NSObject {

	// MARK: - Properties

	private let onDrawingChange: (() -> Void)?

	// MARK: - Initialize

	init(onDrawingChange: (() -> Void)?) {
		self.onDrawingChange = onDrawingChange
	}
}

// MARK: - PKCanvasViewDelegate

extension DrawingViewDelegate: PKCanvasViewDelegate {

	func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
		onDrawingChange?()
	}
}
