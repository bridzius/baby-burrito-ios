import Foundation
import Testing
@testable import Domain

struct BabyValidationTests {
    let calendar: Calendar = .vilnius

    func baby(
        name:                   String = "Ona",
        birthDate:              Date   = .vilnius(2026, 3, 14),
        feedingIntervalMinutes: Int    = 180
    ) -> Baby {
        Baby(name: name, birthDate: birthDate, feedingIntervalMinutes: feedingIntervalMinutes)
    }

    @Test func accepts_a_valid_baby() throws {
        #expect(try baby().validated(calendar: calendar) == baby())
    }

    @Test(arguments: ["", "   ", "\n"])
    func rejects_an_empty_name(name: String) {
        #expect(throws: BabyValidationError.emptyName) {
            try baby(name: name).validated(calendar: calendar)
        }
    }

    @Test func accepts_a_birth_date_on_the_first_allowed_day() throws {
        _ = try baby(birthDate: .vilnius(2026, 1, 1)).validated(calendar: calendar)
    }

    @Test func rejects_a_birth_date_before_2026() {
        #expect(throws: BabyValidationError.birthDateTooEarly) {
            try baby(birthDate: .vilnius(2025, 12, 31, hour: 23, minute: 59))
                .validated(calendar: calendar)
        }
    }

    @Test(arguments: [15, 30, 180, 705, 720])
    func accepts_feeding_intervals_within_bounds_in_quarter_hours(minutes: Int) throws {
        _ = try baby(feedingIntervalMinutes: minutes).validated(calendar: calendar)
    }

    @Test(arguments: [0, 14, 20, 179, 721, 735])
    func rejects_feeding_intervals_outside_bounds_or_steps(minutes: Int) {
        #expect(throws: BabyValidationError.feedingIntervalNotAllowed) {
            try baby(feedingIntervalMinutes: minutes).validated(calendar: calendar)
        }
    }

    @Test(arguments: BabyValidationError.allCases)
    func every_error_has_a_reason(error: BabyValidationError) {
        #expect(!error.reason.isEmpty)
    }
}
