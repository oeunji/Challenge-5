//
//  DrawingSession.swift
//  Is This Red?
//

import SwiftUI
import PencilKit

/// 그림 데이터와 그것을 렌더한 결과를 들고 있습니다.
/// 자유 드로잉과 미션 드로잉은 별개의 그림이므로 인스턴스를 따로 만들어 씁니다.
///
/// 캔버스 뷰(`PKCanvasView`)는 여기 두지 않습니다. `UIViewRepresentable`은 자기 `UIView`를
/// 소유해야 하고, 앱 수명을 갖는 객체가 만든 뷰를 넘기면 화면이 다시 만들어질 때 같은 뷰가
/// 재호스팅되어 터치 전달이 깨집니다. 화면 사이를 건너는 것은 값 타입인 `PKDrawing`입니다.
@Observable
final class DrawingSession {

	// MARK: - Types

	/// 렌더 영역을 정하는 방식. 두 그리기 화면이 서로 다르게 요구합니다.
	enum Framing: Equatable {
		/// 그림 경계에 여백을 두른 영역. 그림이 비어 있으면 기본 정사각형.
		case fittingDrawing(padding: CGFloat)
		/// 주어진 크기를 원점에 그대로. 크기가 `.zero`면 기본 정사각형.
		case fixed(CGSize)
	}

	// MARK: - Constants

	private enum Metric {
		static let fallbackSide: CGFloat = 1024
	}

	// MARK: - Properties

	var drawing = PKDrawing()
	private(set) var normalImage: UIImage?
	private(set) var simulatedImage: UIImage?

	// MARK: - Computed Values

	private var fallbackRect: CGRect {
		CGRect(x: 0, y: 0, width: Metric.fallbackSide, height: Metric.fallbackSide)
	}

	// MARK: - Methods

	func rect(for framing: Framing) -> CGRect {
		switch framing {
		case .fittingDrawing(let padding):
			let bounds = drawing.bounds
			guard !bounds.isEmpty else { return fallbackRect }
			return bounds.insetBy(dx: -padding, dy: -padding)
		case .fixed(let size):
			guard size != .zero else { return fallbackRect }
			return CGRect(origin: .zero, size: size)
		}
	}

	func render(_ framing: Framing, mode: VisionMode) {
		let image = DrawingRenderService.render(drawing: drawing, rect: rect(for: framing))
		normalImage = image
		simulatedImage = ColorVisionService.simulate(image: image, mode: mode)
	}
}
