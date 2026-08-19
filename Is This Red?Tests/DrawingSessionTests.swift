//
//  DrawingSessionTests.swift
//  Is This Red?Tests
//

import Testing
import PencilKit
@testable import Is_This_Red_

struct DrawingSessionTests {

	// MARK: - Constants

	private let fallback = CGRect(x: 0, y: 0, width: 1024, height: 1024)

	// MARK: - Tests

	@Test("그림이 비어 있으면 fittingDrawing은 기본 정사각형을 쓴다")
	func emptyDrawingFallsBackToSquare() {
		let session = DrawingSession()

		#expect(session.rect(for: .fittingDrawing(padding: 24)) == fallback)
	}

	@Test("그림이 있으면 경계 바깥으로 여백만큼 넓힌다")
	func drawingBoundsGetPadding() {
		let session = DrawingSession()
		session.canvas.drawing = strokedDrawing()
		let bounds = session.canvas.drawing.bounds

		let rect = session.rect(for: .fittingDrawing(padding: 24))

		#expect(rect.width == bounds.width + 48)
		#expect(rect.height == bounds.height + 48)
		#expect(rect.minX == bounds.minX - 24)
	}

	@Test("fixed는 주어진 크기를 원점에 그대로 쓴다")
	func fixedUsesGivenSize() {
		let session = DrawingSession()

		let rect = session.rect(for: .fixed(CGSize(width: 800, height: 600)))

		#expect(rect == CGRect(x: 0, y: 0, width: 800, height: 600))
	}

	@Test("fixed에 0 크기가 오면 기본 정사각형으로 대체한다")
	func fixedZeroFallsBackToSquare() {
		let session = DrawingSession()

		#expect(session.rect(for: .fixed(.zero)) == fallback)
	}

	// MARK: - Helpers

	/// 경계를 가진 그림을 만듭니다. 좌표는 임의이고 값 자체에 의미는 없습니다.
	private func strokedDrawing() -> PKDrawing {
		let points = [CGPoint(x: 100, y: 100), CGPoint(x: 300, y: 250)].map {
			PKStrokePoint(
				location: $0,
				timeOffset: 0,
				size: CGSize(width: 4, height: 4),
				opacity: 1,
				force: 1,
				azimuth: 0,
				altitude: 0
			)
		}
		let path = PKStrokePath(controlPoints: points, creationDate: Date())
		return PKDrawing(strokes: [PKStroke(ink: PKInk(.pen, color: .black), path: path)])
	}
}
