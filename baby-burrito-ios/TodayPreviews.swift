import BabyCore
import SwiftData
import SwiftUI

private enum PreviewTiming {
    static let feedingIntervalMinutes: Int    = 180
    static let countingDownSecondsAgo: Double = 97 * 60
    static let dueNowSecondsAgo: Double       = 180 * 60 + 20
    static let dueForSecondsAgo: Double       = (180 + 65) * 60
    static let birthDaysAgo: Double           = 14
}

@MainActor
private func todayPreview(lastFeedingSecondsAgo: TimeInterval?) -> some View {
    do {
        let container: ModelContainer = try LocalStore.inMemoryContainer()
        let store: FeedingStore       = FeedingStore(
            modelContext: container.mainContext,
            syncQueue:    NoSyncQueue(),
            calendar:     .autoupdatingCurrent,
            now:          Date.init
        )
        let baby: LocalBaby = try store.createBaby(Baby(
            name:                   "Burrito",
            birthDate:              .now.addingTimeInterval(-PreviewTiming.birthDaysAgo * 86_400),
            feedingIntervalMinutes: PreviewTiming.feedingIntervalMinutes
        ))
        if let lastFeedingSecondsAgo {
            _ = try store.log(
                fedAt:   .now.addingTimeInterval(-lastFeedingSecondsAgo),
                details: FeedingDetails(kind: .nursing, durationMinutes: 15, side: .left)
            )
        }
        return TodayView(baby: baby) { _ in }
            .modelContainer(container)
    } catch {
        preconditionFailure("Preview data failed: \(error)")
    }
}

#Preview("No feedings, light") {
    todayPreview(lastFeedingSecondsAgo: nil)
}

#Preview("No feedings, dark") {
    todayPreview(lastFeedingSecondsAgo: nil)
        .preferredColorScheme(.dark)
}

#Preview("Counting down, light") {
    todayPreview(lastFeedingSecondsAgo: PreviewTiming.countingDownSecondsAgo)
}

#Preview("Counting down, dark") {
    todayPreview(lastFeedingSecondsAgo: PreviewTiming.countingDownSecondsAgo)
        .preferredColorScheme(.dark)
}

#Preview("Due now, light") {
    todayPreview(lastFeedingSecondsAgo: PreviewTiming.dueNowSecondsAgo)
}

#Preview("Due now, dark") {
    todayPreview(lastFeedingSecondsAgo: PreviewTiming.dueNowSecondsAgo)
        .preferredColorScheme(.dark)
}

#Preview("Due for 1 h 5 min, light") {
    todayPreview(lastFeedingSecondsAgo: PreviewTiming.dueForSecondsAgo)
}

#Preview("Due for 1 h 5 min, dark") {
    todayPreview(lastFeedingSecondsAgo: PreviewTiming.dueForSecondsAgo)
        .preferredColorScheme(.dark)
}
