import XCTest

@MainActor
final class LiveActivityTests: XCTestCase {
    static let rowIdentifier: String        = "feedingRow"
    static let launchTimeout: TimeInterval  = 30
    static let elementTimeout: TimeInterval = 5
    static let activityAppearDelay: UInt32  = 3
    static let springboardBundleID: String  = "com.apple.springboard"

    private var app: XCUIApplication = XCUIApplication()

    override func setUp() async throws {
        continueAfterFailure = false
        app.launchArguments  = ["-seededFeedingCount", "3"]
        app.launch()
        let firstRow: XCUIElement = app.descendants(matching: .any)
            .matching(identifier: Self.rowIdentifier).firstMatch
        XCTAssertTrue(firstRow.waitForExistence(timeout: Self.launchTimeout))
    }

    override func tearDown() async throws {
        app.launch()
        setShowOnLockScreen(false)
    }

    private func keepScreenshot(_ screenshot: XCUIScreenshot, named name: String) {
        let attachment: XCTAttachment = XCTAttachment(screenshot: screenshot)
        attachment.name               = name
        attachment.lifetime           = .keepAlways
        add(attachment)
    }

    private func setShowOnLockScreen(_ isOn: Bool) {
        app.buttons["Settings"].tap()
        let toggle: XCUIElement = app.switches["Show on Lock Screen"]
        XCTAssertTrue(toggle.waitForExistence(timeout: Self.elementTimeout))
        if (toggle.value as? String == "1") != isOn {
            toggle.switches.firstMatch.tap()
        }
        keepScreenshot(app.screenshot(), named: "Settings, Lock Screen \(isOn)")
        app.navigationBars.buttons.element(boundBy: 0).tap()
    }

    func testTurningTheActivityOnShowsItInTheDynamicIsland() {
        setShowOnLockScreen(true)
        app.buttons["repeatButton"].tap()
        app.buttons["Done"].tap()

        XCUIDevice.shared.press(.home)
        sleep(Self.activityAppearDelay)
        keepScreenshot(XCUIScreen.main.screenshot(), named: "Home Screen with the activity")

        let springboard: XCUIApplication = XCUIApplication(
            bundleIdentifier: Self.springboardBundleID
        )
        let topLeft: XCUICoordinate      = springboard.coordinate(
            withNormalizedOffset: CGVector(dx: 0.1, dy: 0.01)
        )
        topLeft.press(forDuration: 0.1, thenDragTo: springboard.coordinate(
            withNormalizedOffset: CGVector(dx: 0.1, dy: 0.7)
        ))
        sleep(Self.activityAppearDelay)
        keepScreenshot(XCUIScreen.main.screenshot(), named: "Notification Center with the activity")
    }
}
