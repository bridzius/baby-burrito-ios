import XCTest

@MainActor
final class TrendsTests: XCTestCase {
    static let rowIdentifier: String        = "feedingRow"
    static let launchTimeout: TimeInterval  = 30
    static let elementTimeout: TimeInterval = 5
    static let seededFeedingCount: String   = "400"
    static let seededWeighingCount: String  = "6"
    static let bottlesChartID: String       = "bottlesChart"
    static let weightChartID: String        = "weightChart"
    static let maximumSwipes: Int           = 4

    private var app: XCUIApplication = XCUIApplication()

    override func setUp() async throws {
        continueAfterFailure = false
        app.launchArguments  = [
            "-seededFeedingCount", Self.seededFeedingCount,
            "-seededWeighingCount", Self.seededWeighingCount,
        ]
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

    private var weightChart: XCUIElement {
        app.descendants(matching: .any).matching(identifier: Self.weightChartID).firstMatch
    }

    private func scrollTrendsToTheEnd() {
        XCTAssertTrue(app.staticTexts["Bottles"].waitForExistence(timeout: Self.elementTimeout))
        for _ in 0..<Self.maximumSwipes where !weightChart.exists {
            app.collectionViews.firstMatch.swipeUp()
        }
    }

    func testShowsTheWeightChartWithWeighings() {
        app.buttons["Trends"].tap()
        scrollTrendsToTheEnd()

        XCTAssertTrue(weightChart.exists)
        keepScreenshot(named: "Trends weight")
    }

    func testHidesTheWeightChartWithoutWeighings() {
        app.terminate()
        app.launchArguments = ["-seededFeedingCount", Self.seededFeedingCount]
        app.launch()
        XCTAssertTrue(app.buttons["Trends"].waitForExistence(timeout: Self.launchTimeout))

        app.buttons["Trends"].tap()
        scrollTrendsToTheEnd()

        XCTAssertFalse(weightChart.exists)
        XCTAssertTrue(app.staticTexts["Rhythm"].exists)
    }
}
