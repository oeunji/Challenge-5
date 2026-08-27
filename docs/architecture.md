# Architecture

**Is This Red?** is a SwiftUI app that lets a user experience how color-vision deficiency changes perception. Two independent experiences share one `VisionMode` enum (`normal`, `protanopia`, `deuteranopia`, `tritanopia`, `achromatopsia`) and one set of simulation coefficients.

## Folder layout

```
App/          entry point and routing        MyApp, RootView, AppCoordinator
Features/     screens, grouped by experience
  Onboarding/           OnboardingFirstView, OnboardingSecondView
  Home/                 ExperienceModeSelectView
  SeeThroughTheirEyes/  CreateView, VisionSimView
  DrawAsThem/           VisionModeSelectView, ColorblindDrawView, ColorblindDrawViewModel
Components/   reusable SwiftUI views          CardSurface, DrawingToolbar, Theme
Models/       domain types                    DrawingSession, DrawingTool, VisionMode
Services/     one framework per file          ColorVisionService, DrawingRenderService
Bridge/       the only place UIKit is touched DrawingView, DrawingViewDelegate
```

`SeeThroughTheirEyes/` and `DrawAsThem/` never reference each other. Everything they share lives in the four folders below `Features/`.

Any `.swift` file placed under `IsThisRed/` joins the app target automatically (`PBXFileSystemSynchronizedRootGroup`) — moving files between these folders requires no `project.pbxproj` edit.

## Navigation

`MyApp` creates an `AppCoordinator` and a `DrawingSession` and injects both with `.environment()`.

`AppCoordinator` (`App/AppCoordinator.swift`) owns every navigation decision:

- `stage` — `.onboardingFirst` / `.onboardingSecond` / `.experience`. `RootView` switches on it. Advancing goes through `onboardingDidFinish()`.
- `path: [Route]` — the push stack, bound to the single `NavigationStack` in `RootView`.

```swift
enum Route: Hashable {
	case create
	case visionSim
	case visionModeSelect
	case colorblindDraw(VisionMode)
}
```

`Route` is a `Hashable` enum rather than a `NavigationPath` so tests can compare a path by value. `Hashable` is not optional here — `NavigationStack(path:)` and `navigationDestination(for:)` both require it.

Destinations are assembled in exactly one place, `RootView.destination(for:)`. Screens call `coordinator.push(.visionSim)` and never name a destination type. There is no `NavigationLink(destination:)` anywhere in the app.

Going back needs no code: the back button writes through the `path` binding, which is why the coordinator has no `pop()`.

```
OnboardingFirstView → OnboardingSecondView → ExperienceModeSelectView
                                                   ├─ .create           → CreateView → .visionSim → VisionSimView
                                                   └─ .visionModeSelect → VisionModeSelectView → .colorblindDraw(mode) → ColorblindDrawView
```

`VisionSimView`'s "Finish Your Experience" calls `popToRoot()`.

## Simulation core

The domain type lives outside the service layer; each service file owns exactly one framework.

- `Models/VisionMode.swift` — the `VisionMode` enum and `colorMatrix`, the **single source of truth** for the per-mode RGB coefficients. No imports. Change a mode's simulation here and nowhere else.
- `Services/DrawingRenderService.swift` — PencilKit only. `render(drawing:rect:)` rasterizes a `PKDrawing` to a `UIImage`.
- `Services/ColorVisionService.swift` — CoreImage only, and an `enum` of statics so the `CIContext` is created once for the whole app.
  - `simulate(image:mode:)` applies the coefficients through `CIFilter.colorMatrix`.
  - `simulate(color:mode:)` applies the same coefficients arithmetically to a single `Color`, for palette swatches — `CIFilter` only operates on images. Both read `VisionMode.colorMatrix`, so they cannot drift apart.

## Drawing

### Who owns the canvas

**`PKCanvasView` is owned by the screen that displays it, as `@State`, and never by a model, view model, or environment object.**

This is not a style preference. A `UIViewRepresentable` must own the `UIView` it returns from `makeUIView`. When a longer-lived object supplied the canvas, `navigationDestination` rebuilt the screen, the same `UIView` was re-hosted, and its gesture recognizers lost their responder chain — the app crashed on the first stroke:

```
*** -[__NSArrayM insertObject:atIndex:]: object cannot be nil
    -[UIGestureRecognizer _delayTouchesForEvent:inPhase:]
```

What crosses a screen boundary is `PKDrawing`, a value type.

### The pieces

`Bridge/DrawingView.swift` wraps `PKCanvasView` as a `UIViewRepresentable`; `Bridge/DrawingViewDelegate.swift` adapts `PKCanvasViewDelegate` callbacks into the `onDrawingChange` closure. These two files are the app's entire UIKit surface.

`Models/DrawingSession.swift` holds a `PKDrawing` plus the images rendered from it. `Framing` decides the render area, because the two drawing screens want different ones:

| Framing | falls back to 1024×1024 when | otherwise |
| --- | --- | --- |
| `.fittingDrawing(padding:)` | the drawing is empty | drawing bounds, inset outward by `padding` |
| `.fixed(size)` | `size` is `.zero` | that size at the origin |

Instances are not shared between the two experiences — free drawing and mission drawing are different pictures. `CreateView` and `VisionSimView` share the app-level session; `ColorblindDrawViewModel` owns a private one.

`Models/DrawingTool.swift` is the whole tool state as one `Equatable` value (kind, color, per-kind widths). Nothing calls a `setTool`-style method — `DrawingToolbar`'s `onChange(of: tool)` pushes any change to the canvas via `apply(to:)`.

`Components/DrawingToolbar.swift` is shared by both drawing screens. It takes an optional `palette` and a `simulationMode`; `ColorblindDrawView` passes its shuffled palette and its effective vision mode so the swatches render pre-distorted, `CreateView` takes the defaults.

`Components/Theme.swift` holds `AppColor` and `GridBackground` (the graph-paper backdrop used by both select screens). `Components/CardSurface.swift` is the white bordered card surface used by both; it draws background and border from one shared `Shape` and uses `strokeBorder` so the line stays inside the card.

The app is pinned to light mode (`preferredColorScheme(.light)` in `MyApp`) because the drawing surfaces and card colors are hardcoded light values, and because a comparison of simulated colors should not shift with the device theme.

## Testing

25 test cases run; 19 of them need neither SwiftUI nor UIKit.

| Target of the test | File |
| --- | --- |
| Navigation rules (stage advance, push, popToRoot) | `AppCoordinatorTests` |
| Reveal state × selected mode → effective mode | `ColorblindDrawViewModelTests` |
| Render-area rules for both `Framing` cases | `DrawingSessionTests` |
| Per-kind width memory, pen fallback on color pick | `DrawingToolTests` |
| Color-matrix wiring per vision mode | `Is_This_Red_Tests` |
| Drawing an actual stroke in both flows | `DrawingFlowUITests` |

`DrawingFlowUITests` exists because the crash above was invisible to every test that only checked whether a screen appeared. It draws a real stroke in each flow and asserts the app is still running.

Rendered pixels are not compared. The coefficients are verified directly instead, and image comparison is unstable across simulator versions.
