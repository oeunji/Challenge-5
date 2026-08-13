# Architecture

**Is This Red?** is a SwiftUI app that lets a user experience how color-vision deficiency changes perception. Two experiences share one `VisionMode` enum (`normal`, `protanopia`, `deuteranopia`, `tritanopia`, `achromatopsia`) and one simulation engine.

## Screen flow

`MyApp` (`App/MyApp.swift`) is the `@main` entry point → `RootView` (`App/RootView.swift`) drives a linear state machine via two `@State` bools (`didFinishFirst`, `didFinishOnboarding`), not `NavigationStack`:

```
OnboardingFirstView → OnboardingSecondView → ExperienceModeSelectView
```

From `ExperienceModeSelectView` (`Flow/`), the user picks one of two independent experiences, each its own `NavigationStack` push chain:

- **See Through Their Eyes**: `CreateView` (free-draw canvas) → `VisionSimView` (side-by-side normal vs. simulated comparison, mode picker).
- **Draw As Them**: `VisionModeSelectView` (pick a vision mode first) → `ColorblindDrawView` (draw a randomly assigned mission while the palette itself is pre-distorted for the chosen mode; a "Reveal Reality" toggle compares real vs. simulated colors).

## Simulation core

`Services/VisionSimulationService.swift` holds the `VisionMode` enum and does two things:
- Renders a `PKDrawing` to a `UIImage` (`render(drawing:size:)` / `render(drawing:rect:)`).
- Applies a Core Image `CIFilter.colorMatrix` per vision mode to simulate color-deficient perception on a rendered image.

`ColorblindDrawView` additionally reimplements the same color-matrix math by hand (`applyMatrix`, `matrix(for:)`) to distort individual `Color` values for the palette swatches, since `CIFilter` only operates on images. When changing the color-matrix coefficients for a vision mode, update both `VisionSimulationService.simulate` and `ColorblindDrawView.matrix(for:)` — they must stay in sync.

## Drawing

`Components/DrawingView.swift` wraps `PKCanvasView` (`UIViewRepresentable`) with a delegate callback (`onDrawingChange`) used to trigger re-simulation on every stroke. Both `CreateView` and `ColorblindDrawView` duplicate their own toolbar (pencil/pen/brush/eraser/lasso, color palette, width slider) and tool-state (`ToolType` enum, width bindings) rather than sharing one — they're intentionally independent screens with different palette/reveal behavior layered on top.
