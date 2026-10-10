import Foundation

extension Calendar {
    static let vilnius: Calendar = {
        var calendar: Calendar = Calendar(identifier: .gregorian)
        calendar.timeZone      = TimeZone(identifier: "Europe/Vilnius")!
        return calendar
    }()
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
}
