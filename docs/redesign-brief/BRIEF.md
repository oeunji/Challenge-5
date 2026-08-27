# Redesign brief — Is This Red?

Stitch에 붙여넣을 프롬프트다. 아래 **Prompt** 블록을 그대로 쓰고,
`screens/` 의 PNG를 해당 화면의 참조 이미지로 함께 올린다.

한 번에 7개를 다 던지지 말고 **화면 하나씩** 돌린다. 공통 규칙(Part 1)을 매번 앞에 붙이고
그 화면 섹션만 이어 붙이면 된다.

---

## Prompt — Part 1 : 매 요청에 붙이는 공통 규칙

```
iPad app, LANDSCAPE only, 1376 x 1032 pt canvas. Light mode only — do not
produce a dark variant. Do not produce a phone layout.

This app makes people EXPERIENCE color-vision deficiency rather than read about
it. That is a hard design constraint, not a theme:

- NEVER convey state by color alone. Pair color with icon, weight, border,
  size, or position.
- NEVER rely on red-vs-green contrast to distinguish two things.
- Body text contrast must be at least 4.5:1.

Colors — use only these:
  Surface          #FFFFFF
  Surface variant  #F5F5F5
  On surface       #131313   (primary text)
  On surface var   #5F5F5F   (secondary text)
  Outline          #E0E0E0   (borders, dividers)
  Brand            #E63946   (currently unused in the UI — see goals)
  Brand container  #FFEBEE
  Accent           #B71C1C

Type — Apple Dynamic Type, SF Pro. Sizes in pt:
  34 / 28 / 22 / 20 / 17 semibold / 17 / 16 / 15 / 13 / 12
  SF Pro Rounded is reserved for action words only (buttons, prompts, missions).

Spacing scale: 4 8 12 16 24 32 48 64
Corner radius: 8 (small chrome) / 16 (buttons, cards) / 24 (large cards) / pill
Elevation:  soft — y10 blur40 black 15%   |   glossy — inner white 40% + y4 blur8 black 10%

Keep the existing information architecture and copy. Redesign layout, hierarchy
and use of space — do not invent new features or rename screens.
```

## Prompt — Part 2 : 전체 목표

```
Overall goals for this redesign:

1. Use the horizontal space. Every screen is currently a narrow centered column
   on a 1376pt-wide canvas, leaving large empty margins left and right.
2. Fix vertical dead space. Two screens leave 180-300pt empty at the bottom.
3. Put the brand color to work. #E63946 is defined but never used; the UI is
   currently all neutral greys. Introduce it where it aids hierarchy — but never
   as the only signal for a state.
4. Strengthen hierarchy inside cards. Cards are currently identical rectangles
   with a title and one line of grey text; nothing guides the eye to a choice.
```

---

## 화면별 (참조 이미지와 함께)

### 1. Onboarding — Question · `screens/1-onboarding-question.png`

```
Full-bleed color background that changes on every tap. "Is This Red?" repeats 5
times, fading from 86% to 42% opacity, then "Choose Your Answer" below. Two
glass buttons, Yes and No, at the bottom.

Both answers advance — there is no correct answer, and that is the point of the
screen. Three of the five background colors are yellow-green, not red: they are
what red looks like with red-green color blindness. Keep the background as the
only content; anything placed on it must not hide it (hence the translucent
glass buttons).

Redesign goal: make the repeated fading title feel intentional rather than
accidental, and make the two answers feel equally weighted.
```

### 2. Onboarding — Answer · `screens/2-onboarding-answer.png`

```
Pure black background. Four lines appear one at a time on tap:
  "Were Those Real Red?" / "They were all Red." /
  "The color you see isn't the color everyone sees." / "Start Experience"
Only the last line is bold — it is the call to action.

Pure black is deliberate: it wipes the color afterimage from the previous
screen. Keep it.

Redesign goal: the four lines are currently the same size and centered as one
block. Give the reveal a sense of progression, and make the last line read as a
button without adding a heavy control.
```

### 3. Experience Select · `screens/3-experience-select.png`

```
Graph-paper background (32pt grid, #F5F5F5 on white). Logo, then the line
"The color you see isn't the color everyone sees.", then "Choose Your
Experience", then two cards side by side:

  "See Through Their Eyes" — Simulate how your drawing looks to them
  "Draw As Them"           — Draw with color-vision limits

The two cards are the two halves of the app: how others see my drawing, versus
how I would draw with their vision.

Redesign goal (highest priority screen): content sits in the upper middle and
about 300pt of the bottom is empty. The two cards are 400pt wide on a 1376pt
canvas. Make the two choices feel substantial and distinct from each other —
they are the main decision in the app.
```

### 4. Create · `screens/4-create.png`

```
Full-screen drawing canvas (Apple Pencil / finger). The drawing toolbar sits
centered in the navigation bar: undo, redo | pencil, pen, brush, eraser, lasso |
6 color swatches | width slider. "Next" sits at the top right. A hint line on
translucent material sits at the bottom: "Feel free to draw, and tap the Next
button when you're done."

The canvas must stay as large as possible — that is why the toolbar lives in the
nav bar rather than in its own row.

Redesign goal: the toolbar is a single 669pt strip of small grey icons and reads
as undifferentiated. Group it so tools, colors and size are legible at a glance,
without stealing canvas area.
```

### 5. Vision Sim · `screens/5-vision-sim.png`

```
Title "See Through Their Eyes". A segmented control picks the vision type:
Protanopia / Deuteranopia / Tritanopia / Achromatopsia. Below it the user's
drawing appears twice side by side — "Normal" on the left, the simulated version
on the right. A "Finish Your Experience" button at the bottom.

The two previews must always be the same size; the whole point is comparison.

Redesign goal: the previews are sized from the width only, so about 180pt of
height goes unused. Make the comparison fill the screen and make it obvious
which side is which — without relying on color to label them.
```

### 6. Vision Mode Select · `screens/6-vision-mode-select.png`

```
Graph-paper background. Title "Choose a Vision Mode" in rounded type, then four
cards in a 2x2 grid:

  Protanopia    — Reduced sensitivity to red.
  Deuteranopia  — Reduced sensitivity to green.
  Tritanopia    — Reduced sensitivity to blue.
  Achromatopsia — No color perception.

Redesign goal: the four cards are identical white rectangles, so the user has
nothing to choose between except reading four sentences. Give each mode a
visual identity that shows what it does — but remember the audience may not
distinguish the very colors being described, so a color chip alone will not work.
```

### 7. Colorblind Draw · `screens/7-colorblind-draw.png`

```
Title "Mode: Protanopia". Same drawing toolbar as screen 4, but here the color
swatches are rendered THROUGH the simulation — under Protanopia the red and the
green swatch both look yellow-green, and the palette order is reshuffled every
session so the user cannot memorize positions. Picking a color is meant to be
hard; that is the exercise.

A frosted "Mission" card floats at the top left with a task like "Design a
traffic light." A "Reveal Reality" button at the bottom reveals the true colors
for comparison.

Redesign goal: the mission is the reason the user is on this screen, but the
card is a small translucent box in a corner. Give the mission presence without
covering the canvas, and make "Reveal Reality" feel like the reward it is.
```

---

## 주의

- **1376 x 1032 landscape**를 빼먹으면 Stitch가 폰 레이아웃을 낸다. 매번 첫 줄에 넣는다.
- Stitch 결과에는 Dynamic Type, `.continuous` 모서리, PencilKit 캔버스 같은 iOS 고유
  속성이 담기지 않는다. 시안으로만 쓰고 코드로 되돌릴 때 토큰에 맞춰 정리한다.
- 스크린샷은 현재 Figma 상태 그대로다. 코드가 바뀌면 다시 뽑아야 한다.
