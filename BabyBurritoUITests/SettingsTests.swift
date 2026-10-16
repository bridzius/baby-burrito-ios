import XCTest

@MainActor
final class SettingsTests: XCTestCase {
    static let rowIdentifier: String        = "feedingRow"
    static let launchTimeout: TimeInterval  = 30
    static let elementTimeout: TimeInterval = 5
    static let longerInterval: String       = "4h"
    static let weightRowIdentifier: String  = "weightRow"
    // The thousands separator depends on the simulator's region.
    static let steppedUpWeight: String      = "510 g"

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

    func testLoggingAWeighingShowsItAsTheLatestWeight() {
        app.buttons["Settings"].tap()
        app.buttons[Self.weightRowIdentifier].tap()
        app.buttons["Log weighing"].tap()
        app.buttons["Increment"].tap()
        app.buttons["Done"].tap()

        let weighingRow: XCUIElement = app.buttons.matching(
            NSPredicate(format: "label CONTAINS %@", Self.steppedUpWeight)
        ).firstMatch
        XCTAssertTrue(weighingRow.waitForExistence(timeout: Self.elementTimeout))

        app.navigationBars.buttons.element(boundBy: 0).tap()
        let weightRow: XCUIElement = app.buttons[Self.weightRowIdentifier]
        XCTAssertTrue(weightRow.waitForExistence(timeout: Self.elementTimeout))
        XCTAssertTrue(weightRow.label.contains(Self.steppedUpWeight))
    }

    func testDeleteAllDataReturnsToFirstRun() {
        app.buttons["Settings"].tap()
        app.buttons["Delete all data"].tap()
        app.sheets.buttons["Delete all data"].firstMatch.tap()

        XCTAssertTrue(app.buttons["Continue"].waitForExistence(timeout: Self.elementTimeout))
        XCTAssertEqual(rows.count, 0)
    }

    func testFirstRunCreatesTheBabyAfterTheLockScreenStep() {
        testDeleteAllDataReturnsToFirstRun()

        let name: XCUIElement = app.textFields["Name"]
        name.tap()
        name.typeText("Ona")
        app.buttons["Choose the birth date"].tap()
        app.buttons["Continue"].tap()

        XCTAssertTrue(app.buttons["Not now"].waitForExistence(timeout: Self.elementTimeout))
        app.buttons["Not now"].tap()

        XCTAssertTrue(app.buttons["Log the first feeding"].waitForExistence(
            timeout: Self.elementTimeout
        ))
        XCTAssertTrue(app.navigationBars["Ona"].exists)
    }
}
