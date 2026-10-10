import Foundation

extension Feeding {
    public static func repeating(_ lastFeeding: Feeding?, id: UUID, now: Date) -> Feeding? {
        guard let lastFeeding else { return nil }

        var details: FeedingDetails = lastFeeding.details
        details.side                = details.side?.other

        return Feeding(id: id, fedAt: details.defaultFedAt(now: now), details: details)
    }
}
