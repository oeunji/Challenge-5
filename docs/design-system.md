# Design System

Figma 파일 [스스챌](https://www.figma.com/design/PYgPXCSRmgkM1VK1XtZ3e7/%EC%8A%A4%EC%8A%A4%EC%B1%8C)의
`Token Documentation` 프레임들이 원본이고, 이 문서는 그 코드 대응표다.

## The rule

**UI 코드에 색·크기·여백 숫자를 새로 만들지 않는다.** 아래 네 곳에서만 가져다 쓴다.

| 종류 | 출처 | 사용 |
| --- | --- | --- |
| 색 | `Assets.xcassets` 컬러셋 | `Color("PrimaryBase")` |
| 폰트 | `DesignSystem/Typography.swift` | `.font(Typography.title2)` |
| 여백 | `DesignSystem/Spacing.swift` | `.padding(Spacing.x16)` |
| 그림자 | `DesignSystem/Elevation.swift` | `.deepElevation()` |

토큰에 없는 값이 필요하면 임의로 반올림하지 말고 **먼저 물어볼 것.** 어떤 값이 왜 안 맞는지
알려주면 토큰을 늘릴지 사람이 결정한다. 조용히 `Spacing.x16`으로 뭉개면 1pt 어긋난 원인을
나중에 아무도 못 찾는다.

## Color

Figma: `Token Documentation — Color` (node `60:39`). 값은 전부 `Assets.xcassets`의 컬러셋이다.

| 에셋 | Hex | Figma 토큰 | 역할 |
| --- | --- | --- | --- |
| `PrimaryBase` | `#E63946` | primary/base | 브랜드 핵심색, CTA, 강조 |
| `PrimaryContainer` | `#FFEBEE` | primary/container | 강조 요소의 옅은 배경 |
| `OnPrimary` | `#FFFFFF` | primary/on-primary | Primary 위에 얹는 전경색 |
| `Surface` | `#FFFFFF` | neutral/surface | 기본 배경 |
| `SurfaceVariant` | `#F5F5F5` | neutral/surface-variant | 한 단계 눌린 배경 |
| `OnSurface` | `#131313` | neutral/on-surface | 본문 텍스트 |
| `Outline` | `#E0E0E0` | neutral/outline | 구분선, 테두리 |
| `Accent` | `#B71C1C` | semantic/accent | 어두운 악센트 |
| `Shadow` | `#000000` α0.25 | semantic/shadow | 그림자 색 |

다크 모드 대응은 없다(universal 하나). 앱이 `MyApp`에서 `preferredColorScheme(.light)`로
고정돼 있기 때문이며, 그 이유는 `architecture.md`에 있다.

### 색만으로 정보를 전달하지 말 것

이 앱은 색각 이상을 체험시키는 앱이다. UI 자체가 색에만 의존하면 앱이 자기 주제를 배반한다.

선택 상태, 활성/비활성, 경고는 **색 + 색이 아닌 단서**(아이콘, 굵기, 테두리, 위치)를 함께 쓴다.
`PrimaryBase`와 `Accent`는 적록색각 이상에서 서로 구분되지 않는다.

## Spacing

Figma: `Token Documentation — Spacing` (node `60:99`). 8pt 그리드.

`Spacing.x4` `x8` `x16` `x24` `x32` `x48` `x64` — 이름의 숫자가 곧 pt 값이고
Figma의 `spacing/16` ↔ `Spacing.x16`으로 대응한다.

## Typography

Figma: `Token Documentation — Typography` (node `60:166`). 애플 Dynamic Type 11단계, SF Pro.

| `Typography` | SwiftUI | 크기/행간 | 자간 |
| --- | --- | --- | --- |
| `largeTitle` | `.largeTitle` | 34/41 | +0.40 |
| `title1` | **`.title`** | 28/34 | +0.36 |
| `title2` | `.title2` | 22/28 | +0.35 |
| `title3` | `.title3` | 20/25 | +0.38 |
| `headline` | `.headline` | 17/22 Semibold | −0.43 |
| `body` | `.body` | 17/22 | −0.43 |
| `callout` | `.callout` | 16/21 | −0.31 |
| `subheadline` | `.subheadline` | 15/20 | −0.23 |
| `footnote` | `.footnote` | 13/18 | −0.08 |
| `caption1` | **`.caption`** | 12/16 | 0 |
| `caption2` | `.caption2` | 11/13 | +0.06 |

크기·자간은 iOS Large(기본) 기준 참고값이다. 실제 값은 시스템이 정한다.

**`Typography`가 존재하는 이유는 굵은 두 칸이다.** Figma의 `Title 1`은 SwiftUI에서 `.title1`이
아니라 `.title`, `Caption 1`은 `.caption`이다. 나머지 9개는 이름이 같아 사실상 얇은 래퍼다.

**`Font.system(size:)`를 쓰지 말 것.** 고정 크기는 사용자 글자 크기 설정을 무시한다.
반대로 Dynamic Type은 글자가 커지면 레이아웃이 늘어나므로, 텍스트를 담는 컨테이너에
`.frame(height:)` 고정을 걸면 큰 글자에서 잘린다.

## Elevation

Figma: `Token Documentation — Effects` (node `60:193`).

```swift
card.deepElevation()                              // Elevation/Deep
Color.clear.glossyElevation(fill: Color("PrimaryBase"))  // Elevation/Glossy
```

| 토큰 | Figma | SwiftUI |
| --- | --- | --- |
| Deep | Drop · blur 40 · y10 · 검정 15% | `radius: 20, y: 10` |
| Glossy | Inner · blur 4 · y2 · 흰색 40% | `.inner(radius: 2, y: 2)` |
| Glossy | Drop · blur 8 · y4 · 검정 10% | `radius: 4, y: 4` |

**Figma blur는 SwiftUI radius의 두 배다.** Figma/CSS의 blur는 표준편차의 2배 기준이고
SwiftUI `radius`는 표준편차 기준이라, 그대로 옮기면 그림자가 두 배로 번진다. 새 그림자 토큰을
옮길 때도 반으로 나눈다.

`glossyElevation`만 `fill`과 `shape`를 받는 이유: SwiftUI에서 inner shadow는 `ShapeStyle`에만
붙일 수 있어(`fill.shadow(.inner(...))`) 배경 도형까지 이 메서드가 직접 그려야 한다.
`shape` 기본값은 Figma 카드와 같은 `RoundedRectangle(16, .continuous)`.
`deepElevation`은 순수 그림자라 아무 뷰에나 붙는다.

## 아직 이관되지 않은 코드

토큰은 갖춰졌지만 화면은 대부분 아직 하드코딩 상태다. **기존 코드가 곧 본보기라고 가정하지 말 것.**

- `Features/`와 `Components/`에 하드코딩된 `.font(...)` 17곳
- 하드코딩된 padding/spacing 숫자 16곳
- `Components/Theme.swift`의 `AppColor` — RGB 직접 입력이고 컬러셋과 값이 다르다
  (`title` `subtitle` `cardBorder` `grid`). 이관 시 두 값 중 무엇이 맞는지 확인이 필요하다.

이관은 화면 단위로 한다. 한 파일씩, 레이아웃 결과는 그대로 두고 값의 출처만 바꾼 뒤 빌드한다.
디자인 변경과 값 이관을 같은 커밋에 섞으면 무엇이 화면을 깨뜨렸는지 가릴 수 없다.

## 토큰 추가하기

1. Figma의 해당 `Token Documentation` 프레임에 먼저 추가한다. 원본은 Figma다.
2. 컬러면 `Assets.xcassets`에 컬러셋을, 나머지는 `DesignSystem/`의 해당 파일에 상수를 추가한다.
3. 이 문서의 표를 갱신한다.
