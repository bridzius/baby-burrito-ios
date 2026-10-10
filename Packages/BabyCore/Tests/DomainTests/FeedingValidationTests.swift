import Foundation
import Testing
@testable import Domain

struct FeedingValidationTests {
    let calendar: Calendar = .vilnius
    let birthDate: Date    = .vilnius(2026, 3, 14, hour: 14, minute: 30)
    let now: Date          = .vilnius(2026, 4, 2, hour: 9, minute: 0)

    func formula(amountMl: Int) -> FeedingDetails {
        FeedingDetails(kind: .formula, amountMl: amountMl)
    }

    func nursing(durationMinutes: Int?, side: Side?) -> FeedingDetails {
        FeedingDetails(kind: .nursing, durationMinutes: durationMinutes, side: side)
    }

    func validate(
        _ details: FeedingDetails,
        fedAt:     Date
    ) throws(FeedingValidationError) -> Feeding {
        try Feeding.validated(
            id:        UUID(),
            fedAt:     fedAt,
            details:   details,
            birthDate: birthDate,
            now:       now,
            calendar:  calendar
        )
    }

    @Test func rejects_bottle_amounts_outside_the_allowed_range() throws {
        #expect(throws: FeedingValidationError.amountOutOfRange) {
            try formula(amountMl: 0).validated()
        }
        #expect(throws: FeedingValidationError.amountOutOfRange) {
            try formula(amountMl: 501).validated()
        }
        #expect(try formula(amountMl: 120).validated() == formula(amountMl: 120))
    }

    @Test func nursing_requires_duration_and_side_and_no_amount() throws {
        var withAmount: FeedingDetails = nursing(durationMinutes: 15, side: .left)
        withAmount.amountMl            = 60

        _ = try nursing(durationMinutes: 15, side: .left).validated()
        #expect(throws: FeedingValidationError.missingDuration) {
            try nursing(durationMinutes: nil, side: .left).validated()
        }
        #expect(throws: FeedingValidationError.missingSide) {
            try nursing(durationMinutes: 15, side: nil).validated()
        }
        #expect(throws: FeedingValidationError.durationOutOfRange) {
            try nursing(durationMinutes: 121, side: .both).validated()
        }
        #expect(throws: FeedingValidationError.amountOnlyForBottles) {
            try withAmount.validated()
        }
    }

    @Test func bottles_reject_nursing_fields() {
        var withSide: FeedingDetails = formula(amountMl: 90)
        withSide.side                = .right

        var withDuration: FeedingDetails = FeedingDetails(kind: .breastMilk, amountMl: 90)
        withDuration.durationMinutes     = 10

        #expect(throws: FeedingValidationError.nursingFieldsOnlyForNursing) {
            try withSide.validated()
        }
        #expect(throws: FeedingValidationError.nursingFieldsOnlyForNursing) {
            try withDuration.validated()
        }
    }

    @Test func rejects_feedings_in_the_future_beyond_clock_drift() throws {
        _ = try validate(formula(amountMl: 90), fedAt: now.addingTimeInterval(4 * 60))

        #expect(throws: FeedingValidationError.fedAtInFuture) {
            try validate(formula(amountMl: 90), fedAt: now.addingTimeInterval(6 * 60))
        }
    }

    @Test func update_within_the_same_kind_keeps_other_fields() throws {
        let existing: FeedingDetails = nursing(durationMinutes: 15, side: .left)

        var edited: FeedingDetails = existing.changingKind(to: .nursing)
        edited.side                = .right

        let revision: FeedingDetails = try edited.validated()

        #expect(revision.durationMinutes == 15)
        #expect(revision.side == .right)
    }

    @Test func changing_kind_clears_the_previous_kinds_fields() throws {
        let existing: FeedingDetails = nursing(durationMinutes: 15, side: .left)

        var toBottle: FeedingDetails = existing.changingKind(to: .formula)
        toBottle.amountMl            = 90

        let revision: FeedingDetails = try toBottle.validated()

        #expect(revision.amountMl == 90)
        #expect(revision.durationMinutes == nil)
        #expect(revision.side == nil)
        #expect(throws: FeedingValidationError.missingAmount) {
            try existing.changingKind(to: .formula).validated()
        }
    }

    @Test func accepts_a_feeding_at_five_past_midnight_on_the_birth_day() throws {
        let fivePastMidnight: Date = .vilnius(2026, 3, 14, hour: 0, minute: 5)

        let feeding: Feeding = try validate(formula(amountMl: 30), fedAt: fivePastMidnight)

        #expect(feeding.fedAt == fivePastMidnight)
    }

    @Test func rejects_a_feeding_before_the_birth_day() {
        let dayBeforeBirth: Date = .vilnius(2026, 3, 13, hour: 23, minute: 55)

        #expect(throws: FeedingValidationError.fedAtBeforeBirthDay) {
            try validate(formula(amountMl: 30), fedAt: dayBeforeBirth)
        }
    }

    @Test func keeps_sub_millisecond_precision_of_fed_at() throws {
        let preciseFedAt: Date = Date(timeIntervalSince1970: 1_775_000_000.123_456)

        let feeding: Feeding = try validate(formula(amountMl: 30), fedAt: preciseFedAt)

        #expect(feeding.fedAt == preciseFedAt)
    }

    @Test func rejects_invalid_details_when_validating_a_feeding() {
        #expect(throws: FeedingValidationError.missingAmount) {
            try validate(FeedingDetails(kind: .breastMilk), fedAt: now)
        }
    }

    @Test func the_amount_reason_names_the_allowed_range() {
        let reason: String = FeedingValidationError.amountOutOfRange.reason

        #expect(reason == "Enter an amount from 1 to 500 ml.")
    }

    @Test(arguments: FeedingValidationError.allCases)
    func every_error_has_a_reason(error: FeedingValidationError) {
        #expect(!error.reason.isEmpty)
    }
}
