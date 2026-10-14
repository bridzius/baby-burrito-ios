import BabyCore
import Foundation
import Testing

struct FeedingActivityContentTests {
    let fedAt: Date = .vilnius(2026, 4, 2, hour: 14)

    @Test func describes_the_last_nursing_and_the_next_feeding() {
        let lastFeeding: Feeding = Feeding(id: UUID(), fedAt: fedAt, details: .nursingLeft)

        let content: FeedingActivityContent = FeedingActivityContent(
            lastFeeding:            lastFeeding,
            feedingIntervalMinutes: 180,
            lastLoggedBy:           nil
        )

        #expect(content.lastFedAt == fedAt)
        #expect(content.lastKind == .nursing)
        #expect(content.lastDurationMinutes == 15)
        #expect(content.lastSide == .left)
        #expect(content.lastAmountMl == nil)
        #expect(content.nextFeedingAt == .vilnius(2026, 4, 2, hour: 17))
    }

    @Test func is_empty_without_a_last_feeding() {
        let content: FeedingActivityContent = FeedingActivityContent(
            lastFeeding:            nil,
            feedingIntervalMinutes: 180,
            lastLoggedBy:           nil
        )

        #expect(content.lastFedAt == nil)
        #expect(content.nextFeedingAt == nil)
    }

    @Test func encodes_well_under_the_activity_payload_limit() throws {
        let activityPayloadLimitBytes: Int = 4_096
        let longestName: String            = String(repeating: "W", count: 200)
        let content: FeedingActivityContent = FeedingActivityContent(
            lastFeeding:            Feeding(id: UUID(), fedAt: fedAt, details: .formula90),
            feedingIntervalMinutes: 180,
            lastLoggedBy:           longestName
        )

        let encoded: Data = try JSONEncoder().encode(content)

        #expect(encoded.count < activityPayloadLimitBytes)
    }
}
