import Domain
import Foundation
import Testing

struct ChipSuggestionsTests {
    let now: Date = .vilnius(2026, 4, 20, hour: 12)

    func hoursAgo(_ hours: Double) -> Date {
        now.addingTimeInterval(-hours * 60 * 60)
    }

    func formula(_ amountMl: Int, hoursAgo hours: Double) -> Feeding {
        .bottle(.formula, amountMl: amountMl, at: hoursAgo(hours))
    }

    func values(for kind: FeedingKind, from feedings: [Feeding]) -> [Int] {
        ChipSuggestions.values(for: kind, from: feedings, now: now)
    }

    @Test func without_feedings_the_defaults_are_suggested() {
        #expect(values(for: .formula, from: []) == [30, 60, 90, 120, 150])
        #expect(values(for: .breastMilk, from: []) == [30, 60, 90, 120, 150])
        #expect(values(for: .nursing, from: []) == [5, 10, 15, 20, 30])
    }

    @Test func the_five_most_frequent_values_are_suggested_sorted_by_value() {
        let feedings: [Feeding] = [
            formula(100, hoursAgo: 1), formula(100, hoursAgo: 2), formula(100, hoursAgo: 3),
            formula(80, hoursAgo: 4), formula(80, hoursAgo: 5),
            formula(140, hoursAgo: 6), formula(140, hoursAgo: 7),
            formula(70, hoursAgo: 8), formula(70, hoursAgo: 9),
            formula(110, hoursAgo: 10), formula(110, hoursAgo: 11),
            formula(55, hoursAgo: 12),
        ]

        let suggested: [Int] = values(for: .formula, from: feedings)

        #expect(suggested == [70, 80, 100, 110, 140])
    }

    @Test func ties_go_to_the_more_recent_value() {
        let feedings: [Feeding] = [
            formula(10, hoursAgo: 1), formula(20, hoursAgo: 2), formula(30, hoursAgo: 3),
            formula(40, hoursAgo: 4), formula(50, hoursAgo: 5), formula(60, hoursAgo: 6),
        ]

        let suggested: [Int] = values(for: .formula, from: feedings)

        #expect(suggested == [10, 20, 30, 40, 50])
    }

    @Test func fewer_than_five_values_are_filled_from_the_defaults_without_duplicates() {
        let feedings: [Feeding] = [formula(45, hoursAgo: 1), formula(60, hoursAgo: 2)]

        let suggested: [Int] = values(for: .formula, from: feedings)

        #expect(suggested == [30, 45, 60, 90, 120])
    }

    @Test func values_older_than_fourteen_days_are_ignored() {
        let fourteenDaysInHours: Double = 14 * 24
        let feedings: [Feeding]         = [
            formula(45, hoursAgo: fourteenDaysInHours - 1),
            formula(75, hoursAgo: fourteenDaysInHours + 1),
        ]

        let suggested: [Int] = values(for: .formula, from: feedings)

        #expect(suggested == [30, 45, 60, 90, 120])
    }

    @Test func only_feedings_of_the_same_kind_count() {
        let feedings: [Feeding] = [
            .bottle(.breastMilk, amountMl: 45, at: hoursAgo(1)),
            .nursing(.left, durationMinutes: 12, at: hoursAgo(2)),
            formula(75, hoursAgo: 3),
        ]

        #expect(values(for: .breastMilk, from: feedings) == [30, 45, 60, 90, 120])
        #expect(values(for: .nursing, from: feedings) == [5, 10, 12, 15, 20])
    }
}
