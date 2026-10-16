// What the coordinator needs from CKSyncEngine, so tests can record the changes instead.
@MainActor
public protocol SyncEngine: AnyObject {
    func add(_ changes: CloudChanges)
}
