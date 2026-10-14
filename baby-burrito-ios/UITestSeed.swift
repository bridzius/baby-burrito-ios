#if DEBUG
import BabyCore
import Foundation

// Launch with `-seededFeedingCount <n>` (UI tests) to get an in-memory store holding a baby and
// n feedings, one every 58 minutes back from now. Never touches the App Group store.
enum UITestSeed {
    static let feedingCountKey: String          = "seededFeedingCount"
    static let minutesBetweenFeedings: Int      = 58
    static let feedingIntervalMinutes: Int      = 180
    static let earliestBirthDay: DateComponents = Baby.earliestBirthDay

    static var requestedFeedingCount: Int? {
        let count: Int = UserDefaults.standard.integer(forKey: feedingCountKey)
        return count > 0 ? count : nil
    }

    @MainActor
    static func seed(_ feedingCount: Int, into feedingStore: FeedingStore) {
        guard let birthDate = Calendar.autoupdatingCurrent.date(from: earliestBirthDay) else {
            preconditionFailure("The calendar can't represent the earliest birth day")
        }
        do {
            _ = try feedingStore.createBaby(Baby(
                name:                   "Burrito",
                birthDate:              birthDate,
                feedingIntervalMinutes: feedingIntervalMinutes
            ))
            for index in 0..<feedingCount {
                let minutesAgo: Int = index * minutesBetweenFeedings
                _ = try feedingStore.log(
                    fedAt:   .now.addingTimeInterval(-TimeInterval(minutesAgo * 60)),
                    details: details(for: index)
                )
            }
        } catch {
            preconditionFailure("Seeding UI test feedings failed: \(error)")
        }
    }

    private static func details(for index: Int) -> FeedingDetails {
        switch index % 3 {
        case 0:  FeedingDetails(kind: .nursing, durationMinutes: 15, side: .left)
        case 1:  FeedingDetails(kind: .formula, amountMl: 90)
        default: FeedingDetails(kind: .breastMilk, amountMl: 60)
        }
    }
}
#endif
