import BabyCore
import Foundation

enum NextFeedingAccessibility {
    static let spokenDuration: Duration.UnitsFormatStyle = .units(
        allowed:        [.hours, .minutes],
        width:          .wide,
        fractionalPart: .hide(rounded: .down)
    )

    static func label(nextFeedingAt: Date, now: Date) -> String {
        let time: String = nextFeedingAt.formatted(date: .omitted, time: .shortened)

        switch DueState(nextFeedingAt: nextFeedingAt, now: now) {
        case .notDue:
            let remaining: String = Duration.seconds(nextFeedingAt.timeIntervalSince(now))
                .formatted(spokenDuration)
            return String(localized: "Next feeding in \(remaining), at \(time)")
        case .dueNow:
            return String(localized: "Next feeding due now, at \(time)")
        case .dueFor(let minutes):
            let overdue: String = Duration.minutes(minutes).formatted(spokenDuration)
            return String(localized: "Next feeding was due \(overdue) ago, at \(time)")
        }
    }
}
