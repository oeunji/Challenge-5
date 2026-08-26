//
//  DrawingFlowUITests.swift
//  Is This Red?UITests
//

import XCTest

/// 두 그리기 플로우에서 실제로 획을 긋는다.
///
/// 획 하나가 앱을 죽인 적이 있다. 앱 수명을 갖는 객체가 만든 `PKCanvasView`를
/// `UIViewRepresentable`에 넘긴 탓에, 화면이 다시 만들어지면 같은 뷰가 재호스팅되어
/// 터치 전달이 깨졌다. 화면 진입까지만 확인하는 테스트로는 잡히지 않는다.
final class DrawingFlowUITests: XCTestCase {

    // MARK: - Setup

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    // MARK: - Tests

    @MainActor
    func testFreeDrawFlowSurvivesAStroke() throws {
        let app = XCUIApplication()
        app.launch()
        skipOnboarding(in: app)

        app.staticTexts["See Through Their Eyes"].tap()
        XCTAssertTrue(
            app.buttons["Next"].waitForExistence(timeout: 5),
            "CreateView가 뜨지 않았다"
        )

        drawStroke(in: app)
        XCTAssertEqual(app.state, .runningForeground, "획을 그은 뒤 앱이 죽었다")

        // 그림이 값으로 다음 화면까지 건너가는지 확인한다
        app.buttons["Next"].tap()
        XCTAssertTrue(
            app.staticTexts["Normal"].waitForExistence(timeout: 5),
            "VisionSimView가 비교 화면을 그리지 못했다"
        )
    }

    @MainActor
    func testMissionFlowSurvivesAStroke() throws {
        let app = XCUIApplication()
        app.launch()
        skipOnboarding(in: app)

        app.staticTexts["Draw As Them"].tap()
        XCTAssertTrue(
            app.staticTexts["Protanopia"].waitForExistence(timeout: 5),
            "모드 선택 화면이 뜨지 않았다"
        )

        app.staticTexts["Protanopia"].tap()
        XCTAssertTrue(
            app.staticTexts["Mission"].waitForExistence(timeout: 5),
            "ColorblindDrawView가 뜨지 않았다"
        )

        drawStroke(in: app)
        XCTAssertEqual(app.state, .runningForeground, "획을 그은 뒤 앱이 죽었다")
    }

    // MARK: - Helpers

    /// 온보딩 두 화면을 지나 모드 선택까지 간다.
    private func skipOnboarding(in app: XCUIApplication) {
        for _ in 0..<5 {
            app.buttons["Yes"].tap()
        }
        for _ in 0..<4 {
            app.tap()
        }
        XCTAssertTrue(
            app.staticTexts["Choose Your Experience"].waitForExistence(timeout: 5),
            "모드 선택 화면에 도달하지 못했다"
        )
    }

    private func drawStroke(in app: XCUIApplication) {
        let start = app.coordinate(withNormalizedOffset: CGVector(dx: 0.35, dy: 0.5))
        let end = app.coordinate(withNormalizedOffset: CGVector(dx: 0.65, dy: 0.6))
        start.press(forDuration: 0.15, thenDragTo: end)
    }
}
