@testable import BabyCore
import CloudKit

@MainActor
final class RecordingSyncEngine: SyncEngine {
    private(set) var added: [CloudChanges] = []

    var recordChanges: [CKSyncEngine.PendingRecordZoneChange] { added.flatMap(\.recordChanges) }
    var zoneChanges: [CKSyncEngine.PendingDatabaseChange] { added.flatMap(\.zoneChanges) }

    func add(_ changes: CloudChanges) {
        added.append(changes)
    }
}
