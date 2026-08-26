//
//  Radius.swift
//  Is This Red?
//
//  Created by 이은지 on 8/26/26.
//

import CoreGraphics

/// 코너 라운딩 스케일.
///
/// Figma `Token Documentation — Border Radius`의 `radius/*` 토큰에 대응합니다.
/// 단계는 컴포넌트 크기 계층에 맞춥니다 — 작은 크롬 / 일반 / 큰 면.
///
/// 도형은 항상 `RoundedRectangle(cornerRadius:style: .continuous)`로 그립니다.
/// iOS의 둥근 모서리는 원호가 아니라 연속 곡선이라, 기본값을 쓰면 각져 보입니다.
///
/// Figma의 `radius/full`은 여기에 없습니다. 알약 모양은 `Capsule()`로 그리는 게 정확하고,
/// 큰 수를 상수로 두면 그걸 `RoundedRectangle`에 넘기는 잘못된 사용을 부릅니다.
enum Radius {
	/// `radius/standard` — 8pt. 툴바, 칩, 인풋 같은 작은 크롬.
	static let standard: CGFloat = 8
	/// `radius/medium` — 16pt. 버튼과 일반 카드.
	static let medium: CGFloat = 16
	/// `radius/large` — 24pt. 모달, 대형 카드 등 큰 면.
	static let large: CGFloat = 24
}
