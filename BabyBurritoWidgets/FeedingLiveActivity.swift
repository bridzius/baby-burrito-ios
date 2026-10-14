import ActivityKit
import BabyCore
import SwiftUI
import WidgetKit

struct FeedingLiveActivity: Widget {
    static let compactTimerWidth: CGFloat = 48

    var body: some WidgetConfiguration {
        ActivityConfiguration(for: FeedingActivityAttributes.self) { context in
            ActivityContentView(context: context)
        } dynamicIsland: { context in
            let content: FeedingActivityContent = context.state
            let tapURL: URL                     = Self.tapURL(for: context.attributes)

            return DynamicIsland {
                DynamicIslandExpandedRegion(.bottom) {
                    ActivityLockScreenView(
                        babyName: context.attributes.babyName,
                        content:  content,
                        canLog:   context.attributes.canLog,
                        isDue:    context.isStale
                    )
                }
            } compactLeading: {
                if let kind = content.lastKind {
                    Image(systemName: kind.symbolName)
                        .foregroundStyle(kind.color)
                }
            } compactTrailing: {
                if let nextFeedingAt = content.nextFeedingAt {
                    compactTimer(nextFeedingAt: nextFeedingAt, isDue: context.isStale)
                }
            } minimal: {
                if let kind = content.lastKind,
                   let lastFedAt = content.lastFedAt,
                   let nextFeedingAt = content.nextFeedingAt {
                    ActivityRing(
                        kind:          kind,
                        lastFedAt:     lastFedAt,
                        nextFeedingAt: nextFeedingAt,
                        isDue:         context.isStale
                    )
                }
            }
            .widgetURL(tapURL)
        }
        .supplementalActivityFamilies([.small])
    }

    // The 18 Pro's narrower island leaves little room, so the compact timer drops the seconds.
    private func compactTimer(nextFeedingAt: Date, isDue: Bool) -> some View {
        let timer: Text = isDue
            ? ActivityTimer.countUp(from: nextFeedingAt, isLuminanceReduced: true)
            : ActivityTimer.countdown(to: nextFeedingAt, isLuminanceReduced: true)
        return timer
            .numerals(.body)
            .frame(maxWidth: Self.compactTimerWidth)
    }

    // Viewers can't log, and the app checks again, because the link is untrusted.
    static func tapURL(for attributes: FeedingActivityAttributes) -> URL {
        guard attributes.canLog else { return DeepLink.today.url }
        return DeepLink.logFeeding(zoneName: attributes.zoneName).url
    }
}

private struct ActivityContentView: View {
    let context: ActivityViewContext<FeedingActivityAttributes>

    @Environment(\.activityFamily) private var activityFamily: ActivityFamily

    var body: some View {
        switch activityFamily {
        case .small:
            ActivitySmartStackView(content: context.state, isDue: context.isStale)
                .widgetURL(DeepLink.today.url)
        default:
            ActivityLockScreenView(
                babyName: context.attributes.babyName,
                content:  context.state,
                canLog:   context.attributes.canLog,
                isDue:    context.isStale
            )
            .widgetURL(FeedingLiveActivity.tapURL(for: context.attributes))
        }
    }
}
