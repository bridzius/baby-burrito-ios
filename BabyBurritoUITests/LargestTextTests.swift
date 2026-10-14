import XCTest

@MainActor
final class LargestTextTests: XCTestCase {
    static let launchTimeout: TimeInterval = 30
    static let largestSize: String         = "UICTContentSizeCategoryAccessibilityXXXL"

    private var app: XCUIApplication = XCUIApplication()

    func testTodayMovesLogFeedingToTheTopToolbar() {
        continueAfterFailure = false
        app.launchArguments  = [
            "-seededFeedingCount", "5",
            "-UIPreferredContentSizeCategoryName", Self.largestSize,
        ]
        app.launch()
        // The header fills the screen at this size, so no feeding row is on screen yet.
        XCTAssertTrue(app.buttons["Settings"].waitForExistence(timeout: Self.launchTimeout))

        let attachment: XCTAttachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name               = "Today at AX5"
        attachment.lifetime           = .keepAlways
        add(attachment)

        XCTAssertTrue(app.navigationBars.buttons["Log feeding"].exists)
        XCTAssertTrue(app.buttons["repeatButton"].exists)
    }
}
