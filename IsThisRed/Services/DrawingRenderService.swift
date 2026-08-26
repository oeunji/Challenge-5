//
//  DrawingRenderService.swift
//  Is This Red?
//

import PencilKit

/// PencilKit 전담. 그림을 이미지로 굽는 일만 합니다.
enum DrawingRenderService {

	// MARK: - Methods

	static func render(drawing: PKDrawing, rect: CGRect) -> UIImage {
		drawing.image(from: rect, scale: 1)
	}
}
