# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

Build (iOS Simulator):
```
xcodebuild -project "Is This Red?.xcodeproj" -scheme "Is This Red?" -destination "generic/platform=iOS Simulator" build
```

Run all tests:
```
xcodebuild -project "Is This Red?.xcodeproj" -scheme "Is This Red?" -destination "platform=iOS Simulator,name=iPad Pro 13-inch (M5)" test
```

Run a single test (Swift Testing framework, not XCTest):
```
xcodebuild -project "Is This Red?.xcodeproj" -scheme "Is This Red?" -destination "platform=iOS Simulator,name=iPad Pro 13-inch (M5)" test -only-testing:"Is This Red?Tests/Is_This_Red_Tests/normalModeKeepsColorUnchanged()"
```

Note: `xcodebuild` requires the active developer directory to point at Xcode, not the bare Command Line Tools (`xcode-select -p`). If it errors with "requires Xcode", switch with `sudo xcode-select -s /Applications/Xcode.app`, or just build/run from Xcode directly — that's the normal workflow for this iPad app.

The project uses Xcode 16's file-system-synchronized groups (`PBXFileSystemSynchronizedRootGroup`): any `.swift` file placed under `Is This Red?/` is automatically part of the app target with no `project.pbxproj` edit needed. The same is true for `Is This Red?Tests/` and `Is This Red?UITests/`.

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
- Shadows — `DesignSystem/Elevation.swift` (`deepElevation()`, `glossyElevation(fill:in:)`)

If no token fits, don't round to the nearest one — say which value doesn't fit and ask before adding a token.

Most screens are not migrated yet, so existing code is not the example to copy. See `docs/design-system.md` for the full token tables, the Figma source frames, and the two conversion gotchas (Figma blur is 2× SwiftUI `radius`; Figma `Title 1` is SwiftUI `.title`).

This app is about color-vision deficiency, so UI state must never be conveyed by color alone — pair color with an icon, weight, border, or position.
