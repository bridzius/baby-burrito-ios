import Foundation
import Testing
import Domain

struct WeighingValidationTests {
    let calendar: Calendar = .vilnius
    let birthDate: Date    = .vilnius(2026, 3, 14)
    let now: Date          = .vilnius(2026, 4, 2, hour: 9)

    func validated(
        weighedOn: Date,
        grams:     Int = 4_250
    ) throws(WeighingValidationError) -> Weighing {
        try Weighing.validated(
            weighedOn: weighedOn,
            grams:     grams,
            birthDate: birthDate,
            now:       now,
            calendar:  calendar
        )
    }

    @Test func accepts_a_weighing_and_keeps_only_its_day() throws {
        let weighing: Weighing = try validated(weighedOn: .vilnius(2026, 3, 20, hour: 15))

        #expect(weighing == Weighing(weighedOn: .vilnius(2026, 3, 20), grams: 4_250))
    }

    @Test(arguments: [500, 4_250, 25_000])
    func accepts_weights_within_bounds(grams: Int) throws {
        _ = try validated(weighedOn: .vilnius(2026, 3, 20), grams: grams)
    }

    @Test(arguments: [0, 499, 25_001])
    func rejects_weights_outside_bounds(grams: Int) {
        #expect(throws: WeighingValidationError.weightOutOfRange) {
            try validated(weighedOn: .vilnius(2026, 3, 20), grams: grams)
        }
    }

    @Test func accepts_the_birth_day_and_today() throws {
        _ = try validated(weighedOn: .vilnius(2026, 3, 14))
        _ = try validated(weighedOn: .vilnius(2026, 4, 2, hour: 23, minute: 59))
    }

    @Test func rejects_a_day_before_the_birth_day() {
        #expect(throws: WeighingValidationError.weighedOnBeforeBirthDay) {
            try validated(weighedOn: .vilnius(2026, 3, 13, hour: 23, minute: 59))
        }
    }

    @Test func rejects_a_day_after_today() {
        #expect(throws: WeighingValidationError.weighedOnInFuture) {
            try validated(weighedOn: .vilnius(2026, 4, 3))
        }
    }

    @Test(arguments: WeighingValidationError.allCases)
    func every_error_has_a_reason(error: WeighingValidationError) {
        #expect(!error.reason.isEmpty)
    }
}
