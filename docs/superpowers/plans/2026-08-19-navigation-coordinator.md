# 화면 전환 Coordinator 구현 계획

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 뷰 안에 흩어진 화면 전환 규칙을 `AppCoordinator` 한 곳으로 모으고, 화면 간 공유 상태인 `PKCanvasView`를 `DrawingSession` 모델로 흡수한다.

**Architecture:** `@Observable` 클래스 두 개를 `MyApp`이 만들어 `.environment()`로 주입한다. `AppCoordinator`는 온보딩 단계(`stage`)와 push 경로(`path: [Route]`)를 소유하고, `RootView`가 그 둘을 읽어 화면을 고른다. 목적지 조립은 `RootView`의 `navigationDestination` 한 곳에만 존재한다.

**Tech Stack:** SwiftUI (iOS 26.4), PencilKit, Observation, Swift Testing

**Spec:** `docs/superpowers/specs/2026-08-19-navigation-coordinator-design.md`

## Global Constraints

- 들여쓰기는 **탭 문자(`\t`)**. 한 줄 최대 99자. (`.claude/skills/swift-style-share/`)
- 타입 안에서 `// MARK: -` 구분자 사용: `Types` / `Constants` / `Properties` / `Initialize` / `Body` / `Subviews` / `Computed Values` / `Methods` / `Actions`. MARK 위아래에 빈 줄.
- 상속 예정이 없는 클래스는 `final`.
- 관련 상수는 `private enum Metric`으로 묶는다.
- **눈에 보이는 동작은 바뀌지 않는다.** 렌더 영역 계산 규칙은 현재 코드와 동일하게 유지한다.
- 새 `.swift` 파일은 `Is This Red?/` 아래에 두면 타겟에 자동 포함된다 (`PBXFileSystemSynchronizedRootGroup`). `project.pbxproj`를 편집하지 말 것.
- 빌드: `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -project "Is This Red?.xcodeproj" -scheme "Is This Red?" -destination "generic/platform=iOS Simulator" build`
- 테스트: 위 명령의 `-destination "platform=iOS Simulator,name=iPad Pro 13-inch (M5)" test`
- 각 Task는 빌드와 **전체 테스트 통과** 상태로 커밋한다.

## File Structure

| 파일 | 책임 |
| --- | --- |
| `Is This Red?/App/AppCoordinator.swift` (신규) | `Route` 열거형 + 전환 상태 소유 |
| `Is This Red?/Models/DrawingSession.swift` (신규) | 캔버스 1개 + 렌더 결과 2개 + 렌더 영역 계산 |
| `Is This Red?Tests/AppCoordinatorTests.swift` (신규) | 전환 규칙 검증 |
| `Is This Red?Tests/DrawingSessionTests.swift` (신규) | 렌더 영역 계산 검증 |
| `Is This Red?/App/MyApp.swift` | 두 객체 생성·주입 |
| `Is This Red?/App/RootView.swift` | `stage` 분기 + `NavigationStack` + 목적지 조립 |
| `Is This Red?/Flow/OnboardingFirstView.swift` | `@Binding` 제거 → coordinator 호출 |
| `Is This Red?/Flow/OnboardingSecondView.swift` | 위와 동일 |
| `Is This Red?/Flow/ExperienceModeSelectView.swift` | `NavigationStack` 제거, 버튼이 `push` |
| `Is This Red?/Flow/VisionModeSelectView.swift` | 카드가 `push` |
| `Is This Red?/Flow/CreateView.swift` | 세션 사용, "Next"가 `push` |
| `Is This Red?/Flow/VisionSimView.swift` | 세션 사용, "Finish"가 `popToRoot` |
| `Is This Red?/Flow/ColorblindDrawView.swift` | 자체 세션 인스턴스 사용 |

## Task 순서 주의

스펙의 마이그레이션 순서에서 **세션 전환을 라우팅보다 앞으로** 옮겼다. `navigationDestination`이 `VisionSimView()`를 인자 없이 만들어야 하는데, 세션 전환 전에는 `canvasView:` 인자가 필수라 컴파일되지 않기 때문이다.

---

### Task 1: AppCoordinator

전환 상태를 소유하는 객체. 아직 아무도 쓰지 않는다.

**Files:**
- Create: `Is This Red?/App/AppCoordinator.swift`
- Test: `Is This Red?Tests/AppCoordinatorTests.swift`

**Interfaces:**
- Consumes: `VisionMode` (기존 `Services/VisionSimulationService.swift`)
- Produces:
  - `enum Route: Hashable { case create, visionSim, visionModeSelect, colorblindDraw(VisionMode) }`
  - `final class AppCoordinator` — `stage: Stage` (get-only), `path: [Route]`, `onboardingDidFinish()`, `push(_ route: Route)`, `popToRoot()`
  - `AppCoordinator.Stage` — `.onboardingFirst`, `.onboardingSecond`, `.experience`

- [ ] **Step 1: 실패하는 테스트 작성**

`Is This Red?Tests/AppCoordinatorTests.swift`:

```swift
//
//  AppCoordinatorTests.swift
//  Is This Red?Tests
//

import Testing
@testable import Is_This_Red_

struct AppCoordinatorTests {

	// MARK: - Tests

	@Test("온보딩을 두 번 지나면 체험 단계가 된다")
	func onboardingAdvancesThroughStages() {
		let coordinator = AppCoordinator()
		#expect(coordinator.stage == .onboardingFirst)

		coordinator.onboardingDidFinish()
		#expect(coordinator.stage == .onboardingSecond)

		coordinator.onboardingDidFinish()
		#expect(coordinator.stage == .experience)
	}

	@Test("체험 단계에서 더 진행해도 단계가 유지된다")
	func onboardingStopsAtExperience() {
		let coordinator = AppCoordinator()
		coordinator.onboardingDidFinish()
		coordinator.onboardingDidFinish()
		coordinator.onboardingDidFinish()

		#expect(coordinator.stage == .experience)
	}

	@Test("push하면 경로에 목적지가 순서대로 쌓인다")
	func pushAppendsRoutes() {
		let coordinator = AppCoordinator()

		coordinator.push(.visionModeSelect)
		coordinator.push(.colorblindDraw(.protanopia))

		#expect(coordinator.path == [.visionModeSelect, .colorblindDraw(.protanopia)])
	}

	@Test("popToRoot는 경로를 비운다")
	func popToRootClearsPath() {
		let coordinator = AppCoordinator()
		coordinator.push(.create)
		coordinator.push(.visionSim)

		coordinator.popToRoot()

		#expect(coordinator.path.isEmpty)
	}
}
```

- [ ] **Step 2: 실패 확인**

Run:
```
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -project "Is This Red?.xcodeproj" -scheme "Is This Red?" -destination "platform=iOS Simulator,name=iPad Pro 13-inch (M5)" test 2>&1 | grep -E "error:|\*\* TEST"
```
Expected: 컴파일 실패. `cannot find 'AppCoordinator' in scope`

- [ ] **Step 3: 최소 구현**

`Is This Red?/App/AppCoordinator.swift`:

```swift
//
//  AppCoordinator.swift
//  Is This Red?
//

import Observation

/// 앱이 이동할 수 있는 화면. `NavigationStack`의 경로 원소로 쓰인다.
enum Route: Hashable {
	case create
	case visionSim
	case visionModeSelect
	case colorblindDraw(VisionMode)
}

/// 온보딩 단계와 push 경로를 소유한다. 뷰는 목적지를 모르고 이 객체에 요청만 한다.
@Observable
final class AppCoordinator {

	// MARK: - Types

	enum Stage {
		case onboardingFirst
		case onboardingSecond
		case experience
	}

	// MARK: - Properties

	private(set) var stage: Stage = .onboardingFirst
	var path: [Route] = []

	// MARK: - Methods

	/// 온보딩 한 단계를 끝낸다. 이미 체험 단계면 아무 일도 하지 않는다.
	func onboardingDidFinish() {
		switch stage {
		case .onboardingFirst:
			stage = .onboardingSecond
		case .onboardingSecond:
			stage = .experience
		case .experience:
			break
		}
	}

	func push(_ route: Route) {
		path.append(route)
	}

	func popToRoot() {
		path.removeAll()
	}
}
```

- [ ] **Step 4: 통과 확인**

Run: Step 2와 같은 명령
Expected: `** TEST SUCCEEDED **`, 테스트 7개 통과 (기존 3 + 신규 4)

- [ ] **Step 5: 커밋**

```bash
git add "Is This Red?/App/AppCoordinator.swift" "Is This Red?Tests/AppCoordinatorTests.swift"
git commit -m "add: 화면 전환 상태를 소유하는 AppCoordinator"
```

---

### Task 2: DrawingSession

캔버스와 렌더 결과를 소유하는 모델. 아직 아무도 쓰지 않는다.

**Files:**
- Create: `Is This Red?/Models/DrawingSession.swift`
- Test: `Is This Red?Tests/DrawingSessionTests.swift`

**Interfaces:**
- Consumes: `VisionSimulator.render(drawing:rect:)`, `VisionSimulator.simulate(image:mode:)`, `VisionMode`
- Produces:
  - `final class DrawingSession` — `canvas: PKCanvasView`, `normalImage: UIImage?` (get-only), `simulatedImage: UIImage?` (get-only), `rect(for: Framing) -> CGRect`, `render(_ framing: Framing, mode: VisionMode)`
  - `DrawingSession.Framing` — `.fittingDrawing(padding: CGFloat)`, `.fixed(CGSize)`

**렌더 영역 규칙 (현재 동작 그대로 유지):**

| Framing | 대체 조건 | 대체값 | 정상 결과 |
| --- | --- | --- | --- |
| `.fittingDrawing(padding:)` | 그림이 비어 있을 때 | 1024×1024 | 그림 경계를 `padding`만큼 바깥으로 넓힌 사각형 |
| `.fixed(size)` | `size`가 `.zero`일 때 | 1024×1024 | 원점 `.zero`에 그 크기 |

`.fixed`는 그림이 비어 있어도 대체하지 않는다. 현재 `ColorblindDrawView`가 그렇게 동작한다.

- [ ] **Step 1: 실패하는 테스트 작성**

`Is This Red?Tests/DrawingSessionTests.swift`:

```swift
//
//  DrawingSessionTests.swift
//  Is This Red?Tests
//

import Testing
import PencilKit
@testable import Is_This_Red_

struct DrawingSessionTests {

	// MARK: - Constants

	private let fallback = CGRect(x: 0, y: 0, width: 1024, height: 1024)

	// MARK: - Tests

	@Test("그림이 비어 있으면 fittingDrawing은 기본 정사각형을 쓴다")
	func emptyDrawingFallsBackToSquare() {
		let session = DrawingSession()

		#expect(session.rect(for: .fittingDrawing(padding: 24)) == fallback)
	}

	@Test("그림이 있으면 경계 바깥으로 여백만큼 넓힌다")
	func drawingBoundsGetPadding() {
		let session = DrawingSession()
		session.canvas.drawing = strokedDrawing()
		let bounds = session.canvas.drawing.bounds

		let rect = session.rect(for: .fittingDrawing(padding: 24))

		#expect(rect.width == bounds.width + 48)
		#expect(rect.height == bounds.height + 48)
		#expect(rect.minX == bounds.minX - 24)
	}

	@Test("fixed는 주어진 크기를 원점에 그대로 쓴다")
	func fixedUsesGivenSize() {
		let session = DrawingSession()

		let rect = session.rect(for: .fixed(CGSize(width: 800, height: 600)))

		#expect(rect == CGRect(x: 0, y: 0, width: 800, height: 600))
	}

	@Test("fixed에 0 크기가 오면 기본 정사각형으로 대체한다")
	func fixedZeroFallsBackToSquare() {
		let session = DrawingSession()

		#expect(session.rect(for: .fixed(.zero)) == fallback)
	}

	// MARK: - Helpers

	/// 경계를 가진 그림을 만든다. 좌표는 임의이고 값 자체에 의미는 없다.
	private func strokedDrawing() -> PKDrawing {
		let points = [CGPoint(x: 100, y: 100), CGPoint(x: 300, y: 250)].map {
			PKStrokePoint(
				location: $0,
				timeOffset: 0,
				size: CGSize(width: 4, height: 4),
				opacity: 1,
				force: 1,
				azimuth: 0,
				altitude: 0
			)
		}
		let path = PKStrokePath(controlPoints: points, creationDate: Date())
		return PKDrawing(strokes: [PKStroke(ink: PKInk(.pen, color: .black), path: path)])
	}
}
```

- [ ] **Step 2: 실패 확인**

Run:
```
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -project "Is This Red?.xcodeproj" -scheme "Is This Red?" -destination "platform=iOS Simulator,name=iPad Pro 13-inch (M5)" test 2>&1 | grep -E "error:|\*\* TEST"
```
Expected: 컴파일 실패. `cannot find 'DrawingSession' in scope`

- [ ] **Step 3: 최소 구현**

`Is This Red?/Models/DrawingSession.swift`:

```swift
//
//  DrawingSession.swift
//  Is This Red?
//

import SwiftUI
import PencilKit

/// 캔버스 하나와 그것을 렌더한 결과를 들고 있다.
/// 자유 드로잉과 미션 드로잉은 별개의 그림이므로 인스턴스를 따로 만들어 쓴다.
@Observable
final class DrawingSession {

	// MARK: - Types

	/// 렌더 영역을 정하는 방식. 두 그리기 화면이 서로 다르게 요구한다.
	enum Framing: Equatable {
		/// 그림 경계에 여백을 두른 영역. 그림이 비어 있으면 기본 정사각형.
		case fittingDrawing(padding: CGFloat)
		/// 주어진 크기를 원점에 그대로. 크기가 `.zero`면 기본 정사각형.
		case fixed(CGSize)
	}

	// MARK: - Constants

	private enum Metric {
		static let fallbackSide: CGFloat = 1024
	}

	// MARK: - Properties

	let canvas = PKCanvasView()
	private(set) var normalImage: UIImage?
	private(set) var simulatedImage: UIImage?

	// MARK: - Computed Values

	private var fallbackRect: CGRect {
		CGRect(x: 0, y: 0, width: Metric.fallbackSide, height: Metric.fallbackSide)
	}

	// MARK: - Methods

	func rect(for framing: Framing) -> CGRect {
		switch framing {
		case .fittingDrawing(let padding):
			let bounds = canvas.drawing.bounds
			guard !bounds.isEmpty else { return fallbackRect }
			return bounds.insetBy(dx: -padding, dy: -padding)
		case .fixed(let size):
			guard size != .zero else { return fallbackRect }
			return CGRect(origin: .zero, size: size)
		}
	}

	func render(_ framing: Framing, mode: VisionMode) {
		let image = VisionSimulator.render(drawing: canvas.drawing, rect: rect(for: framing))
		normalImage = image
		simulatedImage = VisionSimulator.simulate(image: image, mode: mode)
	}
}
```

- [ ] **Step 4: 통과 확인**

Run:
```
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -project "Is This Red?.xcodeproj" -scheme "Is This Red?" -destination "platform=iOS Simulator,name=iPad Pro 13-inch (M5)" test 2>&1 | grep -E "error:|\*\* TEST"
```
Expected: `** TEST SUCCEEDED **`, 테스트 11개 통과 (기존 3 + Task 1의 4 + 신규 4)

- [ ] **Step 5: 커밋**

```bash
git add "Is This Red?/Models/DrawingSession.swift" "Is This Red?Tests/DrawingSessionTests.swift"
git commit -m "add: 캔버스와 렌더 결과를 소유하는 DrawingSession"
```

---

### Task 3: 두 객체 주입 + 온보딩 단계 전환

`RootView`의 bool 2개를 걷어낸다. `NavigationStack`은 아직 건드리지 않는다.

**Files:**
- Modify: `Is This Red?/App/MyApp.swift`
- Modify: `Is This Red?/App/RootView.swift`
- Modify: `Is This Red?/Flow/OnboardingFirstView.swift`
- Modify: `Is This Red?/Flow/OnboardingSecondView.swift`

**Interfaces:**
- Consumes: `AppCoordinator`, `AppCoordinator.Stage`, `DrawingSession` (Task 1·2)
- Produces: `OnboardingFirstView()`, `OnboardingSecondView()` — 인자 없는 생성자

- [ ] **Step 1: MyApp에서 두 객체 생성·주입**

`Is This Red?/App/MyApp.swift` 전체를 아래로 교체:

```swift
//
//  MyApp.swift
//  Is This Red?
//

import SwiftUI

@main
struct MyApp: App {

	// MARK: - Properties

	@State private var coordinator = AppCoordinator()
	@State private var session = DrawingSession()

	// MARK: - Body

	var body: some Scene {
		WindowGroup {
			RootView()
				.preferredColorScheme(.light)
				.environment(coordinator)
				.environment(session)
		}
	}
}
```

- [ ] **Step 2: RootView를 stage 분기로 교체**

`Is This Red?/App/RootView.swift`에서 `// MARK: - Properties`부터 `// MARK: - Body` 블록 끝까지를 아래로 교체:

```swift
	// MARK: - Properties

	@Environment(AppCoordinator.self) private var coordinator

	// MARK: - Body

	var body: some View {
		switch coordinator.stage {
		case .onboardingFirst:
			OnboardingFirstView()
		case .onboardingSecond:
			OnboardingSecondView()
		case .experience:
			ExperienceModeSelectView()
		}
	}
```

`@State private var didFinishFirst`와 `didFinishOnboarding` 두 줄은 삭제된다.

- [ ] **Step 3: OnboardingFirstView 배선**

`Is This Red?/Flow/OnboardingFirstView.swift`에서 아래 줄을

```swift
	@Binding var didFinish: Bool
	@State private var backgroundIndex = 0
```

이렇게 바꾼다:

```swift
	@Environment(AppCoordinator.self) private var coordinator
	@State private var backgroundIndex = 0
```

그리고 `answerDidTap()` 안의

```swift
		if nextIndex == 0 {
			withAnimation(.easeInOut(duration: 0.35)) {
				didFinish = true
			}
		}
```

를 이렇게 바꾼다:

```swift
		if nextIndex == 0 {
			withAnimation(.easeInOut(duration: 0.35)) {
				coordinator.onboardingDidFinish()
			}
		}
```

- [ ] **Step 4: OnboardingSecondView 배선**

`Is This Red?/Flow/OnboardingSecondView.swift`에서

```swift
	@Binding var didFinish: Bool
	@State private var revealedCount = 1
```

를

```swift
	@Environment(AppCoordinator.self) private var coordinator
	@State private var revealedCount = 1
```

로 바꾸고, `viewDidTap()` 안의 `didFinish = true`를 `coordinator.onboardingDidFinish()`로 바꾼다.

- [ ] **Step 5: 빌드와 테스트**

Run:
```
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -project "Is This Red?.xcodeproj" -scheme "Is This Red?" -destination "platform=iOS Simulator,name=iPad Pro 13-inch (M5)" test 2>&1 | grep -E "error:|\*\* TEST"
```
Expected: `** TEST SUCCEEDED **`, 11개 통과

- [ ] **Step 6: 손으로 확인**

시뮬레이터에서 앱을 실행해 Yes/No를 다섯 번 눌러 온보딩 2단계로 넘어가고, 화면을 네 번 탭해 모드 선택 화면까지 도달하는지 본다. 이전과 동일해야 한다.

- [ ] **Step 7: 커밋**

```bash
git add "Is This Red?/App" "Is This Red?/Flow/OnboardingFirstView.swift" "Is This Red?/Flow/OnboardingSecondView.swift"
git commit -m "refactor: 온보딩 단계 전환을 AppCoordinator로 이관"
```

---

### Task 4: CreateView·VisionSimView를 세션으로

두 화면이 인자로 캔버스를 주고받는 대신 같은 세션을 본다. `NavigationLink`는 아직 그대로 둔다.

**Files:**
- Modify: `Is This Red?/Flow/CreateView.swift`
- Modify: `Is This Red?/Flow/VisionSimView.swift`

**Interfaces:**
- Consumes: `DrawingSession` (Task 2) — `canvas`, `normalImage`, `simulatedImage`, `render(_:mode:)`
- Produces: `VisionSimView()` — 인자 없는 생성자. Task 6의 `navigationDestination`이 이 형태를 요구한다.

- [ ] **Step 1: CreateView가 세션을 쓰게 한다**

`Is This Red?/Flow/CreateView.swift`에서

```swift
	@State private var canvasView = PKCanvasView()
	@State private var tool = DrawingTool()
	@Environment(\.dismiss) private var dismiss
```

를

```swift
	@Environment(DrawingSession.self) private var session
	@State private var tool = DrawingTool()
```

로 바꾼다. `dismiss`는 더 이상 쓰이지 않는다.

본문의 `canvasView` 참조 두 곳을 `session.canvas`로 바꾼다:

```swift
		DrawingView(canvasView: session.canvas)
```
```swift
					DrawingToolbar(tool: $tool, canvasView: session.canvas)
```

`nextLink`의 목적지에서 인자를 없앤다:

```swift
	private var nextLink: some View {
		NavigationLink {
			VisionSimView()
		} label: {
			Text("Next")
				.font(.system(size: 16, weight: .semibold, design: .rounded))
				.foregroundColor(.black)
		}
		.buttonStyle(.bordered)
		.tint(.clear)
		.padding(.horizontal, 12)
	}
```

- [ ] **Step 2: VisionSimView가 세션을 쓰게 한다**

`Is This Red?/Flow/VisionSimView.swift`의 `Constants`·`Properties` 블록을 아래로 교체:

```swift
	// MARK: - Constants

	private enum Metric {
		static let spacing: CGFloat = 16
		static let horizontalPadding: CGFloat = 16
		static let drawingPadding: CGFloat = 24
	}

	// MARK: - Properties

	@Environment(DrawingSession.self) private var session
	@Environment(\.dismiss) private var dismiss
	var onFinish: (() -> Void)?

	@State private var selectedMode: VisionMode = .protanopia
```

`canvasView`, `normalImage`, `simulatedImage` 세 프로퍼티와 `Metric.emptyDrawingSide`가 사라진다.

`preview` 호출 두 곳이 세션의 이미지를 보게 한다:

```swift
					preview(title: "Normal", image: session.normalImage, side: max(0, available / 2))
					preview(
						title: selectedMode.rawValue,
						image: session.simulatedImage,
						side: max(0, available / 2)
					)
```

`preview`가 옵셔널 이미지를 받게 한다:

```swift
	private func preview(title: String, image: UIImage?, side: CGFloat) -> some View {
		VStack {
			Text(title)
				.font(.caption)
			if let image {
				Image(uiImage: image)
					.resizable()
					.scaledToFit()
					.frame(width: side, height: side)
					.border(Color.gray.opacity(0.3))
			}
		}
	}
```

`drawingRect`와 `updateImages`를 지우고 아래 하나로 대체한다:

```swift
	// MARK: - Methods

	private func updateImages() {
		session.render(.fittingDrawing(padding: Metric.drawingPadding), mode: selectedMode)
	}
```

`// MARK: - Computed Values` 구분자도 남는 멤버가 없으므로 함께 지운다.

- [ ] **Step 3: 빌드와 테스트**

Run:
```
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -project "Is This Red?.xcodeproj" -scheme "Is This Red?" -destination "platform=iOS Simulator,name=iPad Pro 13-inch (M5)" test 2>&1 | grep -E "error:|\*\* TEST"
```
Expected: `** TEST SUCCEEDED **`, 11개 통과

- [ ] **Step 4: 손으로 확인**

"See Through Their Eyes" → 무언가 그리기 → Next. 왼쪽 Normal과 오른쪽 시뮬레이션 이미지가 이전처럼 보여야 한다. 모드 피커를 바꾸면 오른쪽만 바뀐다.

**알려진 일시적 퇴행:** `CreateView`가 `onFinish`를 더 이상 넘기지 않으므로, 이 시점의 "Finish Your Experience"는 모드 선택 화면이 아니라 `CreateView`로만 돌아간다. Task 7에서 `popToRoot()`로 대체되며 복구된다. 여기서 고치려 하지 말 것 — Task 6 전에는 `path`가 스택을 구동하지 않아 `popToRoot()`가 화면에 아무 영향을 주지 않는다.

- [ ] **Step 5: 커밋**

```bash
git add "Is This Red?/Flow/CreateView.swift" "Is This Red?/Flow/VisionSimView.swift"
git commit -m "refactor: CreateView와 VisionSimView가 DrawingSession을 공유"
```

---

### Task 5: ColorblindDrawView를 세션으로

이 화면은 캔버스를 공유하지 않으므로 자기 인스턴스를 소유한다.

**Files:**
- Modify: `Is This Red?/Flow/ColorblindDrawView.swift`

**Interfaces:**
- Consumes: `DrawingSession` (Task 2)
- Produces: 없음 (생성자 `ColorblindDrawView(selectedMode:)` 유지)

- [ ] **Step 1: 상태를 세션으로 교체**

`Properties` 블록에서 아래 네 줄을

```swift
	@State private var canvasView = PKCanvasView()
	…
	@State private var normalImage: UIImage?
	@State private var simulatedImage: UIImage?
```

한 줄로 바꾼다:

```swift
	@State private var session = DrawingSession()
```

`Metric`에서 `fallbackCanvasSide`를 지운다. 대체 규칙은 이제 `DrawingSession`이 갖는다.

- [ ] **Step 2: 캔버스 참조 교체**

`canvasView`를 쓰는 세 곳을 `session.canvas`로 바꾼다:

```swift
			DrawingToolbar(
				tool: $tool,
				canvasView: session.canvas,
				palette: palette,
				simulationMode: effectiveMode
			)
```
```swift
				DrawingView(canvasView: session.canvas) {
					renderAndSimulate()
				}
```

- [ ] **Step 3: 렌더 호출과 표시 이미지 교체**

`renderAndSimulate()`를 아래로 바꾼다:

```swift
	private func renderAndSimulate() {
		session.render(.fixed(renderSize), mode: selectedMode)
	}
```

`displayedImage`가 세션을 보게 한다:

```swift
	private var displayedImage: UIImage? {
		isShowingNormal ? session.normalImage : session.simulatedImage
	}
```

- [ ] **Step 4: 빌드와 테스트**

Run:
```
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -project "Is This Red?.xcodeproj" -scheme "Is This Red?" -destination "platform=iOS Simulator,name=iPad Pro 13-inch (M5)" test 2>&1 | grep -E "error:|\*\* TEST"
```
Expected: `** TEST SUCCEEDED **`, 11개 통과

- [ ] **Step 5: 손으로 확인**

"Draw As Them" → 모드 선택 → 그리기. 획이 보이고, "Reveal Reality"를 눌러 Normal/Simulated를 전환하면 이전처럼 그림이 바뀌어야 한다. 뒤로 나갔다 다른 모드로 다시 들어가면 **빈 캔버스**로 시작해야 한다.

- [ ] **Step 6: 커밋**

```bash
git add "Is This Red?/Flow/ColorblindDrawView.swift"
git commit -m "refactor: ColorblindDrawView가 자체 DrawingSession을 소유"
```

---

### Task 6: NavigationStack을 RootView로 이전

목적지 조립을 한 곳에 만든다. 기존 `NavigationLink`는 아직 살아 있고 바깥 스택 안에서 그대로 동작한다.

**Files:**
- Modify: `Is This Red?/App/RootView.swift`
- Modify: `Is This Red?/Flow/ExperienceModeSelectView.swift`

**Interfaces:**
- Consumes: `Route`, `AppCoordinator.path` (Task 1), `VisionSimView()` (Task 4)
- Produces: `navigationDestination(for: Route.self)` — 이후 모든 push의 유일한 목적지 조립 지점

- [ ] **Step 1: ExperienceModeSelectView에서 NavigationStack 제거**

`body`의 `NavigationStack { … }` 래퍼를 벗겨 `ZStack`이 최상위가 되게 한다. 안쪽 내용은 그대로 두고 들여쓰기만 한 단계 줄인다.

```swift
	var body: some View {
		ZStack {
			GridBackground()
			VStack(spacing: 16) {
				…
			}
		}
	}
```

- [ ] **Step 2: RootView에 스택과 목적지 추가**

`Is This Red?/App/RootView.swift`의 `Body` 블록을 아래로 교체하고 `Subviews` 블록을 새로 만든다:

```swift
	// MARK: - Body

	var body: some View {
		switch coordinator.stage {
		case .onboardingFirst:
			OnboardingFirstView()
		case .onboardingSecond:
			OnboardingSecondView()
		case .experience:
			experienceStack
		}
	}

	// MARK: - Subviews

	private var experienceStack: some View {
		@Bindable var coordinator = coordinator

		return NavigationStack(path: $coordinator.path) {
			ExperienceModeSelectView()
				.navigationDestination(for: Route.self) { route in
					destination(for: route)
				}
		}
	}

	@ViewBuilder
	private func destination(for route: Route) -> some View {
		switch route {
		case .create:
			CreateView()
		case .visionSim:
			VisionSimView()
		case .visionModeSelect:
			VisionModeSelectView()
		case .colorblindDraw(let mode):
			ColorblindDrawView(selectedMode: mode)
		}
	}
```

`@Observable` 객체의 프로퍼티를 바인딩하려면 `@Bindable`이 필요하다. 지역 변수로 다시 선언하는 것이 정식 사용법이다.

- [ ] **Step 3: 빌드와 테스트**

Run:
```
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -project "Is This Red?.xcodeproj" -scheme "Is This Red?" -destination "platform=iOS Simulator,name=iPad Pro 13-inch (M5)" test 2>&1 | grep -E "error:|\*\* TEST"
```
Expected: `** TEST SUCCEEDED **`, 11개 통과

- [ ] **Step 4: 손으로 확인**

두 갈래 플로우가 모두 이전처럼 push되고 back 버튼으로 돌아와야 한다. 이 단계에서는 아직 기존 `NavigationLink`가 전환을 담당한다.

- [ ] **Step 5: 커밋**

```bash
git add "Is This Red?/App/RootView.swift" "Is This Red?/Flow/ExperienceModeSelectView.swift"
git commit -m "refactor: NavigationStack과 목적지 조립을 RootView로 이전"
```

---

### Task 7: NavigationLink를 push로 교체

전환 규칙을 하나로 만든다. 이 Task가 끝나면 앱에 `NavigationLink(destination:)`이 남지 않는다.

**Files:**
- Modify: `Is This Red?/Flow/ExperienceModeSelectView.swift`
- Modify: `Is This Red?/Flow/VisionModeSelectView.swift`
- Modify: `Is This Red?/Flow/CreateView.swift`
- Modify: `Is This Red?/Flow/VisionSimView.swift`

**Interfaces:**
- Consumes: `AppCoordinator.push(_:)`, `AppCoordinator.popToRoot()`, `Route` (Task 1)
- Produces: 없음 (마지막 Task)

- [ ] **Step 1: ExperienceModeSelectView의 두 버튼**

`Properties` 블록에 추가:

```swift
	// MARK: - Properties

	@Environment(AppCoordinator.self) private var coordinator
```

호출부 두 곳을 바꾼다:

```swift
					HStack(spacing: 16) {
						modeButton(
							title: "See Through Their Eyes",
							subtitle: "Simulate how your drawing looks to them",
							route: .create
						)

						modeButton(
							title: "Draw As Them",
							subtitle: "Draw with color-vision limits",
							route: .visionModeSelect
						)
					}
```

`modeButton`에서 제네릭 목적지 파라미터를 없앤다:

```swift
	private func modeButton(title: String, subtitle: String, route: Route) -> some View {
		Button {
			coordinator.push(route)
		} label: {
			VStack(spacing: 6) {
				Text(title)
					.font(.system(size: 18, weight: .semibold))
					.foregroundColor(AppColor.title)
				Text(subtitle)
					.font(.system(size: 12, weight: .regular))
					.foregroundColor(AppColor.subtitle)
					.multilineTextAlignment(.center)
					.lineLimit(2)
			}
			.frame(width: Metric.buttonWidth)
			.frame(minHeight: Metric.buttonMinHeight)
			.padding(.vertical, 6)
			.background(.white)
			.clipShape(RoundedRectangle(cornerRadius: Metric.cornerRadius, style: .continuous))
			.overlay(
				RoundedRectangle(cornerRadius: Metric.cornerRadius, style: .continuous)
					.stroke(AppColor.cardBorder, lineWidth: 1.5)
			)
			.shadow(color: .white.opacity(0.25), radius: 4, x: 0, y: 2)
		}
		.buttonStyle(.plain)
	}
```

`@ViewBuilder`와 `<Destination: View>`가 사라진다.

- [ ] **Step 2: VisionModeSelectView의 카드**

`Properties` 블록에 `@Environment(AppCoordinator.self) private var coordinator`를 추가하고, `modeCard`의 `NavigationLink`를 `Button`으로 바꾼다:

```swift
	private func modeCard(_ item: (mode: VisionMode, subtitle: String)) -> some View {
		Button {
			coordinator.push(.colorblindDraw(item.mode))
		} label: {
			VStack(alignment: .center, spacing: 10) {
				Text(item.mode.rawValue)
					.font(.system(size: 24, weight: .semibold))
					.foregroundColor(AppColor.title)
					.multilineTextAlignment(.center)
				Text(item.subtitle)
					.font(.system(size: 18, weight: .regular))
					.foregroundColor(AppColor.subtitle)
					.multilineTextAlignment(.center)
			}
			.frame(maxWidth: Metric.cardMaxWidth, minHeight: Metric.cardMinHeight)
			.padding(.horizontal, 12)
			.background(Color.white)
			.clipShape(RoundedRectangle(cornerRadius: Metric.cornerRadius, style: .continuous))
			.overlay(
				RoundedRectangle(cornerRadius: Metric.cornerRadius, style: .continuous)
					.stroke(AppColor.cardBorder, lineWidth: 1.5)
			)
		}
		.buttonStyle(.plain)
	}
```

- [ ] **Step 3: CreateView의 Next**

`Properties`에 `@Environment(AppCoordinator.self) private var coordinator`를 추가하고, `nextLink`를 `nextButton`으로 바꾼다. `toolbar` 안의 참조도 함께 고친다.

```swift
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
```

- [ ] **Step 4: VisionSimView의 Finish**

`Properties`에 `@Environment(AppCoordinator.self) private var coordinator`를 추가하고, `@Environment(\.dismiss) private var dismiss`와 `var onFinish: (() -> Void)?` 두 줄을 삭제한다.

버튼 동작을 바꾼다:

```swift
			Button("Finish Your Experience") {
				coordinator.popToRoot()
			}
			.padding()
			.foregroundColor(.black)
```

`dismiss()` 후 `DispatchQueue.main.async { onFinish?() }`로 상위까지 닫던 우회가 사라진다.

- [ ] **Step 5: NavigationLink가 남지 않았는지 확인**

Run:
```
grep -rn "NavigationLink" --include="*.swift" "Is This Red?/"
```
Expected: 출력 없음

- [ ] **Step 6: 빌드와 테스트**

Run:
```
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -project "Is This Red?.xcodeproj" -scheme "Is This Red?" -destination "platform=iOS Simulator,name=iPad Pro 13-inch (M5)" test 2>&1 | grep -E "error:|\*\* TEST"
```
Expected: `** TEST SUCCEEDED **`, 11개 통과

- [ ] **Step 7: 전체 플로우 손으로 확인**

1. 온보딩 Yes/No 다섯 번 → 두 번째 온보딩 → 네 번 탭 → 모드 선택
2. "See Through Their Eyes" → 그리기 → Next → 모드 피커 전환 → "Finish Your Experience" → **모드 선택 화면으로 한 번에 복귀**
3. "Draw As Them" → 모드 선택 → 그리기 → Reveal Reality → back → 다른 모드 → **빈 캔버스**

- [ ] **Step 8: 커밋**

```bash
git add "Is This Red?/Flow"
git commit -m "refactor: 모든 화면 전환을 AppCoordinator push로 통일"
```

---

## 완료 기준

- `grep -rn "NavigationLink" --include="*.swift" "Is This Red?/"` 결과가 비어 있다.
- `RootView`에 화면 전환용 `Bool` `@State`가 없다.
- 테스트 11개가 통과한다.
- 위 Task 7 Step 7의 세 가지 플로우가 이전과 동일하게 동작한다.
