import BabyCore
import WidgetKit

struct FeedingWidgetEntry: TimelineEntry {
    let date: Date
    let babyName: String?
    let content: FeedingActivityContent
    let isDue: Bool

    // One entry now and, when a next feeding is known, one at that time to switch to "Due".
    static func timeline(
        babyName: String?,
        content:  FeedingActivityContent,
        now:      Date
    ) -> [FeedingWidgetEntry] {
        guard let nextFeedingAt = content.nextFeedingAt, nextFeedingAt > now else {
            let isDue: Bool = content.nextFeedingAt != nil
            return [entry(at: now, babyName: babyName, content: content, isDue: isDue)]
        }
        return [
            entry(at: now, babyName: babyName, content: content, isDue: false),
            entry(at: nextFeedingAt, babyName: babyName, content: content, isDue: true),
        ]
    }

    private static func entry(
        at date:  Date,
        babyName: String?,
        content:  FeedingActivityContent,
        isDue:    Bool
    ) -> FeedingWidgetEntry {
        FeedingWidgetEntry(date: date, babyName: babyName, content: content, isDue: isDue)
    }
}
