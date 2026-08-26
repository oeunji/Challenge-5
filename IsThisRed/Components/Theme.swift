//
//  Theme.swift
//  Is This Red?
//

import SwiftUI

/// 온보딩 이후 화면들이 공유하는 색상.
enum AppColor {
	static let title = Color("OnSurface")
	static let subtitle = Color("OnSurfaceVariant")
	static let cardBorder = Color("Outline")
	static let grid = Color("SurfaceVariant")
}

/// 흰 배경 위에 일정 간격의 모눈을 그립니다.
struct GridBackground: View {

	// MARK: - Constants

	private enum Metric {
		static let spacing: CGFloat = Spacing.x32
		static let lineWidth: CGFloat = 1
	}

	// MARK: - Body

	var body: some View {
		Color("Surface")
			.ignoresSafeArea()
			.overlay(
				GeometryReader { proxy in
					Path { path in
						for x in stride(from: 0, through: proxy.size.width, by: Metric.spacing) {
							path.move(to: CGPoint(x: x, y: 0))
							path.addLine(to: CGPoint(x: x, y: proxy.size.height))
						}
						for y in stride(from: 0, through: proxy.size.height, by: Metric.spacing) {
							path.move(to: CGPoint(x: 0, y: y))
							path.addLine(to: CGPoint(x: proxy.size.width, y: y))
						}
					}
					.stroke(AppColor.grid, lineWidth: Metric.lineWidth)
				}
			)
	}
}
