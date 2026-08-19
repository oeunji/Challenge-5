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

`Services/VisionSimulationService.swift` holds the `VisionMode` enum and the `VisionSimulator` namespace (an `enum` of statics, so the `CIContext` is created once for the whole app):

- `VisionMode.colorMatrix` is the **single source of truth** for the per-mode RGB coefficients. Change a mode's simulation here and nowhere else.
- `render(drawing:rect:)` rasterizes a `PKDrawing` to a `UIImage`.
- `simulate(image:mode:)` applies those coefficients through `CIFilter.colorMatrix`.
- `simulate(color:mode:)` applies the same coefficients arithmetically to a single `Color`, for palette swatches — `CIFilter` only operates on images.

`Is This Red?Tests` pins the matrix wiring (`normal` is identity, `achromatopsia` flattens to luminance, `protanopia` doesn't).

## Drawing

`Components/DrawingView.swift` wraps `PKCanvasView` (`UIViewRepresentable`) with a delegate callback (`onDrawingChange`) used to trigger re-simulation on every stroke.

`Components/DrawingToolbar.swift` is shared by both drawing screens:
- `DrawingTool` is the whole tool state as one `Equatable` value (kind, color, per-kind widths). Nothing calls a `setTool`-style method — the toolbar's `onChange(of: tool)` pushes any change to the canvas via `apply(to:)`.
- `DrawingToolbar` takes an optional `palette` and a `simulationMode`; `ColorblindDrawView` passes its shuffled palette and its vision mode so the swatches render pre-distorted, `CreateView` takes the defaults.

`Components/Theme.swift` holds `AppColor` (shared card/title/border colors) and `GridBackground` (the graph-paper backdrop used by both select screens).
