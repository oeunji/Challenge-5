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
			experienceStack
		}
	}
}

// MARK: - Subviews

extension RootView {
    
    private var experienceStack: some View {
        @Bindable var coordinator = coordinator

        return NavigationStack(path: $coordinator.path) {
            ExperienceModeSelectView()
                .navigationDestination(for: Route.self) { route in
                    destination(for: route)
                }
        }
    }

    @ViewBuilder
    private func destination(for route: Route) -> some View {
        switch route {
        case .create:
            CreateView()
        case .visionSim:
            VisionSimView()
        case .visionModeSelect:
            VisionModeSelectView()
        case .colorblindDraw(let mode):
            ColorblindDrawView(selectedMode: mode)
        }
    }
}
