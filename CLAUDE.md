# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

Build (iOS Simulator):
```
xcodebuild -project IsThisRed.xcodeproj -scheme IsThisRed -destination "generic/platform=iOS Simulator" build
```

Run all tests:
```
xcodebuild -project IsThisRed.xcodeproj -scheme IsThisRed -destination "platform=iOS Simulator,name=iPad Pro 13-inch (M5)" test
```

Run a single test (Swift Testing framework, not XCTest):
```
xcodebuild -project IsThisRed.xcodeproj -scheme IsThisRed -destination "platform=iOS Simulator,name=iPad Pro 13-inch (M5)" test -only-testing:"IsThisRedTests/Is_This_Red_Tests/normalModeKeepsColorUnchanged()"
```

Note: `xcodebuild` requires the active developer directory to point at Xcode, not the bare Command Line Tools (`xcode-select -p`). If it errors with "requires Xcode", switch with `sudo xcode-select -s /Applications/Xcode.app`, or just build/run from Xcode directly — that's the normal workflow for this iPad app.

The app is named **Is This Red?** but every path, target and module is `IsThisRed` — the question mark lives only in `INFOPLIST_KEY_CFBundleDisplayName`, because `?` is a shell wildcard and a URL-reserved character. Keep it out of filenames.

The project uses Xcode 16's file-system-synchronized groups (`PBXFileSystemSynchronizedRootGroup`): any `.swift` file placed under `IsThisRed/` is automatically part of the app target with no `project.pbxproj` edit needed. The same is true for `IsThisRedTests/` and `IsThisRedUITests/`.

## Platform constraints

- iPad only (`TARGETED_DEVICE_FAMILY = 2`), landscape only (`INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad` = landscape left/right). Don't add iPhone- or portrait-specific layout code without also revisiting these build settings.
- iOS 26.4 deployment target, Swift 5.

## Architecture

Two independent SwiftUI experiences (free-draw comparison vs. mission-based drawing) share one color-vision simulation engine (`VisionMode` enum + Core Image color matrix). See `docs/architecture.md` for the screen flow, the simulation core (including a duplication gotcha), and the drawing components.

## Design system

Don't invent colors, sizes, or spacing numbers in UI code. Take them from:

- Colors — colorsets in `Assets.xcassets` (`Color("PrimaryBase")`, `Surface`, `OnSurface`, `Outline`, `Accent`, …)
- Type — `DesignSystem/Typography.swift` (`.font(Typography.title2)`). Never `Font.system(size:)` — it breaks Dynamic Type.
- Spacing — `DesignSystem/Spacing.swift` (`Spacing.x4` … `Spacing.x64`)
- Corner radius — `DesignSystem/Radius.swift` (`Radius.standard` / `.medium` / `.large`), always with `style: .continuous`. For a pill use `Capsule()`, not a large radius.
- Shadows — `DesignSystem/Elevation.swift` (`deepElevation()`, `glossyElevation(fill:in:)`)

If no token fits, don't round to the nearest one — say which value doesn't fit and ask before adding a token.

Type, spacing, and corner radius are fully migrated — existing screens are a fair example to copy. The remaining literals are deliberate (per-screen art direction, glass material alphas, the drawing palette). See `docs/design-system.md` for the full token tables, the Figma source frames, and the conversion gotchas (Figma blur is 2× SwiftUI `radius`; Figma `Title 1` is SwiftUI `.title`).

This app is about color-vision deficiency, so UI state must never be conveyed by color alone — pair color with an icon, weight, border, or position.

`DESIGN.md` covers why each screen looks and behaves the way it does — read it before changing layout or visual language, not just before changing tokens.
