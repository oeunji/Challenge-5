//
//  AppCoordinatorTests.swift
//  Is This Red?Tests
//

import Testing
@testable import Is_This_Red_

struct AppCoordinatorTests {

	// MARK: - Tests

	@Test("온보딩을 두 번 지나면 체험 단계가 된다")
	func onboardingAdvancesThroughStages() {
		let coordinator = AppCoordinator()
		#expect(coordinator.stage == .onboardingFirst)

		coordinator.onboardingDidFinish()
		#expect(coordinator.stage == .onboardingSecond)

		coordinator.onboardingDidFinish()
		#expect(coordinator.stage == .experience)
	}

	@Test("체험 단계에서 더 진행해도 단계가 유지된다")
	func onboardingStopsAtExperience() {
		let coordinator = AppCoordinator()
		coordinator.onboardingDidFinish()
		coordinator.onboardingDidFinish()
		coordinator.onboardingDidFinish()

		#expect(coordinator.stage == .experience)
	}

	@Test("push하면 경로에 목적지가 순서대로 쌓인다")
	func pushAppendsRoutes() {
		let coordinator = AppCoordinator()

		coordinator.push(.visionModeSelect)
		coordinator.push(.colorblindDraw(.protanopia))

		#expect(coordinator.path == [.visionModeSelect, .colorblindDraw(.protanopia)])
	}

	@Test("popToRoot는 경로를 비운다")
	func popToRootClearsPath() {
		let coordinator = AppCoordinator()
		coordinator.push(.create)
		coordinator.push(.visionSim)

		coordinator.popToRoot()

		#expect(coordinator.path.isEmpty)
	}
}
