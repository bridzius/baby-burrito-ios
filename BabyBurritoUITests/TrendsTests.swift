import XCTest

@MainActor
final class TrendsTests: XCTestCase {
    static let rowIdentifier: String        = "feedingRow"
    static let launchTimeout: TimeInterval  = 30
    static let elementTimeout: TimeInterval = 5
    static let seededFeedingCount: String   = "400"
    static let bottlesChartID: String       = "bottlesChart"

    private var app: XCUIApplication = XCUIApplication()

    override func setUp() async throws {
        continueAfterFailure = false
        app.launchArguments  = ["-seededFeedingCount", Self.seededFeedingCount]
        app.launch()
        let firstRow: XCUIElement = app.descendants(matching: .any)
            .matching(identifier: Self.rowIdentifier).firstMatch
        XCTAssertTrue(firstRow.waitForExistence(timeout: Self.launchTimeout))
    }

    private func keepScreenshot(named name: String) {
        let attachment: XCTAttachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name               = name
        attachment.lifetime           = .keepAlways
        add(attachment)
    }

    func testShowsTheChartsForBothRanges() {
        app.buttons["Trends"].tap()
        XCTAssertTrue(app.staticTexts["Bottles"].waitForExistence(timeout: Self.elementTimeout))
        keepScreenshot(named: "Trends 7 days")

        app.buttons["30 days"].tap()
        keepScreenshot(named: "Trends 30 days")
        XCTAssertTrue(app.staticTexts["Nursing"].exists)
    }

    func testTappingADayReturnsToToday() {
        app.buttons["Trends"].tap()
        let bottlesChart: XCUIElement = app.descendants(matching: .any)
            .matching(identifier: Self.bottlesChartID).firstMatch
        XCTAssertTrue(bottlesChart.waitForExistence(timeout: Self.elementTimeout))

        bottlesChart.coordinate(withNormalizedOffset: CGVector(dx: 0.2, dy: 0.5)).tap()

        XCTAssertTrue(app.buttons["Settings"].waitForExistence(timeout: Self.elementTimeout))
        keepScreenshot(named: "Today after tapping a day")
    }
}
