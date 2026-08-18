//
//  Theme.swift
//  Is This Red?
//

import SwiftUI

/// 온보딩 이후 화면들이 공유하는 색상.
enum AppColor {
	static let title = Color(red: 0.1647, green: 0.0275, blue: 0.0275)
	static let subtitle = Color(red: 0.4275, green: 0.2706, blue: 0.2706)
	static let cardBorder = Color(red: 0.8471, green: 0.8157, blue: 0.8157)
	static let grid = Color.gray.opacity(0.18)
}

/// 흰 배경 위에 일정 간격의 모눈을 그립니다.
struct GridBackground: View {

	// MARK: - Constants

	private enum Metric {
		static let spacing: CGFloat = 30
		static let lineWidth: CGFloat = 1
	}

	// MARK: - Body

	var body: some View {
		Color.white
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
