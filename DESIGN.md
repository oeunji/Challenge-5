# Design

**Is This Red?** 는 색각 이상을 *설명*하지 않고 *겪게* 하는 iPad 앱이다.
이 문서는 화면이 왜 지금의 모습인지를 다룬다. 토큰의 실제 값은
[`docs/design-system.md`](docs/design-system.md)에, 코드 구조는
[`docs/architecture.md`](docs/architecture.md)에 있다.

## 하나뿐인 제약

**UI가 색만으로 정보를 전달하면 이 앱은 자기 주제를 배반한다.**

색각 이상을 체험시키는 앱에서 "선택된 항목은 빨강"이라고 말하는 순간, 그 UI는
앱이 설명하려는 바로 그 사용자를 배제한다. 그래서 선택·활성·경고 같은 상태는 항상
색 **더하기** 다른 단서로 표현한다.

| 상태 | 색 | 함께 쓰는 단서 |
| --- | --- | --- |
| 선택된 그리기 도구 | 파랑 | — (아이콘만, 아래 "열린 결정" 참고) |
| 선택된 색상 스와치 | — | 크기 20→24pt, 흰 링 2pt, 그림자 |
| 눌린 버튼 | 채움 22→18% | 크기 0.98배, 그림자 축소 |
| 선택된 세그먼트 | 흰 배경 | 굵기 Regular→Semibold |

파랑이 반복해서 등장하는 것도 의도에 가깝다. 적록색각 이상에서 빨강과 초록은 서로
수렴하지만 파랑은 대부분의 유형에서 구분된다. 상태 표시에 브랜드 레드(`#E63946`)를
쓰지 않은 이유다.

같은 이유로 **본문 대비를 4.5:1 아래로 내리지 않는다.** 한때 부제가 `Shadow`(검정 25%,
1.8:1)를 쓰다가 `OnSurfaceVariant`(#5F5F5F, 6.4:1)를 따로 만들어 옮겼다.

## 화면 흐름

```
OnboardingFirst  →  OnboardingSecond  →  ExperienceModeSelect
                                              ├─ Create → VisionSim          (See Through Their Eyes)
                                              └─ VisionModeSelect → ColorblindDraw  (Draw As Them)
```

두 갈래는 서로를 참조하지 않는다. 같은 질문을 반대 방향에서 던진다 —
**남이 내 그림을 어떻게 보는가** / **내가 남처럼 보면 어떻게 그리게 되는가.**

### 1. OnboardingFirst — 질문

전면 색 배경에 "Is This Red?"가 다섯 줄 겹쳐 있고, 각 줄의 불투명도가 0.855에서
0.423까지 떨어진다. 확신이 옅어지는 모양이다.

`Yes` / `No` 어느 쪽을 눌러도 다음 배경으로 넘어간다. **정답이 없다는 것이 이 화면의
전부다.** 다섯 색 중 세 개(`#B7BE28` `#D6DB2F` `#B7BE28`)는 빨강이 아니라 황록인데,
이건 오류가 아니라 적록색각 이상이 보는 "빨강"이다. 한 바퀴를 돌면 온보딩이 끝난다.

### 2. OnboardingSecond — 답

검정 배경. 탭할 때마다 한 줄씩 드러난다.

> Were Those Real Red? → They were all Red. → The color you see isn't the color
> everyone sees. → Start Experience

마지막 줄만 Bold로 무게를 준다. 순검정 배경은 앞 화면의 색 잔상을 지우는 역할이라
`OnSurface`(#131313)가 아니라 리터럴 `Color.black`을 쓴다.

### 3. ExperienceModeSelect — 갈림길

모눈 배경 위에 로고, 한 문장, 두 장의 카드. 여기서부터 앱의 표면은 흰 모눈종이가 된다 —
그리기 앱이라는 신호이자, 색이 주인공이므로 배경은 최대한 물러나 있어야 한다는 판단이다.

### 4·5. See Through Their Eyes — Create → VisionSim

`Create`는 PencilKit 캔버스가 화면 전체를 차지하고, 도구 막대는 네비게이션 바
가운데(`.principal`)에 들어간다. 그림 그릴 면적을 한 픽셀이라도 더 확보하기 위해서다.

`VisionSim`은 같은 그림을 **Normal과 선택한 모드로 나란히** 보여준다. 비교가 목적이라
두 미리보기는 항상 같은 크기다.

### 6·7. Draw As Them — VisionModeSelect → ColorblindDraw

`ColorblindDraw`가 이 앱에서 가장 공들인 화면이다. 세 가지가 동시에 일어난다.

- **캔버스는 거의 투명하다**(`opacity 0.02`). 사용자가 보는 것은 시뮬레이션을 거친 이미지다.
- **팔레트 스와치도 시뮬레이션된 색으로 그려진다.** Protanopia에서는 빨강과 초록 스와치가
  둘 다 황록으로 보인다. 색을 고르는 행위 자체가 어려워지는 것이 이 화면의 미션이다.
- **팔레트 순서가 매번 섞인다**(검정만 고정). 위치로 색을 외우는 우회로를 막는다.

미션은 "Design a traffic light." "Create a red and green warning sign." 처럼
적록 구분이 필요한 것들이다. `Reveal Reality`를 누르면 정상 시야와 비교할 수 있다.

## 비주얼 언어

**모눈 배경** — 흰 바탕에 32pt 간격 `#F5F5F5` 격자. 선택 화면 두 곳에서만 쓴다.
그리기 화면은 실제 캔버스라 격자가 없다.

**카드 서피스** — 흰 채움 + `Outline` 1.5pt 테두리. 그림자를 쓰지 않는다. 모눈 위에
떠 있는 종이가 아니라 모눈에 놓인 종이로 보이게 하려는 것이다.

**유리 버튼** — 온보딩에서만. 색 배경 위에 흰색 22% 채움과 35% 테두리를 얹어, 버튼이
배경색을 가리지 않고 통과시킨다. 배경색이 콘텐츠인 화면이라 버튼이 그것을 덮으면 안 된다.

**SF Pro Rounded** — 사용자에게 행동을 요구하는 문구에만 쓴다(`Next`, `Reveal Reality`,
`Choose a Vision Mode`, 미션 문구). 나머지는 SF Pro. 둥근 서체가 지시를 부드럽게 만든다.

**타이포는 전부 Dynamic Type이다.** 고정 크기(`Font.system(size:)`)를 쓰지 않는다.
접근성 앱이 접근성 설정을 무시하면 곤란하다.

## 플랫폼 결정

**iPad 가로 전용.** 그리기에 필요한 면적과 `VisionSim`의 나란한 비교 때문이다.
세로에서는 미리보기 두 장을 같은 크기로 놓을 수 없다.

**라이트 모드 고정**(`preferredColorScheme(.light)`). 색 비교가 주제인 앱에서 표면 색이
시스템 설정에 따라 변하면 비교 자체가 흔들린다. 그래서 컬러 토큰에 다크 모드 값이 없다.

## Figma

파일: [스스챌](https://www.figma.com/design/PYgPXCSRmgkM1VK1XtZ3e7/%EC%8A%A4%EC%8A%A4%EC%B1%8C)

| 래퍼 | 내용 |
| --- | --- |
| `디자인 시스템` | Color · Spacing · Border Radius · Typography · Effects 토큰 문서 |
| `Onboarding 1` | 배경색 5단계 |
| `Onboarding 2` | 문장 공개 4단계 |
| `Home` | ExperienceModeSelect |
| `See Through Their Eyes` | Create · VisionSim |
| `Draw As Them` | VisionModeSelect · ColorblindDraw |

**Figma가 토큰의 원본이다.** 값을 바꾸려면 Figma를 먼저 고치고 코드를 따라가게 한다.

정적 프레임으로 표현할 수 없는 것 세 가지는 옮기지 않았다 — 탭에 따른 전환 애니메이션,
사용자가 그 자리에서 그리는 그림, 조건부로만 나타나는 요소(`revealPicker`). 상태가
여럿인 화면은 프레임을 나눠 단계별로 그렸다.

## 열린 결정

- **`DrawingToolbar`의 선택 색이 `.blue` 리터럴이다.** 파랑을 유지하는 데는 접근성 근거가
  있지만, 지금 코드에는 그 근거가 남아 있지 않아 다음 사람이 브랜드색으로 바꾸기 쉽다.
  `semantic/selected` 토큰으로 승격할지 미결.
- **브랜드 팔레트가 화면에 없다.** `PrimaryBase` `PrimaryContainer` `Accent`가 정의만 되어
  있고 쓰이지 않는다. 앱의 실제 색은 온보딩의 하드코딩 5색과 중립 톤뿐이다.
- **`VisionSim`의 세로 여백.** 미리보기 변을 가로 기준으로만 계산해서 iPad 가로에서는
  아래가 항상 남는다.
- **`ExperienceModeSelect`의 하단 여백.** 콘텐츠가 중앙보다 위에 뭉쳐 있다.
