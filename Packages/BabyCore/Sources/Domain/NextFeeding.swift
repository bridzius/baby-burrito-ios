import Foundation

extension Feeding {
    public func nextFeedingAt(feedingIntervalMinutes: Int) -> Date {
        fedAt.addingTimeInterval(TimeInterval(feedingIntervalMinutes * 60))
    }
}
