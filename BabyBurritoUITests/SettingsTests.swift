import XCTest

@MainActor
final class SettingsTests: XCTestCase {
    static let rowIdentifier: String        = "feedingRow"
    static let launchTimeout: TimeInterval  = 30
    static let elementTimeout: TimeInterval = 5
    static let longerInterval: String       = "4h"

    private var app: XCUIApplication = XCUIApplication()

    private var rows: XCUIElementQuery {
        app.descendants(matching: .any).matching(identifier: Self.rowIdentifier)
    }

    override func setUp() async throws {
        continueAfterFailure = false
        app.launchArguments  = ["-seededFeedingCount", "3"]
        app.launch()
        XCTAssertTrue(rows.firstMatch.waitForExistence(timeout: Self.launchTimeout))
    }

    func testChangingTheIntervalUpdatesTodaysNextFeeding() {
        app.buttons["Settings"].tap()
        app.buttons[Self.longerInterval].tap()
        app.navigationBars.buttons.element(boundBy: 0).tap()

        let every4Hours: XCUIElement = app.descendants(matching: .any).matching(
            NSPredicate(format: "label CONTAINS %@", "every 4 hr")
        ).firstMatch
        XCTAssertTrue(every4Hours.waitForExistence(timeout: Self.elementTimeout))
    }

    func testDeleteAllDataReturnsToFirstRun() {
        app.buttons["Settings"].tap()
        app.buttons["Delete all data"].tap()
        app.sheets.buttons["Delete all data"].firstMatch.tap()

        XCTAssertTrue(app.buttons["Continue"].waitForExistence(timeout: Self.elementTimeout))
        XCTAssertEqual(rows.count, 0)
    }
}
