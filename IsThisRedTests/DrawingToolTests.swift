//
//  DrawingToolTests.swift
//  Is This Red?Tests
//

import Testing
import SwiftUI
@testable import IsThisRed

struct DrawingToolTests {

	// MARK: - Tests

	/// 슬라이더는 하나뿐이지만 도구마다 굵기가 따로 기억되어야 한다.
	@Test("도구를 바꿔도 각 도구의 굵기는 따로 기억된다")
	func widthIsRememberedPerKind() {
		var tool = DrawingTool()
		tool.kind = .pen
		tool.width = 11

		tool.kind = .brush
		#expect(tool.width == 7, "펜의 굵기가 붓에 새어 나왔다")

		tool.width = 18
		tool.kind = .pen
		#expect(tool.width == 11, "펜으로 돌아왔을 때 굵기를 잊었다")
	}

	/// 지우개나 올가미 상태에서 색을 고르는 것은 "그리고 싶다"는 뜻이다.
	@Test("잉킹 도구가 아닐 때 색을 고르면 펜으로 돌아온다")
	func selectingColorLeavesNonInkingTool() {
		var tool = DrawingTool()
		tool.kind = .eraser

		tool.select(.red)

		#expect(tool.kind == .pen)
		#expect(tool.color == .red)
	}

	@Test("잉킹 도구일 때 색을 고르면 도구는 그대로 둔다")
	func selectingColorKeepsInkingTool() {
		var tool = DrawingTool()
		tool.kind = .brush

		tool.select(.blue)

		#expect(tool.kind == .brush)
		#expect(tool.color == .blue)
	}
}
