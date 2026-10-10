import Domain
import Foundation
import Testing

#if DEBUG
let isReleaseBuild: Bool = false
#else
let isReleaseBuild: Bool = true
#endif

struct StatisticsPerformanceTests {
    static let feedingCount: Int           = 7_000
    static let budget: Duration            = .milliseconds(50)
    static let minutesBetweenFeedings: Int = 150
    static let trendsDays: Int             = 30

    static func feedings(endingAt now: Date) -> [Feeding] {
        (0..<feedingCount).map { index in
            let fedAt: Date = now.addingTimeInterval(
                -TimeInterval(index * minutesBetweenFeedings * 60)
            )
            return index.isMultiple(of: 3)
                ? .nursing(.left, durationMinutes: 15, at: fedAt)
                : .bottle(.formula, amountMl: 90, at: fedAt)
        }
    }

    @Test(.enabled(if: isReleaseBuild, "The budget applies to release builds"))
    func summary_and_daily_over_seven_thousand_feedings_take_under_fifty_milliseconds() {
        let now: Date              = .vilnius(2026, 10, 10, hour: 12)
        let feedings: [Feeding]    = Self.feedings(endingAt: now)
        let clock: ContinuousClock = ContinuousClock()

        let elapsed: Duration = clock.measure {
            _ = Statistics.summary(of: feedings, window: 24 * 60 * 60, now: now)
            _ = Statistics.daily(of: feedings, calendar: .vilnius, days: Self.trendsDays, now: now)
        }

        #expect(elapsed < Self.budget)
    }
}
