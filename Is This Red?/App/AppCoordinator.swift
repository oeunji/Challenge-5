//
//  AppCoordinator.swift
//  Is This Red?
//

import Observation

/// 앱이 이동할 수 있는 화면. `NavigationStack`의 경로 원소로 쓰입니다.
enum Route: Hashable {
	case create
	case visionSim
	case visionModeSelect
	case colorblindDraw(VisionMode)
}

/// 온보딩 단계와 push 경로를 소유합니다. 뷰는 목적지를 모르고 이 객체에 요청만 합니다.
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

	/// 온보딩 한 단계를 끝냅니다. 이미 체험 단계면 아무 일도 하지 않습니다.
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
