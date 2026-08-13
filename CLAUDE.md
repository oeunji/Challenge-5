# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

Build (iOS Simulator):
```
xcodebuild -project "Is This Red?.xcodeproj" -scheme "Is This Red?" -destination "generic/platform=iOS Simulator" build
```

Run all tests:
```
xcodebuild -project "Is This Red?.xcodeproj" -scheme "Is This Red?" -destination "platform=iOS Simulator,name=iPad Pro 13-inch (M4)" test
```

Run a single test (Swift Testing framework, not XCTest):
```
xcodebuild -project "Is This Red?.xcodeproj" -scheme "Is This Red?" -destination "platform=iOS Simulator,name=iPad Pro 13-inch (M4)" test -only-testing:"Is This Red?Tests/Is_This_Red_Tests/example"
```

Note: `xcodebuild` requires the active developer directory to point at Xcode, not the bare Command Line Tools (`xcode-select -p`). If it errors with "requires Xcode", switch with `sudo xcode-select -s /Applications/Xcode.app`, or just build/run from Xcode directly — that's the normal workflow for this iPad app.

The project uses Xcode 16's file-system-synchronized groups (`PBXFileSystemSynchronizedRootGroup`): any `.swift` file placed under `Is This Red?/` is automatically part of the app target with no `project.pbxproj` edit needed. The same is true for `Is This Red?Tests/` and `Is This Red?UITests/`.

## Platform constraints

- iPad only (`TARGETED_DEVICE_FAMILY = 2`), landscape only (`INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad` = landscape left/right). Don't add iPhone- or portrait-specific layout code without also revisiting these build settings.
- iOS 26.4 deployment target, Swift 5.

## Architecture

**Is This Red?** is a SwiftUI app that lets a user experience how color-vision deficiency changes perception. Two experiences share one `VisionMode` enum (`normal`, `protanopia`, `deuteranopia`, `tritanopia`, `achromatopsia`) and one simulation engine.

### Screen flow

`MyApp` (`App/MyApp.swift`) is the `@main` entry point → `RootView` (`App/RootView.swift`) drives a linear state machine via two `@State` bools (`didFinishFirst`, `didFinishOnboarding`), not `NavigationStack`:

```
OnboardingFirstView → OnboardingSecondView → ExperienceModeSelectView
```

From `ExperienceModeSelectView` (`Flow/`), the user picks one of two independent experiences, each its own `NavigationStack` push chain:

- **See Through Their Eyes**: `CreateView` (free-draw canvas) → `VisionSimView` (side-by-side normal vs. simulated comparison, mode picker).
- **Draw As Them**: `VisionModeSelectView` (pick a vision mode first) → `ColorblindDrawView` (draw a randomly assigned mission while the palette itself is pre-distorted for the chosen mode; a "Reveal Reality" toggle compares real vs. simulated colors).

### Simulation core

`Services/VisionSimulationService.swift` holds the `VisionMode` enum and does two things:
- Renders a `PKDrawing` to a `UIImage` (`render(drawing:size:)` / `render(drawing:rect:)`).
- Applies a Core Image `CIFilter.colorMatrix` per vision mode to simulate color-deficient perception on a rendered image.

`ColorblindDrawView` additionally reimplements the same color-matrix math by hand (`applyMatrix`, `matrix(for:)`) to distort individual `Color` values for the palette swatches, since `CIFilter` only operates on images. When changing the color-matrix coefficients for a vision mode, update both `VisionSimulationService.simulate` and `ColorblindDrawView.matrix(for:)` — they must stay in sync.

### Drawing

`Components/DrawingView.swift` wraps `PKCanvasView` (`UIViewRepresentable`) with a delegate callback (`onDrawingChange`) used to trigger re-simulation on every stroke. Both `CreateView` and `ColorblindDrawView` duplicate their own toolbar (pencil/pen/brush/eraser/lasso, color palette, width slider) and tool-state (`ToolType` enum, width bindings) rather than sharing one — they're intentionally independent screens with different palette/reveal behavior layered on top.
