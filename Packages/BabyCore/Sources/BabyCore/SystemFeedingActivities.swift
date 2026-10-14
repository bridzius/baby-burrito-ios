#if os(iOS)
import ActivityKit
import Foundation

public struct SystemFeedingActivities: FeedingActivities {
    public init() {}

    public var running: FeedingActivityState? {
        guard let activity = Self.runningActivity() else { return nil }
        return FeedingActivityState(
            attributes: activity.attributes,
            content:    activity.content.state
        )
    }

    public func start(_ state: FeedingActivityState) throws {
        _ = try Activity.request(
            attributes: state.attributes,
            content:    Self.activityContent(state.content),
            pushType:   nil
        )
    }

    public func update(to content: FeedingActivityContent) async {
        await Self.updateRunningActivity(to: content)
    }

    public func end() async {
        await Self.endEveryActivity()
    }

    // Activity isn't Sendable, so each one is found and used within a single nonisolated call.
    private nonisolated static func runningActivity() -> Activity<FeedingActivityAttributes>? {
        Activity<FeedingActivityAttributes>.activities.first { activity in
            activity.activityState == .active || activity.activityState == .stale
        }
    }

    private nonisolated static func updateRunningActivity(
        to content: FeedingActivityContent
    ) async {
        await runningActivity()?.update(activityContent(content))
    }

    // Includes any activity left over from an earlier run.
    private nonisolated static func endEveryActivity() async {
        for activity in Activity<FeedingActivityAttributes>.activities {
            await activity.end(nil, dismissalPolicy: .immediate)
        }
    }

    // The activity turns stale at the next feeding time, which switches its views to "Due"
    // without an update.
    private nonisolated static func activityContent(
        _ content: FeedingActivityContent
    ) -> ActivityContent<FeedingActivityContent> {
        ActivityContent(state: content, staleDate: content.nextFeedingAt)
    }
}
#endif
