//
//  DrawingToolbar.swift
//  Is This Red?
//

import SwiftUI
import PencilKit

struct DrawingToolbar: View {

	// MARK: - Constants

	private enum Metric {
		static let itemSpacing: CGFloat = Spacing.x16
		static let dividerHeight: CGFloat = 20
		static let sliderWidth: CGFloat = 110
		static let swatchSize: CGFloat = 20
		static let selectedSwatchSize: CGFloat = 24
	}

	// MARK: - Properties

	@Binding var tool: DrawingTool
	let canvasView: PKCanvasView
	var palette: [Color] = DrawingTool.defaultPalette
	var simulationMode: VisionMode = .normal

	// MARK: - Body

	var body: some View {
		HStack(spacing: Metric.itemSpacing) {
			Button {
				canvasView.undoManager?.undo()
			} label: {
				Image(systemName: "arrow.uturn.backward")
			}
			Button {
				canvasView.undoManager?.redo()
			} label: {
				Image(systemName: "arrow.uturn.forward")
			}

			divider

			ForEach(DrawingTool.Kind.allCases, id: \.self) { kind in
				Button {
					tool.kind = kind
				} label: {
					Image(systemName: kind.systemImage)
						.foregroundColor(tool.kind == kind ? .blue : .primary)
				}
			}

			divider

			ForEach(palette, id: \.self) { color in
				swatch(color)
			}

			divider

			Slider(value: $tool.width, in: tool.kind.widthRange ?? 2...12, step: 1)
				.tint(Color("OnSurface"))
				.frame(width: Metric.sliderWidth)
				.opacity(tool.kind.isInking ? 1 : 0.2)
				.allowsHitTesting(tool.kind.isInking)
		}
		.foregroundColor(Color("OnSurface"))
		.padding(Spacing.x8)
		.background(Color("SurfaceVariant"))
		.cornerRadius(10)
		.onAppear { tool.apply(to: canvasView) }
		.onChange(of: tool) { tool.apply(to: canvasView) }
	}
}

// MARK: - Subviews

extension DrawingToolbar {
    
    private var divider: some View {
        Divider().frame(height: Metric.dividerHeight)
    }

    private func swatch(_ color: Color) -> some View {
        let isSelected = tool.color == color
        let size = isSelected ? Metric.selectedSwatchSize : Metric.swatchSize

        return Button {
            tool.select(color)
        } label: {
            Circle()
                .fill(ColorVisionService.simulate(color: color, mode: simulationMode))
                .frame(width: size, height: size)
                .overlay(
                    Circle()
                        .stroke(.white.opacity(isSelected ? 0.95 : 0), lineWidth: 2)
                )
                .shadow(color: .black.opacity(isSelected ? 0.35 : 0), radius: 6, x: 0, y: 2)
                .animation(.easeInOut(duration: 0.12), value: isSelected)
        }
        .buttonStyle(.plain)
    }
}
