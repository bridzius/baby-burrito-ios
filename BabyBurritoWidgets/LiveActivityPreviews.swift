import BabyCore
import SwiftUI
import WidgetKit

private enum PreviewActivity {
    static let feedingIntervalMinutes: Int = 180
    static let countingDownMinutesAgo: Int = 97
    static let dueMinutesAgo: Int          = 192
    static let previewWidth: CGFloat       = 370
    static let smartStackWidth: CGFloat    = 160

    static let attributes: FeedingActivityAttributes = FeedingActivityAttributes(
        babyName: "Burrito",
        zoneName: "BabyLog-preview",
        canLog:   true
    )

    static func content(minutesAgo: Int, loggedBy: String? = nil) -> FeedingActivityContent {
        FeedingActivityContent(
            lastFeeding:            Feeding(
                id:      UUID(),
                fedAt:   .now.addingTimeInterval(-TimeInterval(minutesAgo * 60)),
                details: FeedingDetails(kind: .nursing, durationMinutes: 15, side: .left)
            ),
            feedingIntervalMinutes: feedingIntervalMinutes,
            lastLoggedBy:           loggedBy
        )
    }

    static let countingDown: FeedingActivityContent = content(
        minutesAgo: countingDownMinutesAgo, loggedBy: "Dad"
    )
    static let due: FeedingActivityContent = content(minutesAgo: dueMinutesAgo)
}

#Preview("Lock Screen", as: .content, using: PreviewActivity.attributes) {
    FeedingLiveActivity()
} contentStates: {
    PreviewActivity.countingDown
    PreviewActivity.due
}

#Preview("Island compact", as: .dynamicIsland(.compact), using: PreviewActivity.attributes) {
    FeedingLiveActivity()
} contentStates: {
    PreviewActivity.countingDown
    PreviewActivity.due
}

#Preview("Island minimal", as: .dynamicIsland(.minimal), using: PreviewActivity.attributes) {
    FeedingLiveActivity()
} contentStates: {
    PreviewActivity.countingDown
    PreviewActivity.due
}

#Preview("Island expanded", as: .dynamicIsland(.expanded), using: PreviewActivity.attributes) {
    FeedingLiveActivity()
} contentStates: {
    PreviewActivity.countingDown
    PreviewActivity.due
}

// The macros above can't mark an activity stale or dim the display, so these show the views.
#Preview("Lock Screen states") {
    VStack(spacing: 24) {
        ForEach([false, true], id: \.self) { isLuminanceReduced in
            ActivityLockScreenView(
                babyName:  "Burrito",
                content:   PreviewActivity.countingDown,
                canLog:    true,
                isDue:     false,
                showsRing: true
            )
            ActivityLockScreenView(
                babyName:  "Burrito",
                content:   PreviewActivity.due,
                canLog:    false,
                isDue:     true,
                showsRing: true
            )
            .environment(\.isLuminanceReduced, isLuminanceReduced)
        }
    }
    .frame(width: PreviewActivity.previewWidth)
}

#Preview("Smart Stack") {
    VStack(spacing: 24) {
        ActivitySmartStackView(content: PreviewActivity.countingDown, isDue: false)
        ActivitySmartStackView(content: PreviewActivity.due, isDue: true)
        ActivitySmartStackView(content: PreviewActivity.countingDown, isDue: false)
            .environment(\.isLuminanceReduced, true)
    }
    .frame(width: PreviewActivity.smartStackWidth)
}
