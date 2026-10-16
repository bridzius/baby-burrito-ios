// For previews and UI tests, which never touch CloudKit.
public struct NoSyncQueue: SyncQueue {
    public init() {}

    public func enqueue(_ change: PendingChange) {}
}
