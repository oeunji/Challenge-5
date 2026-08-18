//
//  OnboardingSecondView.swift
//  Is This Red?
//
//  Created by 이은지 on 2/23/26.
//

import SwiftUI

struct OnboardingSecondView: View {

	// MARK: - Constants

	private static let lines: [String] = [
		"Were Those Real Red?",
		"They were all Red.",
		"The color you see isn’t the color everyone sees.",
		"Start Experience"
	]

	// MARK: - Properties

	@Binding var didFinish: Bool
	@State private var revealedCount = 1

	// MARK: - Body

	var body: some View {
		ZStack {
			Color.black
				.ignoresSafeArea()

			VStack(spacing: 18) {
				ForEach(0..<revealedCount, id: \.self) { index in
					let isLast = index == Self.lines.count - 1
					Text(Self.lines[index])
						.font(.system(size: isLast ? 24 : 22, weight: isLast ? .bold : .semibold))
						.foregroundStyle(.white)
						.transition(.opacity)
				}
			}
			.padding(.horizontal, 28)
		}
		.contentShape(Rectangle())
		.onTapGesture {
			viewDidTap()
		}
	}

	// MARK: - Actions

	/// 모든 문장이 드러날 때까지는 한 줄씩 공개하고, 그 다음 탭에서 온보딩을 끝냅니다.
	private func viewDidTap() {
		withAnimation(.easeInOut(duration: revealedCount < Self.lines.count ? 0.25 : 0.35)) {
			if revealedCount < Self.lines.count {
				revealedCount += 1
			} else {
				didFinish = true
			}
		}
	}
}
