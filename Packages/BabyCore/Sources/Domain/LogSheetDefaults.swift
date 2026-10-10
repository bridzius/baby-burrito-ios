import Foundation

extension FeedingDetails {
    // Nursing is usually logged when it ends, so it started one duration ago.
    public func defaultFedAt(now: Date) -> Date {
        guard kind == .nursing, let durationMinutes else { return now }
        return now.addingTimeInterval(-TimeInterval(durationMinutes * 60))
    }
}
