import BabyCore
import SwiftData
import SwiftUI

private enum PreviewSeed {
    static let days: Int                   = 30
    static let feedingsPerDay: Int         = 8
    static let hoursBetweenFeedings: Int   = 3
    static let skippedDay: Int             = 9
    static let birthDaysAgo: Int           = 40
    static let feedingIntervalMinutes: Int = 180

    // A steady mix that varies by day, with one day left empty to show a zero bar.
    static func details(day: Int, feeding: Int) -> FeedingDetails {
        let sides: [Side] = Side.allCases
        switch (day + feeding) % 4 {
        case 0:  return FeedingDetails(kind: .formula, amountMl: 60 + (day % 5) * 15)
        case 1:  return FeedingDetails(kind: .breastMilk, amountMl: 50 + (feeding % 3) * 20)
        default: return FeedingDetails(
            kind:            .nursing,
            durationMinutes: 10 + (day % 4) * 5,
            side:            sides[(day + feeding) % sides.count]
        )
        }
    }
}

@MainActor
private func trendsPreview() -> some View {
    do {
        let calendar: Calendar        = .autoupdatingCurrent
        let container: ModelContainer = try LocalStore.inMemoryContainer()
        let store: FeedingStore       = FeedingStore(
            modelContext: container.mainContext,
            syncQueue:    NoSyncQueue(),
            calendar:     calendar,
            now:          Date.init
        )
        let today: Date = calendar.startOfDay(for: .now)
        _ = try store.createBaby(Baby(
            name:                   "Burrito",
            birthDate:              calendar.date(
                byAdding: .day, value: -PreviewSeed.birthDaysAgo, to: today
            ) ?? today,
            feedingIntervalMinutes: PreviewSeed.feedingIntervalMinutes
        ))
        for day in 1...PreviewSeed.days where day != PreviewSeed.skippedDay {
            for feeding in 0..<PreviewSeed.feedingsPerDay {
                let dayStart: Date = calendar.date(byAdding: .day, value: -day, to: today) ?? today
                let fedAt: Date    = calendar.date(
                    byAdding: .hour, value: feeding * PreviewSeed.hoursBetweenFeedings, to: dayStart
                ) ?? dayStart
                _ = try store.log(
                    fedAt:   fedAt,
                    details: PreviewSeed.details(day: day, feeding: feeding)
                )
            }
        }
        return NavigationStack {
            TrendsView(now: .now) { _, _ in }
        }
        .modelContainer(container)
    } catch {
        preconditionFailure("Preview data failed: \(error)")
    }
}

#Preview("30 days, light") {
    trendsPreview()
}

#Preview("30 days, dark") {
    trendsPreview()
        .preferredColorScheme(.dark)
}
