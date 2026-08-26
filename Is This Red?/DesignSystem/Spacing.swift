//
//  Spacing.swift
//  Is This Red?
//
//  Created by 이은지 on 8/24/26.
//

import CoreGraphics

/// 8pt 그리드 기반 스페이싱 스케일. 패딩, 마진, 갭에 일관되게 적용됩니다.
///
/// Figma `Token Documentation — Spacing`의 `spacing/*` 토큰과 1:1로 대응합니다.
enum Spacing {
	/// `spacing/4` — 4pt
	static let x4: CGFloat = 4
	/// `spacing/8` — 8pt
	static let x8: CGFloat = 8
	/// `spacing/12` — 12pt
	static let x12: CGFloat = 12
	/// `spacing/16` — 16pt
	static let x16: CGFloat = 16
	/// `spacing/24` — 24pt
	static let x24: CGFloat = 24
	/// `spacing/32` — 32pt
	static let x32: CGFloat = 32
	/// `spacing/48` — 48pt
	static let x48: CGFloat = 48
	/// `spacing/64` — 64pt
	static let x64: CGFloat = 64
}
