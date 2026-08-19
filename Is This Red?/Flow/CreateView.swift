//
//  CreateView.swift
//  Is This Red?
//
//  Created by 이은지 on 2/25/26.
//

import SwiftUI
import PencilKit

struct CreateView: View {

	// MARK: - Properties

	@Environment(AppCoordinator.self) private var coordinator
	@Environment(DrawingSession.self) private var session
	@State private var tool = DrawingTool()

	// MARK: - Body

	var body: some View {
		DrawingView(canvasView: session.canvas)
			.ignoresSafeArea(edges: .bottom)
			.safeAreaInset(edge: .bottom) {
				Text("Feel free to draw, and tap the Next button when you’re done.")
					.font(.footnote)
					.foregroundStyle(.secondary)
					.multilineTextAlignment(.center)
					.frame(maxWidth: .infinity)
					.padding(.horizontal, 20)
					.padding(.vertical, 12)
					.background(.thinMaterial)
			}
			.toolbar {
				ToolbarItem(placement: .topBarTrailing) {
					nextButton
				}
				ToolbarItem(placement: .principal) {
					DrawingToolbar(tool: $tool, canvasView: session.canvas)
				}
			}
	}

	// MARK: - Subviews

	private var nextButton: some View {
		Button {
			coordinator.push(.visionSim)
		} label: {
			Text("Next")
				.font(.system(size: 16, weight: .semibold, design: .rounded))
				.foregroundColor(.black)
		}
		.buttonStyle(.bordered)
		.tint(.clear)
		.padding(.horizontal, 12)
	}
}
