import Foundation

// The Live Activity's ContentState, apart from ActivityKit so it builds and tests on macOS.
public struct FeedingActivityContent: Codable, Hashable, Sendable {
    public var lastFedAt: Date?
    public var lastKind: FeedingKind?
    public var lastAmountMl: Int?
    public var lastDurationMinutes: Int?
    public var lastSide: Side?
    public var lastLoggedBy: String?
    public var nextFeedingAt: Date?

    public init(lastFeeding: Feeding?, feedingIntervalMinutes: Int, lastLoggedBy: String?) {
        lastFedAt           = lastFeeding?.fedAt
        lastKind            = lastFeeding?.details.kind
        lastAmountMl        = lastFeeding?.details.amountMl
        lastDurationMinutes = lastFeeding?.details.durationMinutes
        lastSide            = lastFeeding?.details.side
        self.lastLoggedBy   = lastLoggedBy
        nextFeedingAt       = lastFeeding?.nextFeedingAt(
            feedingIntervalMinutes: feedingIntervalMinutes
        )
    }

    public var lastDetails: FeedingDetails? {
        guard let lastKind else { return nil }
        return FeedingDetails(
            kind:            lastKind,
            amountMl:        lastAmountMl,
            durationMinutes: lastDurationMinutes,
            side:            lastSide
        )
    }
}
