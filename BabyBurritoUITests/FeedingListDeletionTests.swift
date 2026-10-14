import XCTest

@MainActor
final class FeedingListDeletionTests: XCTestCase {
    static let seededFeedingCount: Int         = 3
    static let rowIdentifier: String           = "feedingRow"
    static let launchTimeout: TimeInterval     = 30
    static let undoWindowTimeout: TimeInterval = 10

    private var app: XCUIApplication = XCUIApplication()

    private var rows: XCUIElementQuery {
        app.descendants(matching: .any).matching(identifier: Self.rowIdentifier)
    }

    override func setUp() async throws {
        continueAfterFailure = false
        app.launchArguments  = ["-seededFeedingCount", String(Self.seededFeedingCount)]
        app.launch()
        XCTAssertTrue(rows.firstMatch.waitForExistence(timeout: Self.launchTimeout))
    }

    func testUndoRestoresADeletedFeeding() {
        let rowCountBefore: Int = rows.count

        deleteFirstRow()
        XCTAssertEqual(rows.count, rowCountBefore - 1)

        app.buttons["Undo"].tap()
        XCTAssertTrue(rows.element(boundBy: rowCountBefore - 1).waitForExistence(timeout: 2))
        XCTAssertEqual(rows.count, rowCountBefore)
        XCTAssertFalse(app.buttons["Undo"].exists)
    }

    func testUndoBarLeavesAfterTheUndoWindow() {
        let rowCountBefore: Int = rows.count

        deleteFirstRow()

        let undoGone: XCTNSPredicateExpectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "exists == false"),
            object:    app.buttons["Undo"]
        )
        wait(for: [undoGone], timeout: Self.undoWindowTimeout)
        XCTAssertEqual(rows.count, rowCountBefore - 1)
    }

    private func deleteFirstRow() {
        rows.firstMatch.swipeLeft()
        app.buttons["Delete"].tap()
        XCTAssertTrue(app.buttons["Undo"].waitForExistence(timeout: 2))
    }
}
