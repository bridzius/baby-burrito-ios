import BabyCore

@MainActor
final class RecordingSyncQueue: SyncQueue {
    private(set) var changes: [PendingChange] = []

    func enqueue(_ change: PendingChange) {
        changes.append(change)
    }
}
