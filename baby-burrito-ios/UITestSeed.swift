#if DEBUG
import BabyCore
import Foundation

// Launch with `-seededFeedingCount <n>` (UI tests) to get an in-memory store holding a baby and
// n feedings, one every 58 minutes back from now. Never touches the App Group store.
// `-seededWeighingCount <n>` adds n weighings, one a week back from today.
enum UITestSeed {
    static let feedingCountKey: String          = "seededFeedingCount"
    static let weighingCountKey: String         = "seededWeighingCount"
    static let daysBetweenWeighings: Int        = 7
    static let latestWeighingGrams: Int         = 5_200
    static let weeklyGainGrams: Int             = 180
    static let minutesBetweenFeedings: Int      = 58
    static let feedingIntervalMinutes: Int      = 180
    static let earliestBirthDay: DateComponents = Baby.earliestBirthDay

    // Present, even as 0, means "seed": 0 gives a baby with no feedings.
    static var requestedFeedingCount: Int? {
        guard UserDefaults.standard.object(forKey: feedingCountKey) != nil else { return nil }
        return UserDefaults.standard.integer(forKey: feedingCountKey)
    }

    static var requestedWeighingCount: Int {
        UserDefaults.standard.integer(forKey: weighingCountKey)
    }

    @MainActor
    static func seed(
        _ feedingCount:    Int,
        weighingCount:     Int,
        into feedingStore: FeedingStore
    ) {
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
            for index in 0..<weighingCount {
                let weighedOn: Date = Calendar.autoupdatingCurrent.date(
                    byAdding: .day, value: -index * daysBetweenWeighings, to: .now
                ) ?? .now
                _ = try feedingStore.logWeighing(
                    weighedOn: weighedOn,
                    grams:     latestWeighingGrams - index * weeklyGainGrams
                )
            }
        } catch {
            preconditionFailure("Seeding UI test data failed: \(error)")
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
