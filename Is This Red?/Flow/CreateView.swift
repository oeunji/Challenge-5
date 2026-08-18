//
//  CreateView.swift
//  Is This Red?
//
//  Created by 이은지 on 2/25/26.
//

import SwiftUI
import PencilKit

struct CreateView: View {

	@State private var canvasView = PKCanvasView()
	@State private var tool = DrawingTool()
	@Environment(\.dismiss) private var dismiss

	var body: some View {
		DrawingView(canvasView: canvasView)
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
					nextLink
				}
				ToolbarItem(placement: .principal) {
					DrawingToolbar(tool: $tool, canvasView: canvasView)
				}
			}
	}

	private var nextLink: some View {
		NavigationLink {
			VisionSimView(canvasView: canvasView, onFinish: { dismiss() })
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
