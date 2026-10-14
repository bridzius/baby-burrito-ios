import XCTest

@MainActor
final class DeepLinkTests: XCTestCase {
    static let rowIdentifier: String        = "feedingRow"
    static let launchTimeout: TimeInterval  = 30
    static let elementTimeout: TimeInterval = 5

    private var app: XCUIApplication = XCUIApplication()

    private var rows: XCUIElementQuery {
        app.descendants(matching: .any).matching(identifier: Self.rowIdentifier)
    }

    override func setUp() async throws {
        continueAfterFailure = false
        app.launchArguments  = ["-seededFeedingCount", "1"]
        app.launch()
        XCTAssertTrue(rows.firstMatch.waitForExistence(timeout: Self.launchTimeout))
    }

    private func open(_ link: String) throws {
        app.open(try XCTUnwrap(URL(string: link)))
    }

    func testTheLogFeedingLinkLogsExactlyOneFeedingAndShowsTheConfirmation() throws {
        try open("babyburrito://log-feeding")

        XCTAssertTrue(app.buttons["Undo"].waitForExistence(timeout: Self.elementTimeout))
        XCTAssertEqual(rows.count, 2)
    }

    func testAnUnknownZoneOpensTodayWithoutLogging() throws {
        try open("babyburrito://log-feeding?zone=BabyLog-elsewhere")

        let notice: XCUIElement = app.staticTexts["That baby is no longer on this phone"]
        XCTAssertTrue(notice.waitForExistence(timeout: Self.elementTimeout))
        XCTAssertEqual(rows.count, 1)
    }

    func testTheTodayLinkOpensTodayWithoutLogging() throws {
        try open("babyburrito://today")

        XCTAssertTrue(rows.firstMatch.waitForExistence(timeout: Self.elementTimeout))
        XCTAssertFalse(app.buttons["Undo"].exists)
        XCTAssertEqual(rows.count, 1)
    }
}
