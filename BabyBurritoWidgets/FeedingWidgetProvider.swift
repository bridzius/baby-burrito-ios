import BabyCore
import OSLog
import SwiftData
import WidgetKit

// Reads the app's store in the App Group. The app reloads this timeline when its data changes.
struct FeedingWidgetProvider: TimelineProvider {
    static let logger: Logger                  = Logger(
        subsystem: "com.bridzius.babyburrito.widgets", category: "widget"
    )
    static let placeholderIntervalMinutes: Int = 180

    func placeholder(in context: Context) -> FeedingWidgetEntry {
        FeedingWidgetEntry(
            date:     .now,
            babyName: nil,
            content:  FeedingActivityContent(
                lastFeeding:            nil,
                feedingIntervalMinutes: Self.placeholderIntervalMinutes,
                lastLoggedBy:           nil
            ),
            isDue:    false
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (FeedingWidgetEntry) -> Void) {
        completion(Self.entries(now: .now).first ?? placeholder(in: context))
    }

    func getTimeline(
        in context: Context,
        completion: @escaping (Timeline<FeedingWidgetEntry>) -> Void
    ) {
        let entries: [FeedingWidgetEntry] = Self.entries(now: .now)
        let shown: [FeedingWidgetEntry]   = entries.isEmpty ? [placeholder(in: context)] : entries
        completion(Timeline(entries: shown, policy: .never))
    }

    // An unreadable store shows the empty widget rather than stale data.
    private static func entries(now: Date) -> [FeedingWidgetEntry] {
        do {
            let container: ModelContainer = try LocalStore.container(
                at: LocalStore.appGroupStoreURL(), readOnly: true
            )
            let context: ModelContext = ModelContext(container)

            var babyDescriptor: FetchDescriptor<LocalBaby> = FetchDescriptor()
            babyDescriptor.fetchLimit                      = 1
            guard let baby = try context.fetch(babyDescriptor).first else { return [] }

            var feedingDescriptor: FetchDescriptor<LocalFeeding> = FetchDescriptor(
                sortBy: [SortDescriptor(\.fedAt, order: .reverse)]
            )
            feedingDescriptor.fetchLimit = 1
            let lastFeeding: Feeding?    = try context.fetch(feedingDescriptor).first?.feeding

            return FeedingWidgetEntry.timeline(
                babyName: baby.name,
                content:  FeedingActivityContent(
                    lastFeeding:            lastFeeding,
                    feedingIntervalMinutes: baby.feedingIntervalMinutes,
                    lastLoggedBy:           nil
                ),
                now:      now
            )
        } catch {
            logger.error("The widget couldn't read the store: \(error)")
            return []
        }
    }
}
