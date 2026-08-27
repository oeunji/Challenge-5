//
//  Typography.swift
//  Is This Red?
//
//  Created by 이은지 on 8/24/26.
//

import SwiftUI

/// 애플 Dynamic Type 기반 타입 스케일.
///
/// Figma `Token Documentation — Typography`의 스타일 이름과 1:1로 대응합니다.
/// 값은 전부 시스템 텍스트 스타일이므로 사용자 글자 크기 설정에 따라 자동으로 확대·축소됩니다.
/// 주석의 크기·자간은 iOS Large(기본) 기준 참고값입니다.
enum Typography {
	/// Large Title — SF Pro Regular · 34/41pt · LS +0.40
	static let largeTitle = Font.largeTitle
	/// Title 1 — SF Pro Regular · 28/34pt · LS +0.36
	static let title1 = Font.title
	/// Title 2 — SF Pro Regular · 22/28pt · LS +0.35
	static let title2 = Font.title2
	/// Title 3 — SF Pro Regular · 20/25pt · LS +0.38
	static let title3 = Font.title3
	/// Headline — SF Pro Semibold · 17/22pt · LS -0.43
	static let headline = Font.headline
	/// Body — SF Pro Regular · 17/22pt · LS -0.43
	static let body = Font.body
	/// Callout — SF Pro Regular · 16/21pt · LS -0.31
	static let callout = Font.callout
	/// Subheadline — SF Pro Regular · 15/20pt · LS -0.23
	static let subheadline = Font.subheadline
	/// Footnote — SF Pro Regular · 13/18pt · LS -0.08
	static let footnote = Font.footnote
	/// Caption 1 — SF Pro Regular · 12/16pt · LS 0
	static let caption1 = Font.caption
	/// Caption 2 — SF Pro Regular · 11/13pt · LS +0.06
	static let caption2 = Font.caption2
}
