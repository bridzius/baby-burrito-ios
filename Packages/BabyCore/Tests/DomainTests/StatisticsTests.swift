import Domain
import Foundation
import Testing

struct StatisticsTests {
    let utc: Calendar    = .gregorian(timeZone: "UTC")
    let prague: Calendar = .gregorian(timeZone: "Europe/Prague")

    @Test func buckets_by_local_day_not_utc_day() {
        // 23:30 UTC on Oct 7 is 01:30 on Oct 8 in Prague (UTC+2 in summer time).
        let feedings: [Feeding] = [
            .bottle(.formula, amountMl: 80, at: .utc("2026-10-07T10:00:00Z")),
            .bottle(.breastMilk, amountMl: 60, at: .utc("2026-10-07T23:30:00Z")),
        ]

        let figures: TrendsFigures = Statistics.daily(
            of:       feedings,
            calendar: prague,
            days:     2,
            now:      .utc("2026-10-08T12:00:00Z")
        )

        #expect(figures.days[0].totals.totalMl == 80)
        #expect(figures.days[1].totals.totalMl == 60)
        #expect(figures.days[1].totals.breastMilkMl == 60)
        #expect(figures.averageDailyMl == 70)
    }

    @Test func nursing_adds_minutes_per_side_but_no_millilitres() {
        let feedings: [Feeding] = [
            .nursing(.left, durationMinutes: 15, at: .utc("2026-10-08T01:00:00Z")),
            .nursing(.right, durationMinutes: 20, at: .utc("2026-10-08T04:00:00Z")),
            .nursing(.both, durationMinutes: 10, at: .utc("2026-10-08T07:00:00Z")),
            .bottle(.formula, amountMl: 90, at: .utc("2026-10-08T10:00:00Z")),
        ]

        let totals: FeedingTotals = Statistics.summary(
            of:     feedings,
            window: 24 * 60 * 60,
            now:    .utc("2026-10-08T12:00:00Z")
        )

        #expect(totals.nursingCount == 3)
        #expect(totals.nursingMinutes == 45)
        #expect(totals.leftMinutes == 15)
        #expect(totals.rightMinutes == 20)
        #expect(totals.bothMinutes == 10)
        #expect(totals.bottleCount == 1)
        #expect(totals.totalMl == 90)
        #expect(totals.formulaMl == 90)
        #expect(totals.breastMilkMl == 0)
    }

    @Test func summary_counts_only_feedings_inside_the_window() {
        let now: Date = .utc("2026-10-08T12:00:00Z")
        let feedings: [Feeding] = [
            .bottle(.formula, amountMl: 50, at: .utc("2026-10-07T11:59:00Z")),
            .bottle(.formula, amountMl: 70, at: .utc("2026-10-07T12:00:00Z")),
            .bottle(.breastMilk, amountMl: 30, at: .utc("2026-10-08T12:03:00Z")),
        ]

        let totals: FeedingTotals = Statistics.summary(of: feedings, window: 24 * 60 * 60, now: now)

        #expect(totals.bottleCount == 2)
        #expect(totals.formulaMl == 70)
        #expect(totals.breastMilkMl == 30)
    }

    @Test func computes_intervals_across_kinds_and_midnight() {
        let feedings: [Feeding] = [
            .nursing(.left, durationMinutes: 15, at: .utc("2026-10-07T21:00:00Z")),
            .bottle(.formula, amountMl: 90, at: .utc("2026-10-08T00:00:00Z")),
            .nursing(.right, durationMinutes: 15, at: .utc("2026-10-08T02:00:00Z")),
        ]

        let figures: TrendsFigures = Statistics.daily(
            of:       feedings,
            calendar: utc,
            days:     2,
            now:      .utc("2026-10-08T12:00:00Z")
        )

        #expect(figures.days[0].averageIntervalMinutes == nil)
        #expect(figures.days[1].averageIntervalMinutes == 150)
        #expect(figures.days[1].longestIntervalMinutes == 180)
    }

    @Test func the_first_day_measures_its_interval_from_the_feeding_before_the_range() {
        let feedings: [Feeding] = [
            .bottle(.formula, amountMl: 90, at: .utc("2026-10-06T22:00:00Z")),
            .bottle(.formula, amountMl: 90, at: .utc("2026-10-07T02:00:00Z")),
        ]

        let figures: TrendsFigures = Statistics.daily(
            of:       feedings,
            calendar: utc,
            days:     2,
            now:      .utc("2026-10-08T12:00:00Z")
        )

        #expect(figures.days[0].totals.bottleCount == 1)
        #expect(figures.days[0].longestIntervalMinutes == 240)
    }

    @Test func includes_empty_days_so_charts_have_no_gaps() {
        let figures: TrendsFigures = Statistics.daily(
            of:       [],
            calendar: utc,
            days:     7,
            now:      .utc("2026-10-07T12:00:00Z")
        )

        #expect(figures.days.count == 7)
        #expect(figures.days.allSatisfy { $0.totals == FeedingTotals() })
        #expect(figures.days.first?.start == .utc("2026-10-01T00:00:00Z"))
        #expect(figures.averageDailyMl == 0)
    }

    @Test func start_of_local_day_respects_offset() {
        let figures: TrendsFigures = Statistics.daily(
            of:       [],
            calendar: prague,
            days:     1,
            now:      .utc("2026-10-08T12:00:00Z")
        )

        #expect(figures.days[0].start == .utc("2026-10-07T22:00:00Z"))
    }

    @Test func days_follow_local_midnights_across_spring_forward() {
        // Clocks in Vilnius jump from 03:00 to 04:00 on 29 March 2026, so that day lasts 23 h.
        let feedings: [Feeding] = [
            .bottle(.formula, amountMl: 60, at: .vilnius(2026, 3, 29, hour: 2)),
            .bottle(.formula, amountMl: 70, at: .vilnius(2026, 3, 29, hour: 5)),
            .bottle(.formula, amountMl: 80, at: .vilnius(2026, 3, 29, hour: 23, minute: 30)),
            .bottle(.formula, amountMl: 90, at: .vilnius(2026, 3, 30, hour: 0, minute: 30)),
        ]

        let figures: TrendsFigures = Statistics.daily(
            of:       feedings,
            calendar: .vilnius,
            days:     2,
            now:      .vilnius(2026, 3, 30, hour: 12)
        )

        #expect(figures.days.map(\.start) == [.vilnius(2026, 3, 29), .vilnius(2026, 3, 30)])
        #expect(figures.days.map(\.totals.totalMl) == [210, 90])
        #expect(figures.days[0].longestIntervalMinutes == 1_110)
        #expect(figures.days[0].averageIntervalMinutes == 615)
    }

    @Test func days_follow_local_midnights_across_fall_back() {
        // Clocks in Vilnius go back from 04:00 to 03:00 on 25 October 2026, so that day lasts 25 h.
        let feedings: [Feeding] = [
            .bottle(.formula, amountMl: 60, at: .vilnius(2026, 10, 25, hour: 1)),
            .bottle(.formula, amountMl: 70, at: .vilnius(2026, 10, 25, hour: 23, minute: 30)),
            .bottle(.formula, amountMl: 80, at: .vilnius(2026, 10, 26, hour: 0, minute: 30)),
        ]

        let figures: TrendsFigures = Statistics.daily(
            of:       feedings,
            calendar: .vilnius,
            days:     2,
            now:      .vilnius(2026, 10, 26, hour: 12)
        )

        #expect(figures.days.map(\.start) == [.vilnius(2026, 10, 25), .vilnius(2026, 10, 26)])
        #expect(figures.days.map(\.totals.totalMl) == [130, 80])
        #expect(figures.days[0].longestIntervalMinutes == 23 * 60 + 30)
    }
}
