import Foundation

public enum Statistics {
    public static func summary(
        of feedings: [Feeding],
        window:      TimeInterval,
        now:         Date
    ) -> FeedingTotals {
        let windowStart: Date = now.addingTimeInterval(-window)

        var totals: FeedingTotals = FeedingTotals()
        for feeding in feedings where feeding.fedAt >= windowStart {
            totals.add(feeding.details)
        }
        return totals
    }

    public static func daily(
        of feedings: [Feeding],
        calendar:    Calendar,
        days:        Int,
        now:         Date
    ) -> TrendsFigures {
        precondition(days > 0, "Trends need at least one day")

        let dayStarts: [Date]     = localDayStarts(days: days, now: now, calendar: calendar)
        let byFedAt: [Feeding]    = feedings.sorted { $0.fedAt < $1.fedAt }
        var previousFedAt: Date?  = byFedAt.last { $0.fedAt < dayStarts[0] }?.fedAt
        var figures: [DayFigures] = []

        for (start, end) in zip(dayStarts, dayStarts.dropFirst()) {
            let dayFeedings: [Feeding] = byFedAt.filter { $0.fedAt >= start && $0.fedAt < end }
            let day: DayFigures        = DayFigures(
                start:         start,
                feedings:      dayFeedings,
                previousFedAt: previousFedAt
            )
            figures.append(day)
            previousFedAt = dayFeedings.last?.fedAt ?? previousFedAt
        }

        let totalMl: Int = figures.reduce(0) { $0 + $1.totals.totalMl }
        return TrendsFigures(days: figures, averageDailyMl: Double(totalMl) / Double(days))
    }

    // One start more than there are days: tomorrow's start ends today.
    private static func localDayStarts(days: Int, now: Date, calendar: Calendar) -> [Date] {
        let today: Date = calendar.startOfDay(for: now)

        return (1 - days...1).map { offset in
            guard let shifted = calendar.date(byAdding: .day, value: offset, to: today) else {
                preconditionFailure("The calendar can't shift \(today) by \(offset) days")
            }
            return calendar.startOfDay(for: shifted)
        }
    }
}
