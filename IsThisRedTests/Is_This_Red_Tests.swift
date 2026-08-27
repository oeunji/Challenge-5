//
//  Is_This_Red_Tests.swift
//  Is This Red?Tests
//
//  Created by 이은지 on 8/12/26.
//

import Testing
import SwiftUI
@testable import IsThisRed

struct Is_This_Red_Tests {

	// MARK: - Properties

	private let pureRed = Color(red: 1, green: 0, blue: 0)

	// MARK: - Tests

	@Test func normalModeKeepsColorUnchanged() {
		#expect(ColorVisionService.simulate(color: pureRed, mode: .normal) == pureRed)
	}

	/// 전색맹은 휘도 하나로 뭉개지므로 세 채널이 같아야 하고, 순수 빨강이면 0.299가 됩니다.
	@Test func achromatopsiaFlattensChannelsToLuminance() {
		let (red, green, blue) = components(of: .achromatopsia)

		#expect(abs(red - green) < 0.001)
		#expect(abs(green - blue) < 0.001)
		#expect(abs(red - 0.299) < 0.001)
	}

	/// 적색맹에서 순수 빨강은 어두워지지만 회색이 되지는 않습니다.
	@Test func protanopiaDarkensRedWithoutFlattening() {
		let (red, green, blue) = components(of: .protanopia)

		#expect(abs(red - 0.567) < 0.001)
		#expect(abs(green - 0.558) < 0.001)
		#expect(blue == 0)
	}

	// MARK: - Helpers

	private func components(of mode: VisionMode) -> (Double, Double, Double) {
		var (red, green, blue, alpha): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
		UIColor(ColorVisionService.simulate(color: pureRed, mode: mode))
			.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
		return (Double(red), Double(green), Double(blue))
	}
}
