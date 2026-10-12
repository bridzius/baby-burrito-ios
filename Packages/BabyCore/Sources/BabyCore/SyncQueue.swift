@MainActor
public protocol SyncQueue {
    func enqueue(_ change: PendingChange)
}
