//
//  RootView.swift
//  Is This Red?
//
//  Created by 이은지 on 2/23/26.
//

import SwiftUI

struct RootView: View {

	// MARK: - Properties

	@Environment(AppCoordinator.self) private var coordinator

	// MARK: - Body

	var body: some View {
		switch coordinator.stage {
		case .onboardingFirst:
			OnboardingFirstView()
		case .onboardingSecond:
			OnboardingSecondView()
		case .experience:
			ExperienceModeSelectView()
		}
	}
}
