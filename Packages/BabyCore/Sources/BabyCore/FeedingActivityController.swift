// The single owner of the Live Activity: given what it should show, starts, restarts, updates
// or ends it.
@MainActor
public final class FeedingActivityController {
    private let activities: any FeedingActivities

    public init(activities: any FeedingActivities) {
        self.activities = activities
    }

    public func refresh(
        to desired:     FeedingActivityState,
        isPreferenceOn: Bool,
        isForeground:   Bool
    ) async throws {
        let command: FeedingActivityCommand = FeedingActivityCommand(
            isPreferenceOn: isPreferenceOn,
            isForeground:   isForeground,
            running:        activities.running,
            desired:        desired
        )

        switch command {
        case .none:
            return
        case .start:
            try activities.start(desired)
        case .restart:
            await activities.end()
            try activities.start(desired)
        case .update:
            await activities.update(to: desired.content)
        case .end:
            await activities.end()
        }
    }

    public func end() async {
        guard activities.running != nil else { return }
        await activities.end()
    }
}
