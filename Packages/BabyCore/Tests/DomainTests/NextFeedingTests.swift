import Domain
import Foundation
import Testing

struct NextFeedingTests {
    let lastFedAt: Date = .vilnius(2026, 4, 2, hour: 14, minute: 5)

    var nextFeedingAt: Date {
        let lastFeeding: Feeding = .bottle(.formula, amountMl: 90, at: lastFedAt)
        return lastFeeding.nextFeedingAt(feedingIntervalMinutes: 180)
    }

    @Test func next_feeding_is_the_last_feeding_plus_the_interval() {
        #expect(nextFeedingAt == .vilnius(2026, 4, 2, hour: 17, minute: 5))
    }

    @Test func is_not_due_before_the_next_feeding() {
        let oneSecondBefore: Date = nextFeedingAt.addingTimeInterval(-1)

        #expect(DueState(nextFeedingAt: nextFeedingAt, now: oneSecondBefore) == .notDue)
    }

    @Test func is_due_now_for_the_first_minute() {
        let almostAMinuteLater: Date = nextFeedingAt.addingTimeInterval(59)

        #expect(DueState(nextFeedingAt: nextFeedingAt, now: nextFeedingAt) == .dueNow)
        #expect(DueState(nextFeedingAt: nextFeedingAt, now: almostAMinuteLater) == .dueNow)
    }

    @Test func counts_whole_minutes_once_due_for_longer() {
        let oneMinuteLater: Date     = nextFeedingAt.addingTimeInterval(60)
        let twelveMinutesLater: Date = nextFeedingAt.addingTimeInterval(12 * 60 + 59)

        #expect(DueState(nextFeedingAt: nextFeedingAt, now: oneMinuteLater) == .dueFor(minutes: 1))
        #expect(
            DueState(nextFeedingAt: nextFeedingAt, now: twelveMinutesLater) == .dueFor(minutes: 12)
        )
    }
}
