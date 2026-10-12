// Stands in until private sync (#27) queues changes for CloudKit.
public struct NoSyncQueue: SyncQueue {
    public init() {}

    public func enqueue(_ change: PendingChange) {}
}
