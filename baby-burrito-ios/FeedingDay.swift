import BabyCore
import Foundation

struct FeedingDay: Identifiable {
    let start: Date
    let feedings: [LocalFeeding]

    var id: Date { start }

    // Expects feedings newest first, as Today's query returns them.
    static func grouping(_ feedings: [LocalFeeding], calendar: Calendar) -> [FeedingDay] {
        var days: [FeedingDay] = []
        var currentStart: Date?
        var currentFeedings: [LocalFeeding] = []

        for feeding in feedings {
            let start: Date = calendar.startOfDay(for: feeding.fedAt)
            if start != currentStart, let currentStart {
                days.append(FeedingDay(start: currentStart, feedings: currentFeedings))
                currentFeedings = []
            }
            currentStart = start
            currentFeedings.append(feeding)
        }

        guard let currentStart else { return days }
        days.append(FeedingDay(start: currentStart, feedings: currentFeedings))
        return days
    }

    func title(calendar: Calendar, now: Date) -> String {
        if calendar.isDate(start, inSameDayAs: now) {
            return String(localized: "Today")
        }
        if let yesterday = calendar.date(byAdding: .day, value: -1, to: now),
           calendar.isDate(start, inSameDayAs: yesterday) {
            return String(localized: "Yesterday")
        }
        guard calendar.isDate(start, equalTo: now, toGranularity: .year) else {
            return start.formatted(.dateTime.weekday(.wide).day().month(.wide).year())
        }
        return start.formatted(.dateTime.weekday(.wide).day().month(.wide))
    }
}
