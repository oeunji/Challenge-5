//
//  ColorblindDrawViewModelTests.swift
//  Is This Red?Tests
//

import Testing
import SwiftUI
@testable import IsThisRed

struct ColorblindDrawViewModelTests {

	// MARK: - Tests

	@Test("기본 상태에서는 선택한 색각 모드를 쓴다")
	func defaultUsesSelectedMode() {
		let viewModel = ColorblindDrawViewModel(selectedMode: .protanopia)

		#expect(viewModel.effectiveMode == .protanopia)
		#expect(viewModel.isShowingNormal == false)
	}

	@Test("reveal을 확정하면 Normal 비교로 전환된다")
	func revealSwitchesToNormal() {
		let viewModel = ColorblindDrawViewModel(selectedMode: .deuteranopia)

		viewModel.revealDidConfirm()

		#expect(viewModel.isRevealActive)
		#expect(viewModel.revealSelection == .normal)
		#expect(viewModel.effectiveMode == .normal)
	}

	@Test("reveal 중 Simulated로 되돌리면 다시 색각 모드를 쓴다")
	func simulatedSelectionRestoresMode() {
		let viewModel = ColorblindDrawViewModel(selectedMode: .tritanopia)
		viewModel.revealDidConfirm()

		viewModel.revealSelection = .simulated

		#expect(viewModel.effectiveMode == .tritanopia)
		#expect(viewModel.isShowingNormal == false)
	}

	/// reveal 전에는 선택값이 무엇이든 무시되어야 한다.
	@Test("reveal 전에 Normal이 선택돼 있어도 색각 모드를 유지한다")
	func normalSelectionIgnoredBeforeReveal() {
		let viewModel = ColorblindDrawViewModel(selectedMode: .protanopia)

		viewModel.revealSelection = .normal

		#expect(viewModel.effectiveMode == .protanopia)
		#expect(viewModel.isShowingNormal == false)
	}

	@Test("팔레트는 검정으로 시작하고 색을 빠뜨리지 않는다")
	func paletteStartsWithBlackAndKeepsEveryColor() {
		let viewModel = ColorblindDrawViewModel(selectedMode: .protanopia)

		#expect(viewModel.palette.first == .black)
		#expect(Set(viewModel.palette) == Set(DrawingTool.defaultPalette))
	}
}
