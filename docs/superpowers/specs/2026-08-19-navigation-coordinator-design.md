# 화면 전환 Coordinator 도입 설계

작성일: 2026-08-19
대상: `Is This Red?` (SwiftUI, iPadOS, 약 1,100줄)

## 배경

화면 전환이 현재 두 가지 방식으로 흩어져 있다.

- **온보딩 단계** — `RootView`가 `didFinishFirst`, `didFinishOnboarding` 두 개의 `@State` bool로 만든 `if / else if / else` 상태 머신. 단계가 하나 늘 때마다 bool이 하나 늘고 분기가 하나 늘어난다.
- **화면 push** — `NavigationLink(destination:)` 직결. 출발 화면이 목적지 화면의 타입과 초기화 인자를 직접 안다.

두 방식 모두 전환 규칙이 뷰 안에 있어 뷰를 띄우지 않고는 검증할 수 없다. 이 프로젝트에서 뷰 없이 테스트 가능한 코드는 현재 `VisionSimulator` 하나뿐이다.

추가로 `NavigationStack`이 `ExperienceModeSelectView` 안에 있다. 이 화면 자체가 온보딩 이후 표시되는 화면이므로, 스택이 콘텐츠 안에 들어가 있는 형태다.

## 목표

1. 전환 결정을 뷰 밖의 단일 객체로 옮겨 **뷰 없이 테스트 가능**하게 만든다.
2. 목적지 조립을 한 곳으로 모아, 출발 화면이 목적지 타입을 모르게 한다.
3. 화면 간에 넘어가는 유일한 상태(`PKCanvasView`)를 인자 전달 대신 모델로 흡수한다.

## 비목표

- 화면 UI·레이아웃 변경. 이번 작업으로 눈에 보이는 동작은 달라지지 않는다.
- 딥링크, 상태 복원, URL 라우팅. 필요해지면 그때.
- `ColorblindDrawView`의 reveal·미션 로직을 뷰 밖으로 빼는 것. 별개 작업이다.

## 설계

### Route

```swift
enum Route: Hashable {
	case create
	case visionSim
	case visionModeSelect
	case colorblindDraw(VisionMode)
}
```

화면이 7개뿐이고 전부 열거형으로 표현되므로 `NavigationPath`(타입 소거) 대신 `[Route]`를 쓴다. 테스트에서 경로에 무엇이 쌓였는지 값으로 비교할 수 있어야 하고, 이것이 Coordinator를 도입하는 주된 이유이기 때문이다.

`PKCanvasView`는 `Route`에 싣지 않는다. `NSObject`라 `Hashable`을 만족하긴 하지만, 라우트의 동등성이 참조 동일성으로 변해 테스트가 UIKit 인스턴스를 만들어야 한다.

### AppCoordinator

```swift
@Observable
final class AppCoordinator {

	enum Stage {
		case onboardingFirst
		case onboardingSecond
		case experience
	}

	private(set) var stage: Stage = .onboardingFirst
	var path: [Route] = []

	func onboardingDidFinish()
	func push(_ route: Route)
	func popToRoot()
}
```

- `stage` — 온보딩 단계 교체. 외부에서 임의로 바꾸지 못하도록 `private(set)`.
- `path` — `NavigationStack`이 바인딩해야 하므로 `var`.
- `onboardingDidFinish()` — 현재 단계에서 다음 단계로. `.experience`에서 호출되면 아무 일도 하지 않는다.

`pop()`은 두지 않는다. 한 단계 뒤로 가기는 `NavigationStack`의 기본 back 버튼이 `path` 바인딩을 통해 처리하므로, 직접 호출할 곳이 없다. 필요해지면 그때 추가한다.

`MyApp`이 인스턴스를 만들어 `.environment()`로 주입한다.

### DrawingSession

```swift
@Observable
final class DrawingSession {

	/// 렌더 영역을 정하는 방식. 두 그리기 화면이 서로 다르게 요구한다.
	enum Framing: Equatable {
		case fittingDrawing(padding: CGFloat)
		case fixed(CGSize)
	}

	let canvas = PKCanvasView()
	private(set) var normalImage: UIImage?
	private(set) var simulatedImage: UIImage?

	func rect(for framing: Framing) -> CGRect
	func render(_ framing: Framing, mode: VisionMode)
}
```

`Framing`을 파라미터로 받는 이유는 실제 호출자가 둘이고 요구가 다르기 때문이다.

- `VisionSimView` — `.fittingDrawing(padding: 24)`. 그림 경계에 여백을 두른 영역.
- `ColorblindDrawView` — `.fixed(size)`. `GeometryReader`가 준 캔버스 크기 그대로.

두 경우 모두 그림이 비어 있으면 1024×1024 정사각형으로 대체한다. `rect(for:)`는 순수 함수이므로 이 규칙이 테스트 대상이 된다.

`render(_:mode:)`는 원본과 시뮬레이션 이미지를 만들어 저장하기만 한다. 둘 중 무엇을 보여줄지(reveal 토글)는 표시 결정이므로 뷰에 남는다.

#### 인스턴스는 둘, 타입은 하나

자유 드로잉과 미션 드로잉은 별개의 그림이다. 한 인스턴스를 공유하면 한쪽에서 그린 획이 다른 쪽에 나타난다.

| 사용처 | 획득 방식 | 수명 |
| --- | --- | --- |
| `CreateView` ↔ `VisionSimView` | `@Environment` (앱이 소유) | 두 화면이 공유 |
| `ColorblindDrawView` | `@State private var session = DrawingSession()` | 화면과 함께 생성·소멸 |

`ColorblindDrawView`가 `@State`로 소유하므로, 모드를 바꿔 다시 들어오면 새 캔버스로 시작한다. 현재 동작과 같다.

### RootView

`NavigationStack`이 `ExperienceModeSelectView`에서 `RootView`로 올라온다.

```swift
struct RootView: View {

	@Environment(AppCoordinator.self) private var coordinator

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

	private var experienceStack: some View {
		@Bindable var coordinator = coordinator
		return NavigationStack(path: $coordinator.path) {
			ExperienceModeSelectView()
				.navigationDestination(for: Route.self) { route in
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
		}
	}
}
```

`@Observable` 객체의 프로퍼티를 바인딩하려면 `@Bindable`이 필요하다.

목적지 조립은 이 `navigationDestination` 한 곳에만 존재한다.

### 화면별 변경

| 파일 | 변경 |
| --- | --- |
| `MyApp` | `AppCoordinator`, `DrawingSession` 생성 후 `.environment()` 주입 |
| `RootView` | bool 2개 삭제. `stage` 분기 + `NavigationStack` + `navigationDestination` |
| `OnboardingFirstView` | `@Binding didFinish` 삭제 → `coordinator.onboardingDidFinish()` |
| `OnboardingSecondView` | 위와 동일 |
| `ExperienceModeSelectView` | `NavigationStack` 제거. `modeButton`의 `NavigationLink` → `Button` + `push` |
| `CreateView` | `@State canvasView` 삭제 → 세션 사용. "Next" `NavigationLink` → `push(.visionSim)` |
| `VisionSimView` | `canvasView` 인자와 `onFinish` 클로저 삭제. 세션 사용. "Finish" → `popToRoot()` |
| `VisionModeSelectView` | `modeCard`의 `NavigationLink` → `Button` + `push(.colorblindDraw(mode))` |
| `ColorblindDrawView` | `@State canvasView` → `@State session`. 렌더 호출을 세션으로 |

`VisionSimView`의 `onFinish` 클로저와 `DispatchQueue.main.async { onFinish?() }`는 `popToRoot()` 한 줄로 대체되어 사라진다. `dismiss()`를 부른 뒤 상위 화면까지 닫으려고 비동기로 우회하던 코드였다.

## 데이터 흐름

| 상태 | 위치 | 근거 |
| --- | --- | --- |
| `stage`, `path` | `AppCoordinator` | 전환 결정 |
| 캔버스, 렌더 이미지 | `DrawingSession` | 화면 경계를 넘거나, 렌더 로직과 함께 있어야 함 |
| 도구(`DrawingTool`) | 각 뷰 `@State` | 화면 밖으로 나가지 않음 |
| reveal 토글, 미션 문구, 선택된 모드 | 각 뷰 `@State` | 표시 결정 |

## 테스트 계획

기존 3개에 7개를 더해 10개가 된다. 신규 7개는 모두 SwiftUI 뷰 없이 실행된다.

```
AppCoordinatorTests
  온보딩을_두_번_지나면_체험_단계로()
  체험_단계에서_더_진행해도_단계가_유지된다()
  push하면_경로에_목적지가_쌓인다()
  popToRoot는_경로를_비운다()

DrawingSessionTests
  빈_그림에_fittingDrawing이면_기본_정사각형()
  그림이_있으면_경계에_여백이_더해진다()
  fixed는_주어진_크기를_그대로_쓴다()
```

`AppCoordinator` 테스트는 UIKit·SwiftUI 어느 것도 필요 없다. `DrawingSession.rect(for:)` 테스트는 빈 `PKDrawing()`만 있으면 된다.

렌더 결과 이미지의 픽셀 검증은 하지 않는다. `VisionSimulator`가 이미 계수 단위로 검증되고 있고, 이미지 비교는 시뮬레이터 환경에 따라 흔들린다.

## 마이그레이션 순서

각 단계마다 빌드와 전체 테스트가 통과하는 커밋을 남긴다. 어느 단계가 과했는지 되돌릴 수 있어야 한다.

1. `AppCoordinator` + 테스트 4개. 아직 아무도 쓰지 않는다.
2. `DrawingSession` + 테스트 3개. 아직 아무도 쓰지 않는다.
3. `MyApp` 주입, `RootView`를 `stage` 분기로 교체, 온보딩 두 화면 배선. bool 2개 삭제.
4. `NavigationStack`을 `RootView`로 이전, `navigationDestination` 추가. 기존 `NavigationLink`는 아직 그대로 둔다.
5. 각 화면의 `NavigationLink`를 `push`로 교체. 이 단계가 끝나면 앱에 `NavigationLink(destination:)`이 남지 않는다.
6. `CreateView`, `VisionSimView`를 세션으로. `onFinish`·`dismiss` 우회 제거.
7. `ColorblindDrawView`를 세션으로.

3~5단계 사이에는 두 전환 방식이 잠시 공존한다. 5단계에서 정리된다.

## 기각한 대안

| 대안 | 기각 사유 |
| --- | --- |
| `NavigationPath` | 내용을 꺼내 볼 수 없어 테스트에서 개수만 확인 가능. 도입 목적과 충돌 |
| `Route`에 `PKCanvasView` 동봉 | 라우트 동등성이 참조 동일성이 되고, 테스트가 UIKit 인스턴스를 요구 |
| push 경로만 Coordinator | `RootView`의 bool 증식 문제가 남음 |
| 온보딩 단계만 Coordinator | push 전환이 여전히 테스트 불가 |
| `DrawingSession` 단일 인스턴스 공유 | 자유 드로잉과 미션 드로잉의 획이 서로 섞임 |
| TCA / Clean Architecture | 1,100줄 앱에 보일러플레이트가 실제 코드보다 커짐. 감쌀 데이터 소스도 없음 |

## 완료 기준

- 앱에 `NavigationLink(destination:)`이 남아 있지 않다.
- `RootView`에 화면 전환용 `Bool` `@State`가 없다.
- 테스트 10개가 통과한다.
- 온보딩 → 모드 선택 → 두 갈래 플로우 → 복귀가 손으로 확인했을 때 이전과 동일하게 동작한다.
