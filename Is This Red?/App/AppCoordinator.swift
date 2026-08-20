//
//  AppCoordinator.swift
//  Is This Red?
//
//  Created by 이은지 on 8/20/26.
//

import Observation

enum Route: Hashable {
	case create
	case visionSim
	case visionModeSelect
	case colorblindDraw(VisionMode)
}

@Observable
final class AppCoordinator {

	// MARK: - Types

	enum Stage {
		case onboardingFirst
		case onboardingSecond
		case experience
	}

	// MARK: - Properties

	private(set) var stage: Stage = .onboardingFirst
	var path: [Route] = []

	// MARK: - Methods

	func onboardingDidFinish() {
		switch stage {
		case .onboardingFirst:
			stage = .onboardingSecond
		case .onboardingSecond:
			stage = .experience
		case .experience:
			break
		}
	}

	func push(_ route: Route) {
		path.append(route)
	}

	func popToRoot() {
		path.removeAll()
	}
}
