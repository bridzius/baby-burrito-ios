import Domain
import Foundation
import Testing

struct RepeatTests {
    let now: Date           = .vilnius(2026, 4, 2, hour: 3, minute: 0)
    let lateLastNight: Date = .vilnius(2026, 4, 1, hour: 23)
    let id: UUID            = UUID()

    func repeating(_ lastFeeding: Feeding?) -> Feeding? {
        Feeding.repeating(lastFeeding, id: id, now: now)
    }

    @Test func returns_nil_without_a_last_feeding() {
        #expect(repeating(nil) == nil)
    }

    @Test func a_bottle_keeps_its_kind_and_amount_and_is_fed_now() {
        let last: Feeding = .bottle(.breastMilk, amountMl: 110, at: lateLastNight)

        let repeated: Feeding? = repeating(last)

        #expect(repeated == Feeding(
            id:      id,
            fedAt:   now,
            details: FeedingDetails(kind: .breastMilk, amountMl: 110)
        ))
    }

    @Test(arguments: [(Side.left, Side.right), (.right, .left), (.both, .both)])
    func a_nursing_keeps_its_duration_and_switches_side(last: Side, next: Side) {
        let lastFeeding: Feeding = .nursing(last, durationMinutes: 20, at: lateLastNight)

        let expected: FeedingDetails = FeedingDetails(
            kind: .nursing, durationMinutes: 20, side: next
        )

        #expect(repeating(lastFeeding)?.details == expected)
    }

    @Test func a_nursing_is_fed_at_now_minus_its_duration() {
        let lastFeeding: Feeding = .nursing(.left, durationMinutes: 20, at: lateLastNight)

        #expect(repeating(lastFeeding)?.fedAt == .vilnius(2026, 4, 2, hour: 2, minute: 40))
    }

    @Test func the_log_sheet_defaults_a_bottle_to_now() {
        let details: FeedingDetails = FeedingDetails(kind: .formula, amountMl: 90)

        #expect(details.defaultFedAt(now: now) == now)
    }

    @Test func the_log_sheet_defaults_a_nursing_to_now_minus_its_duration() {
        let details: FeedingDetails = FeedingDetails(
            kind: .nursing, durationMinutes: 15, side: .both
        )

        #expect(details.defaultFedAt(now: now) == .vilnius(2026, 4, 2, hour: 2, minute: 45))
    }
}
