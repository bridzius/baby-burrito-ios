import SwiftUI

// System-rendered clocks, so the activity never needs an update to keep ticking. Dimmed
// displays (Always-On, the watch) drop the seconds.
enum ActivityTimer {
    static let secondPrecision: Duration = .seconds(1)
    static let minutePrecision: Duration = .seconds(60)

    static func countdown(to nextFeedingAt: Date, isLuminanceReduced: Bool) -> Text {
        Text(.currentDate, format: .timer(
            countingDownIn: Date.distantPast..<nextFeedingAt,
            maxPrecision:   isLuminanceReduced ? minutePrecision : secondPrecision
        ))
    }

    static func countUp(from nextFeedingAt: Date, isLuminanceReduced: Bool) -> Text {
        Text(.currentDate, format: .stopwatch(
            startingAt:   nextFeedingAt,
            maxPrecision: isLuminanceReduced ? minutePrecision : secondPrecision
        ))
    }

    // "Next in 1:23:10", or "Due · 0:12 ago" once the next feeding time has passed.
    static func headline(nextFeedingAt: Date, isDue: Bool, isLuminanceReduced: Bool) -> Text {
        guard isDue else {
            let remaining: Text = countdown(
                to: nextFeedingAt, isLuminanceReduced: isLuminanceReduced
            )
            return Text("Next in \(remaining)")
        }
        let countUp: Text = countUp(from: nextFeedingAt, isLuminanceReduced: isLuminanceReduced)
        return Text("Due · \(countUp) ago")
    }
}
