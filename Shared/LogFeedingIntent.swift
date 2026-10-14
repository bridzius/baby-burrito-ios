import AppIntents
import BabyCore

// Logging always happens in the foreground app (ADR 0002), so every logging intent opens the
// app through the same deep link as the Live Activity.
struct LogFeedingIntent: AppIntent {
    static let title: LocalizedStringResource = "Log feeding"
    static let description: IntentDescription = "Repeats the last feeding and shows it with Undo."

    func perform() async throws -> some IntentResult & OpensIntent {
        .result(opensIntent: OpenURLIntent(DeepLink.logFeeding(zoneName: nil).url))
    }
}
