import XCTest

@MainActor
final class LogSheetTests: XCTestCase {
    static let rowIdentifier: String        = "feedingRow"
    static let launchTimeout: TimeInterval  = 30
    static let elementTimeout: TimeInterval = 5

    private var app: XCUIApplication = XCUIApplication()

    private var rows: XCUIElementQuery {
        app.descendants(matching: .any).matching(identifier: Self.rowIdentifier)
    }

    private func launch(seededFeedingCount: Int) {
        continueAfterFailure = false
        app.launchArguments  = ["-seededFeedingCount", String(seededFeedingCount)]
        app.launch()
    }

    private func row(containing text: String) -> XCUIElement {
        rows.matching(NSPredicate(format: "label CONTAINS %@", text)).firstMatch
    }

    private func tapDone() {
        let done: XCUIElement = app.buttons["Done"]
        XCTAssertTrue(done.isEnabled)
        done.tap()
    }

    func testLogsANursingWithSideAndDuration() {
        launch(seededFeedingCount: 1)
        XCTAssertTrue(rows.firstMatch.waitForExistence(timeout: Self.launchTimeout))

        app.buttons["Log feeding"].tap()
        app.buttons["Nursing"].tap()
        app.buttons["Right"].tap()
        app.buttons["20"].tap()
        tapDone()

        let nursing: XCUIElement = row(containing: "right breast, 20 minutes")
        XCTAssertTrue(nursing.waitForExistence(timeout: Self.elementTimeout))
    }

    func testLogsABottleWithKindAndAmount() {
        launch(seededFeedingCount: 1)
        XCTAssertTrue(rows.firstMatch.waitForExistence(timeout: Self.launchTimeout))

        app.buttons["Log feeding"].tap()
        app.buttons["Formula"].tap()
        app.buttons["120"].tap()
        tapDone()

        let bottle: XCUIElement = row(containing: "120 milli")
        XCTAssertTrue(bottle.waitForExistence(timeout: Self.elementTimeout))
    }

    func testEditingChangesTheSameFeeding() {
        launch(seededFeedingCount: 2)
        XCTAssertTrue(rows.firstMatch.waitForExistence(timeout: Self.launchTimeout))
        let rowCountBefore: Int = rows.count

        rows.firstMatch.swipeLeft()
        app.buttons["Edit"].tap()
        app.buttons["Breast milk"].tap()
        app.buttons["60"].tap()
        tapDone()

        XCTAssertTrue(row(containing: "Breast milk").waitForExistence(timeout: Self.elementTimeout))
        XCTAssertEqual(rows.count, rowCountBefore)
    }

    func testLogsTheFirstFeedingFromTheEmptyState() {
        launch(seededFeedingCount: 0)
        let logFirstFeeding: XCUIElement = app.buttons["Log the first feeding"]
        XCTAssertTrue(logFirstFeeding.waitForExistence(timeout: Self.launchTimeout))

        logFirstFeeding.tap()
        tapDone()

        XCTAssertTrue(rows.firstMatch.waitForExistence(timeout: Self.elementTimeout))
    }
}
