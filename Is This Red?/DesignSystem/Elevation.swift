//
//  Elevation.swift
//  Is This Red?
//
//  Created by 이은지 on 8/24/26.
//

import SwiftUI

/// Figma `Token Documentation — Effects`의 Elevation 수치.
///
/// Figma의 blur는 SwiftUI `radius`의 두 배 기준이라 절반으로 환산했습니다.
private enum Token {

	enum Deep {
		static let shadow = Color.black.opacity(0.15)
		static let radius: CGFloat = 20
		static let y: CGFloat = 10
	}

	enum Glossy {
		static let highlight = Color.white.opacity(0.4)
		static let highlightRadius: CGFloat = 2
		static let highlightY: CGFloat = 2
		static let shadow = Color.black.opacity(0.1)
		static let radius: CGFloat = 4
		static let y: CGFloat = 4
	}

	static let cardRadius: CGFloat = 16
}

// MARK: - View + Elevation

extension View {

	/// `Elevation/Deep` — 카드와 오버레이를 띄우는 넓고 부드러운 그림자.
	///
	/// Figma: Drop Shadow · blur 40 · x:0 y:10 · 검정 15%
	func deepElevation() -> some View {
		shadow(color: Token.Deep.shadow, radius: Token.Deep.radius, x: 0, y: Token.Deep.y)
	}

	/// `Elevation/Glossy` — 채움 위쪽에 하이라이트를 넣어 광택을 주고 얕은 그림자를 더합니다.
	///
	/// 안쪽 그림자는 채움에만 적용할 수 있어 배경 도형까지 이 메서드가 직접 그립니다.
	///
	/// Figma: Inner Shadow · blur 4 · x:0 y:2 · 흰색 40%
	///        Drop Shadow · blur 8 · x:0 y:4 · 검정 10%
	func glossyElevation(
		fill: some ShapeStyle,
		in shape: some Shape = RoundedRectangle(
			cornerRadius: Token.cardRadius,
			style: .continuous
		)
	) -> some View {
		background(
			fill.shadow(
				.inner(
					color: Token.Glossy.highlight,
					radius: Token.Glossy.highlightRadius,
					y: Token.Glossy.highlightY
				)
			),
			in: shape
		)
		.shadow(color: Token.Glossy.shadow, radius: Token.Glossy.radius, x: 0, y: Token.Glossy.y)
	}
}
