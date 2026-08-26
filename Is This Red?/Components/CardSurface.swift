//
//  CardSurface.swift
//  Is This Red?
//

import SwiftUI

struct CardSurface: ViewModifier {

	// MARK: - Constants

	private enum Metric {
		static let borderWidth: CGFloat = 1.5
	}

	// MARK: - Properties

	let cornerRadius: CGFloat

	// MARK: - Body

	func body(content: Content) -> some View {
		let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)

		return content
			.background(Color("Surface"), in: shape)
			.overlay(shape.strokeBorder(AppColor.cardBorder, lineWidth: Metric.borderWidth))
	}
}

// MARK: - View + CardSurface

extension View {

	func cardSurface(cornerRadius: CGFloat) -> some View {
		modifier(CardSurface(cornerRadius: cornerRadius))
	}
}
