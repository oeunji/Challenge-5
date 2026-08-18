# Swift Style Guide (StyleShare) — Full Reference

Source: [StyleShare/swift-style-guide](https://github.com/StyleShare/swift-style-guide), licensed [CC-BY-4.0](http://creativecommons.org/licenses/by/4.0/), © 전수열 & StyleShare. Condensed for this project; consult the source repo for the canonical, up-to-date text.

## 코드 레이아웃

### 들여쓰기 및 띄어쓰기

- 들여쓰기에는 탭(tab) 대신 2개의 space를 사용합니다.
- 콜론(`:`)을 쓸 때에는 콜론의 오른쪽에만 공백을 둡니다.

  ```swift
  let names: [String: String]?
  ```

- 연산자 오버로딩 함수 정의에서는 연산자와 괄호 사이에 한 칸 띄어씁니다.

  ```swift
  func ** (lhs: Int, rhs: Int)
  ```

### 줄바꿈

- 함수 정의가 최대 길이를 초과하면 파라미터마다 줄바꿈합니다.

  ```swift
  func collectionView(
    _ collectionView: UICollectionView,
    cellForItemAt indexPath: IndexPath
  ) -> UICollectionViewCell {
    // doSomething()
  }
  ```

- 함수 호출이 최대 길이를 초과하면 파라미터 이름을 기준으로 줄바꿈합니다.

  ```swift
  let actionSheet = UIActionSheet(
    title: "정말 계정을 삭제하실 건가요?",
    delegate: self,
    cancelButtonTitle: "취소",
    destructiveButtonTitle: "삭제해주세요"
  )
  ```

  파라미터에 클로저가 2개 이상이면 무조건 내려쓰기합니다.

  ```swift
  UIView.animate(
    withDuration: 0.25,
    animations: {
      // doSomething()
    },
    completion: { finished in
      // doSomething()
    }
  )
  ```

- `if let`이 길면 줄바꿈하고 한 칸 들여씁니다.

  ```swift
  if let user = self.veryLongFunctionNameWhichReturnsOptionalUser(),
     let name = user.veryLongFunctionNameWhichReturnsOptionalName(),
    user.gender == .female {
    // ...
  }
  ```

- `guard let`이 길면 줄바꿈하고 한 칸 들여씁니다. `else`는 `guard`와 같은 들여쓰기.

  ```swift
  guard let user = self.veryLongFunctionNameWhichReturnsOptionalUser(),
        let name = user.veryLongFunctionNameWhichReturnsOptionalName(),
        user.gender == .female
  else {
    return
  }
  ```

### 최대 줄 길이

- 한 줄은 최대 99자.

### 빈 줄

- 빈 줄에는 공백을 포함하지 않습니다.
- 모든 파일은 빈 줄로 끝납니다.
- `// MARK:` 위아래에는 빈 줄을 둡니다.

### 임포트

시스템 프레임워크를 먼저, 빈 줄로 구분해 서드파티 프레임워크를 알파벳 순으로.

```swift
import UIKit

import SwiftyColor
import SwiftyImage
import Then
import URLNavigator
```

## 네이밍

### 클래스와 구조체

- UpperCamelCase, 접두사(Prefix) 없음.

  ```swift
  class SomeClass { }
  struct SomeStructure { }
  ```

### 함수

- lowerCamelCase, `get` 접두사는 되도록 지양.

  ```swift
  func name(for user: User) -> String?   // 좋은 예
  func getName(for user: User) -> String? // 나쁜 예
  ```

- Action 함수는 '주어 + 동사 + 목적어' 형태.
  - *Tap*(눌렀다 뗌) → `.touchUpInside`, *Press*(누름) → `.touchDown`
  - *will~* = 행위 직전, *did~* = 행위 직후, *should~* = 대개 `Bool` 반환

  ```swift
  func backButtonDidTap() { }   // 좋은 예
  func back() { }               // 나쁜 예
  func pressBack() { }          // 나쁜 예
  ```

### 변수 / 상수

- 둘 다 lowerCamelCase.

  ```swift
  let maximumNumberOfLines = 3   // 좋은 예
  let MAX_LINES = 3              // 나쁜 예
  ```

### 열거형

- enum 이름은 UpperCamelCase, case는 lowerCamelCase.

  ```swift
  enum Result {
    case success
    case failure
  }
  ```

### 프로토콜

- UpperCamelCase. 채택 시 콜론 뒤 공백으로 구분 (struct/class/extension 모두 동일).

  ```swift
  struct SomeStructure: SomeProtocol, AnotherProtocol { }
  extension UIViewController: SomeProtocol, AnotherProtocol { }
  ```

### 약어

- 약어로 시작하면 소문자, 그 외에는 대문자.

  ```swift
  let userID: Int?          // 좋은 예 (Id 아님)
  let urlString: String?    // 좋은 예 (URL아님, 시작하는 약어라 소문자)
  let websiteURL: URL?      // 좋은 예
  ```

### Delegate

- Delegate 메서드는 프로토콜명으로 네임스페이스를 구분.

  ```swift
  protocol UserCellDelegate {
    func userCellDidSetProfileImage(_ cell: UserCell)
    func userCell(_ cell: UserCell, didTapFollowButtonWith user: User)
  }
  ```

## 클로저

- 파라미터/리턴 타입이 없으면 `() -> Void`.

  ```swift
  let completionBlock: (() -> Void)?          // 좋은 예
  let completionBlock: (() -> ())?            // 나쁜 예
  ```

- 파라미터에 괄호 사용 안 함: `{ operation, responseObject in ... }` (`{ (operation, responseObject) in ... }` 금지).
- 가능하면 타입 정의 생략: `completion: { finished in ... }` (`{ (finished: Bool) -> Void in ... }` 금지).
- 유일한/마지막 클로저 파라미터는 이름 생략(trailing closure):

  ```swift
  UIView.animate(withDuration: 0.5) {
    // doSomething()
  }
  ```

## 클래스와 구조체

- 클래스/구조체 내부에서 `self`를 명시적으로 사용.
- Swift 네이티브 생성자 사용:

  ```swift
  let frame = CGRect(x: 0, y: 0, width: 100, height: 100)  // 좋은 예
  let frame = CGRectMake(0, 0, 100, 100)                    // 나쁜 예
  ```

## 타입

- `Array<T>` / `Dictionary<T, U>` 대신 `[T]` / `[T: U]`.

## 주석

- `///`: 문서화 주석.
- `// MARK:`: 연관된 코드를 구분 (Objective-C `#pragma mark`와 동일한 역할).

  ```swift
  // MARK: Init

  override init(frame: CGRect) { }
  deinit { }

  // MARK: Layout

  override func layoutSubviews() { }

  // MARK: Actions

  override func menuButtonDidTap() { }
  ```

## 프로그래밍 권장사항

- 변수는 선언과 동시에 초기화. ([Then](https://github.com/devxoul/Then) 같은 초기화 헬퍼 활용)
- 관련 상수는 `enum`으로 묶어 재사용성·유지보수성을 높입니다 (`struct` 대신 `enum`을 쓰는 이유: 생성자 없는 타입으로 강제).

  ```swift
  final class ProfileViewController: UIViewController {

    private enum Metric {
      static let profileImageViewLeft = 10.f
      static let profileImageViewRight = 10.f
    }

    private enum Font {
      static let nameLabel = UIFont.boldSystemFont(ofSize: 14)
    }

    private enum Color {
      static let nameLabelText = 0x000000.color
    }
  }
  ```

  ```swift
  self.profileImageView.frame.origin.x = Metric.profileImageViewLeft
  self.nameLabel.font = Font.nameLabel
  self.nameLabel.textColor = Color.nameLabelText
  ```

- 더 이상 상속되지 않는 클래스는 항상 `final`로 선언.
- 프로토콜 채택 시 관련 메서드를 모아 별도 extension으로 분리:

  ```swift
  final class MyViewController: UIViewController { }

  // MARK: - UITableViewDataSource

  extension MyViewController: UITableViewDataSource { }

  // MARK: - UITableViewDelegate

  extension MyViewController: UITableViewDelegate { }
  ```

  (한 선언부에 `UIViewController, UITableViewDataSource, UITableViewDelegate`를 다 나열하는 방식은 지양)
