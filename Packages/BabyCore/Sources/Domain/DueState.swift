import Foundation

public enum DueState: Equatable, Sendable {
    case notDue
    case dueNow
    case dueFor(minutes: Int)

    public init(nextFeedingAt: Date, now: Date) {
        let secondsSinceDue: TimeInterval = now.timeIntervalSince(nextFeedingAt)
        let minutesSinceDue: Int          = Int(secondsSinceDue / 60)

        guard secondsSinceDue >= 0 else { self = .notDue; return }
        guard minutesSinceDue >= 1 else { self = .dueNow; return }
        self = .dueFor(minutes: minutesSinceDue)
    }
}
