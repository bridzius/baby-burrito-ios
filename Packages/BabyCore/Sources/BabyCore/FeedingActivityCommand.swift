// ActivityKit ends an activity 8 hours after it starts, so a feeding logged in the foreground
// restarts it to reset that clock. Starting is only reliable in the foreground; anything that
// happens in the background can only update.
public enum FeedingActivityCommand: Equatable, Sendable {
    case none
    case start
    case restart
    case update
    case end

    public init(
        isPreferenceOn: Bool,
        isForeground:   Bool,
        running:        FeedingActivityState?,
        desired:        FeedingActivityState
    ) {
        guard isPreferenceOn else { self = running == nil ? .none : .end; return }
        guard let running else { self = isForeground ? .start : .none; return }
        guard running != desired else { self = .none; return }

        let attributesChanged: Bool = running.attributes != desired.attributes
        let newerFeeding: Bool      = Self.isNewer(desired.content, than: running.content)

        guard !(isForeground && (attributesChanged || newerFeeding)) else {
            self = .restart
            return
        }
        // Attributes are fixed for an activity's life; a new name waits for the foreground.
        self = attributesChanged ? .none : .update
    }

    private static func isNewer(
        _ content:           FeedingActivityContent,
        than runningContent: FeedingActivityContent
    ) -> Bool {
        guard let lastFedAt = content.lastFedAt else { return false }
        guard let runningLastFedAt = runningContent.lastFedAt else { return true }
        return lastFedAt > runningLastFedAt
    }
}
