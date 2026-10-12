import BabyCore
import Foundation
import SwiftData

extension Calendar {
    static let vilnius: Calendar = {
        var calendar: Calendar = Calendar(identifier: .gregorian)
        calendar.timeZone      = TimeZone(identifier: "Europe/Vilnius")!
        return calendar
    }()
}

extension Date {
    static func vilnius(_ year: Int, _ month: Int, _ day: Int, hour: Int = 0) -> Date {
        Calendar.vilnius.date(from: DateComponents(year: year, month: month, day: day, hour: hour))!
    }
}

extension Baby {
    static let ona: Baby = Baby(
        name:                   "Ona",
        birthDate:              .vilnius(2026, 3, 14),
        feedingIntervalMinutes: 180
    )
}

extension FeedingDetails {
    static let formula90: FeedingDetails   = FeedingDetails(kind: .formula, amountMl: 90)
    static let nursingLeft: FeedingDetails = FeedingDetails(
        kind: .nursing, durationMinutes: 15, side: .left
    )
}
