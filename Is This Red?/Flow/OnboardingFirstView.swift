//
//  OnboardingFirstView.swift
//  Is This Red?
//
//  Created by 이은지 on 2/23/26.
//

import SwiftUI

struct OnboardingFirstView: View {

	// MARK: - Constants

	private enum Metric {
		static let titleLineCount = 5
		static let minimumLineOpacity: Double = 0.35
		static let opacityStep: Double = 0.12
	}

	// MARK: - Properties

	/// 탭할 때마다 순서대로 바뀌는 "빨강"들. 한 바퀴를 돌면 온보딩이 끝납니다.
	private static let backgrounds: [Color] = [
		Color(red: 1.0, green: 0.1843, blue: 0.1843),    // #FF2F2F
		Color(red: 0.7176, green: 0.7451, blue: 0.1569), // #B7BE28
		Color(red: 0.8392, green: 0.8588, blue: 0.1843), // #D6DB2F
		Color(red: 0.7176, green: 0.7451, blue: 0.1569), // #B7BE28
		Color(red: 1.0, green: 0.2275, blue: 0.1961)     // #FF3A32
	]

	@Environment(AppCoordinator.self) private var coordinator
	@State private var backgroundIndex = 0

	// MARK: - Body

	var body: some View {
		ZStack {
			Self.backgrounds[backgroundIndex]
				.ignoresSafeArea()
				.animation(.easeInOut(duration: 0.6), value: backgroundIndex)

			VStack(spacing: 28) {
				Spacer()

				VStack(spacing: 6) {
					ForEach(0..<Metric.titleLineCount, id: \.self) { line in
						Text("Is This Red?")
							.font(.system(size: 32, weight: .semibold))
							.foregroundStyle(.white.opacity(0.9))
							.shadow(radius: 10)
							.opacity(opacity(forLine: line))
					}
					Spacer().frame(height: 8)
					Text("Choose Your Answer")
						.font(.system(size: 14, weight: .semibold))
						.foregroundStyle(.white.opacity(0.85))
				}
				.padding(.horizontal, 24)

				Spacer()

				HStack(spacing: 14) {
					answerButton("Yes")
					answerButton("No")
				}
				.padding(.horizontal, 22)
				.padding(.bottom, 34)
			}
		}
	}

	// MARK: - Methods

	private func opacity(forLine line: Int) -> Double {
		max(Metric.minimumLineOpacity, 0.95 - Double(line) * Metric.opacityStep)
	}

	// MARK: - Actions

	/// Yes/No 어느 쪽을 눌러도 다음 빨강으로 넘어갑니다 — 정답이 없다는 게 요점입니다.
	private func answerDidTap() {
		let nextIndex = (backgroundIndex + 1) % Self.backgrounds.count

		withAnimation(.easeInOut(duration: 0.45)) {
			backgroundIndex = nextIndex
		}

		if nextIndex == 0 {
			withAnimation(.easeInOut(duration: 0.35)) {
				coordinator.onboardingDidFinish()
			}
		}
	}
}

// MARK: - Subviews

extension OnboardingFirstView {

    private func answerButton(_ title: String) -> some View {
        Button {
            answerDidTap()
        } label: {
            Text(title)
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .frame(maxWidth: .infinity, minHeight: 54)
        }
        .buttonStyle(GlassButtonStyle())
    }
}
