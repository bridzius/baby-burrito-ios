import Foundation

public struct Feeding: Identifiable, Equatable, Sendable {
    public static let maximumFutureDrift: TimeInterval = 5 * 60

    public let id: UUID
    public var fedAt: Date
    public var details: FeedingDetails

    public init(id: UUID, fedAt: Date, details: FeedingDetails) {
        self.id      = id
        self.fedAt   = fedAt
        self.details = details
    }

    public static func validated(
        id:        UUID,
        fedAt:     Date,
        details:   FeedingDetails,
        birthDate: Date,
        now:       Date,
        calendar:  Calendar
    ) throws(FeedingValidationError) -> Feeding {
        guard fedAt >= calendar.startOfDay(for: birthDate) else { throw .fedAtBeforeBirthDay }
        guard fedAt <= now.addingTimeInterval(maximumFutureDrift) else { throw .fedAtInFuture }

        return Feeding(id: id, fedAt: fedAt, details: try details.validated())
    }
}
