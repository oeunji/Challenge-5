//
//  MyApp.swift
//  Is This Red?
//

import SwiftUI

@main
struct MyApp: App {

	// MARK: - Properties

	@State private var coordinator = AppCoordinator()
	@State private var session = DrawingSession()

	// MARK: - Body

	var body: some Scene {
		WindowGroup {
			RootView()
				.preferredColorScheme(.light)
				.environment(coordinator)
				.environment(session)
		}
	}
}
