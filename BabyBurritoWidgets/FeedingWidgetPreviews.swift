import BabyCore
import SwiftUI
import WidgetKit

private enum PreviewWidget {
    static let feedingIntervalMinutes: Int = 180
    static let countingDownMinutesAgo: Int = 97
    static let dueMinutesAgo: Int          = 192

    static func entry(minutesAgo: Int, isDue: Bool) -> FeedingWidgetEntry {
        FeedingWidgetEntry(
            date:     .now,
            babyName: "Burrito",
            content:  FeedingActivityContent(
                lastFeeding:            Feeding(
                    id:      UUID(),
                    fedAt:   .now.addingTimeInterval(-TimeInterval(minutesAgo * 60)),
                    details: FeedingDetails(kind: .formula, amountMl: 90)
                ),
                feedingIntervalMinutes: feedingIntervalMinutes,
                lastLoggedBy:           nil
            ),
            isDue:    isDue
        )
    }
}

#Preview("Small", as: .systemSmall) {
    FeedingWidget()
} timeline: {
    PreviewWidget.entry(minutesAgo: PreviewWidget.countingDownMinutesAgo, isDue: false)
    PreviewWidget.entry(minutesAgo: PreviewWidget.dueMinutesAgo, isDue: true)
}

#Preview("Medium", as: .systemMedium) {
    FeedingWidget()
} timeline: {
    PreviewWidget.entry(minutesAgo: PreviewWidget.countingDownMinutesAgo, isDue: false)
    PreviewWidget.entry(minutesAgo: PreviewWidget.dueMinutesAgo, isDue: true)
}
