import Domain
import Foundation

extension Calendar {
    static let vilnius: Calendar = .gregorian(timeZone: "Europe/Vilnius")

    static func gregorian(timeZone identifier: String) -> Calendar {
        var calendar: Calendar = Calendar(identifier: .gregorian)
        calendar.timeZone      = TimeZone(identifier: identifier)!
        return calendar
    }
}

extension Date {
    static func vilnius(
        _ year:  Int,
        _ month: Int,
        _ day:   Int,
        hour:    Int = 0,
        minute:  Int = 0
    ) -> Date {
        let components: DateComponents = DateComponents(
            year: year, month: month, day: day, hour: hour, minute: minute
        )
        return Calendar.vilnius.date(from: components)!
    }

    static func utc(_ iso8601: String) -> Date {
        try! Date(iso8601, strategy: .iso8601)
    }
}

extension Feeding {
    static func bottle(_ kind: FeedingKind, amountMl: Int, at fedAt: Date) -> Feeding {
        Feeding(id: UUID(), fedAt: fedAt, details: FeedingDetails(kind: kind, amountMl: amountMl))
    }

    static func nursing(_ side: Side, durationMinutes: Int, at fedAt: Date) -> Feeding {
        Feeding(
            id:      UUID(),
            fedAt:   fedAt,
            details: FeedingDetails(kind: .nursing, durationMinutes: durationMinutes, side: side)
        )
    }
}
