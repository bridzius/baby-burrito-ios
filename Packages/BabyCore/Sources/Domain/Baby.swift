import Foundation

public struct Baby: Hashable, Sendable {
    public static let earliestBirthDay: DateComponents                = DateComponents(
        year: 2026, month: 1, day: 1
    )
    public static let allowedFeedingIntervalMinutes: ClosedRange<Int> = 15...720
    public static let feedingIntervalStepMinutes: Int                 = 15

    public var name: String
    public var birthDate: Date
    public var feedingIntervalMinutes: Int

    public init(name: String, birthDate: Date, feedingIntervalMinutes: Int) {
        self.name                   = name
        self.birthDate              = birthDate
        self.feedingIntervalMinutes = feedingIntervalMinutes
    }

    public func validated(
        calendar:          Calendar,
        earliestFedAt:     Date?,
        earliestWeighedOn: Date?
    ) throws(BabyValidationError) -> Baby {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw .emptyName
        }
        guard let earliestBirthDate = calendar.date(from: Self.earliestBirthDay) else {
            preconditionFailure("The calendar can't represent the earliest birth day")
        }
        guard birthDate >= earliestBirthDate else { throw .birthDateTooEarly }
        let birthDayStart: Date = calendar.startOfDay(for: birthDate)
        if let earliestFedAt, earliestFedAt < birthDayStart {
            throw .birthDateAfterEarliestFeeding
        }
        if let earliestWeighedOn, earliestWeighedOn < birthDayStart {
            throw .birthDateAfterEarliestWeighing
        }
        guard Self.allowedFeedingIntervalMinutes.contains(feedingIntervalMinutes),
              feedingIntervalMinutes.isMultiple(of: Self.feedingIntervalStepMinutes)
        else { throw .feedingIntervalNotAllowed }

        return self
    }
}
