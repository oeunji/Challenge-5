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

Two independent SwiftUI experiences (free-draw comparison vs. mission-based drawing) share one color-vision simulation engine (`VisionMode` enum + Core Image color matrix). See `docs/architecture.md` for the screen flow, the simulation core (including a duplication gotcha), and the drawing components.
