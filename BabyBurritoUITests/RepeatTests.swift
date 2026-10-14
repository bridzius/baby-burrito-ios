import XCTest

@MainActor
final class RepeatTests: XCTestCase {
    static let rowIdentifier: String          = "feedingRow"
    static let repeatIdentifier: String       = "repeatButton"
    static let launchTimeout: TimeInterval    = 30
    static let elementTimeout: TimeInterval   = 5
    static let idleCloseTimeout: TimeInterval = 12
    static let editingSpell: TimeInterval     = 12
    static let secondsBetweenEdits: UInt32    = 3

    private var app: XCUIApplication = XCUIApplication()

    private var rows: XCUIElementQuery {
        app.descendants(matching: .any).matching(identifier: Self.rowIdentifier)
    }

    private var undo: XCUIElement { app.buttons["Undo"] }

    override func setUp() async throws {
        continueAfterFailure = false
        app.launchArguments  = ["-seededFeedingCount", "1"]
        app.launch()
        XCTAssertTrue(rows.firstMatch.waitForExistence(timeout: Self.launchTimeout))
    }

    private func tapRepeat() {
        app.buttons[Self.repeatIdentifier].tap()
        XCTAssertTrue(undo.waitForExistence(timeout: Self.elementTimeout))
    }

    private func waitUntilGone(_ element: XCUIElement, timeout: TimeInterval) {
        let gone: XCTNSPredicateExpectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "exists == false"),
            object:    element
        )
        wait(for: [gone], timeout: timeout)
    }

    func testOneTapLogsExactlyOneFeedingAndUndoLeavesNone() {
        XCTAssertEqual(rows.count, 1)

        tapRepeat()
        XCTAssertEqual(rows.count, 2)

        undo.tap()
        waitUntilGone(undo, timeout: Self.elementTimeout)
        XCTAssertEqual(rows.count, 1)
    }

    func testEditingInTheConfirmationChangesTheFeedingInPlace() {
        tapRepeat()
        app.buttons["Both"].tap()
        app.buttons["20"].tap()
        app.buttons["Done"].tap()
        waitUntilGone(undo, timeout: Self.elementTimeout)

        XCTAssertEqual(rows.count, 2)
        let edited: XCUIElement = rows.matching(
            NSPredicate(format: "label CONTAINS %@", "Both · 20 min")
        ).firstMatch
        XCTAssertTrue(edited.exists)
    }

    func testTheConfirmationClosesAfterEightSecondsIdle() {
        tapRepeat()
        waitUntilGone(undo, timeout: Self.idleCloseTimeout)
        XCTAssertEqual(rows.count, 2)
    }

    func testTheConfirmationStaysOpenWhileBeingEdited() {
        tapRepeat()
        let editingEnds: Date = .now.addingTimeInterval(Self.editingSpell)
        var useLeft: Bool     = true

        while Date.now < editingEnds {
            app.buttons[useLeft ? "Left" : "Right"].tap()
            useLeft.toggle()
            sleep(Self.secondsBetweenEdits)
        }
        XCTAssertTrue(undo.exists)
    }
}
