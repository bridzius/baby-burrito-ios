import SwiftUI

// System-rendered clocks, so the activity never needs an update to keep ticking. Dimmed
// displays (Always-On, the watch) show two fields, hours and minutes, so seconds drop once an
// hour or more is left. A minute maxPrecision would spell the time out in words instead.
enum ActivityTimer {
    static let allFields: Int     = 3
    static let dimmedFields: Int  = 2

    static func countdown(to nextFeedingAt: Date, isLuminanceReduced: Bool) -> Text {
        Text(.currentDate, format: .timer(
            countingDownIn: Date.distantPast..<nextFeedingAt,
            maxFieldCount:  isLuminanceReduced ? dimmedFields : allFields
        ))
    }

    static func countUp(from nextFeedingAt: Date, isLuminanceReduced: Bool) -> Text {
        Text(.currentDate, format: .stopwatch(
            startingAt:    nextFeedingAt,
            maxFieldCount: isLuminanceReduced ? dimmedFields : allFields,
            maxPrecision:  .seconds(1)
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
