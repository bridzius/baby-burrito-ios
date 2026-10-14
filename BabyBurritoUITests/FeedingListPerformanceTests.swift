import XCTest

final class FeedingListPerformanceTests: XCTestCase {
    static let seededFeedingCount: Int     = 7_000
    static let launchTimeout: TimeInterval = 120
    static let swipesPerIteration: Int     = 4

    @MainActor
    func testScrollingThroughSevenThousandFeedings() throws {
        let app: XCUIApplication = XCUIApplication()
        app.launchArguments      = ["-seededFeedingCount", String(Self.seededFeedingCount)]
        app.launch()

        let list: XCUIElement = app.collectionViews.firstMatch
        XCTAssertTrue(list.waitForExistence(timeout: Self.launchTimeout))

        let options: XCTMeasureOptions = XCTMeasureOptions()
        options.invocationOptions      = [.manuallyStop]

        measure(metrics: [XCTOSSignpostMetric.scrollDecelerationMetric], options: options) {
            for _ in 0..<Self.swipesPerIteration {
                list.swipeUp(velocity: .fast)
            }
            stopMeasuring()
            for _ in 0..<Self.swipesPerIteration {
                list.swipeDown(velocity: .fast)
            }
        }
    }
}
