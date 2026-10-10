import Foundation

public struct DayFigures: Equatable, Sendable {
    public let start: Date
    public var totals: FeedingTotals = FeedingTotals()
    public var averageIntervalMinutes: Double?
    public var longestIntervalMinutes: Int?

    init(start: Date, feedings: [Feeding], previousFedAt: Date?) {
        self.start = start

        var previousFedAt: Date?   = previousFedAt
        var intervalMinutes: [Int] = []

        for feeding in feedings {
            totals.add(feeding.details)
            if let previousFedAt {
                intervalMinutes.append(Int(feeding.fedAt.timeIntervalSince(previousFedAt) / 60))
            }
            previousFedAt = feeding.fedAt
        }

        guard !intervalMinutes.isEmpty else { return }
        let totalIntervalMinutes: Int = intervalMinutes.reduce(0, +)

        averageIntervalMinutes = Double(totalIntervalMinutes) / Double(intervalMinutes.count)
        longestIntervalMinutes = intervalMinutes.max()
    }
}
