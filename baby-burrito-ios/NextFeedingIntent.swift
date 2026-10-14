import AppIntents
import BabyCore
import SwiftData

// Answered in the background from the App Group store; it never opens the app.
struct NextFeedingIntent: AppIntent {
    static let title: LocalizedStringResource = "Next feeding"
    static let description: IntentDescription = "Says when the next feeding is due."

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let container: ModelContainer = try LocalStore.container(
            at: LocalStore.appGroupStoreURL(), readOnly: true
        )
        let context: ModelContext = ModelContext(container)

        var babyDescriptor: FetchDescriptor<LocalBaby> = FetchDescriptor()
        babyDescriptor.fetchLimit                      = 1
        guard let baby = try context.fetch(babyDescriptor).first else {
            return .result(dialog: "Open Baby Burrito to add your baby first.")
        }

        var feedingDescriptor: FetchDescriptor<LocalFeeding> = FetchDescriptor(
            sortBy: [SortDescriptor(\.fedAt, order: .reverse)]
        )
        feedingDescriptor.fetchLimit = 1
        guard let lastFeeding = try context.fetch(feedingDescriptor).first?.feeding else {
            return .result(dialog: "No feedings are logged yet.")
        }

        let nextFeedingAt: Date = lastFeeding.nextFeedingAt(
            feedingIntervalMinutes: baby.feedingIntervalMinutes
        )
        let answer: String = NextFeedingAccessibility.label(nextFeedingAt: nextFeedingAt, now: .now)
        return .result(dialog: IntentDialog(stringLiteral: answer))
    }
}
