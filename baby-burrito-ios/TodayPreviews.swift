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

private struct PreviewFeeding {
    let secondsAgo: TimeInterval
    let details: FeedingDetails

    static func nursing(_ side: Side, minutes: Int, hoursAgo: Double) -> PreviewFeeding {
        PreviewFeeding(
            secondsAgo: hoursAgo * 3_600,
            details:    FeedingDetails(kind: .nursing, durationMinutes: minutes, side: side)
        )
    }

    static func bottle(_ kind: FeedingKind, ml: Int, hoursAgo: Double) -> PreviewFeeding {
        PreviewFeeding(
            secondsAgo: hoursAgo * 3_600,
            details:    FeedingDetails(kind: kind, amountMl: ml)
        )
    }

    static func lastNursing(secondsAgo: TimeInterval) -> [PreviewFeeding] {
        [PreviewFeeding(
            secondsAgo: secondsAgo,
            details:    FeedingDetails(kind: .nursing, durationMinutes: 15, side: .left)
        )]
    }

    static let countingDown: [PreviewFeeding] = lastNursing(
        secondsAgo: PreviewTiming.countingDownSecondsAgo
    )
    static let dueNow: [PreviewFeeding] = lastNursing(secondsAgo: PreviewTiming.dueNowSecondsAgo)
    static let dueFor: [PreviewFeeding] = lastNursing(secondsAgo: PreviewTiming.dueForSecondsAgo)

    static let mixedKinds: [PreviewFeeding] = [
        .nursing(.left, minutes: 15, hoursAgo: 1.5),
        .bottle(.breastMilk, ml: 90, hoursAgo: 4),
        .nursing(.right, minutes: 20, hoursAgo: 7),
        .bottle(.formula, ml: 120, hoursAgo: 10),
        .nursing(.both, minutes: 10, hoursAgo: 13.5),
        .bottle(.formula, ml: 80, hoursAgo: 17),
        .bottle(.breastMilk, ml: 60, hoursAgo: 21),
        .bottle(.formula, ml: 100, hoursAgo: 26),
    ]
}

@MainActor
private func todayPreview(feedings: [PreviewFeeding]) -> some View {
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
        for feeding in feedings {
            let fedAt: Date = .now.addingTimeInterval(-feeding.secondsAgo)
            _ = try store.log(fedAt: fedAt, details: feeding.details)
        }
        return TodayView(baby: baby, feedingStore: store)
            .modelContainer(container)
    } catch {
        preconditionFailure("Preview data failed: \(error)")
    }
}

#Preview("No feedings, light") {
    todayPreview(feedings: [])
}

#Preview("No feedings, dark") {
    todayPreview(feedings: [])
        .preferredColorScheme(.dark)
}

#Preview("Counting down, light") {
    todayPreview(feedings: PreviewFeeding.countingDown)
}

#Preview("Counting down, dark") {
    todayPreview(feedings: PreviewFeeding.countingDown)
        .preferredColorScheme(.dark)
}

#Preview("Due now, light") {
    todayPreview(feedings: PreviewFeeding.dueNow)
}

#Preview("Due now, dark") {
    todayPreview(feedings: PreviewFeeding.dueNow)
        .preferredColorScheme(.dark)
}

#Preview("Due for 1 h 5 min, light") {
    todayPreview(feedings: PreviewFeeding.dueFor)
}

#Preview("Due for 1 h 5 min, dark") {
    todayPreview(feedings: PreviewFeeding.dueFor)
        .preferredColorScheme(.dark)
}

#Preview("Mixed kinds, light") {
    todayPreview(feedings: PreviewFeeding.mixedKinds)
}

#Preview("Mixed kinds, dark") {
    todayPreview(feedings: PreviewFeeding.mixedKinds)
        .preferredColorScheme(.dark)
}
