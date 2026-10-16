#if DEBUG
import CloudKit

// Logs every event; the spike only reads, so it never has a batch to send.
final class SharingSpikeEngineDelegate: CKSyncEngineDelegate {
    private let log: @Sendable (String) -> Void

    init(log: @escaping @Sendable (String) -> Void) {
        self.log = log
    }

    func handleEvent(_ event: CKSyncEngine.Event, syncEngine: CKSyncEngine) async {
        switch event {
        case .fetchedDatabaseChanges(let changes):
            for modification in changes.modifications {
                log("Zone changed: \(modification.zoneID.zoneName) owner \(modification.zoneID.ownerName)")
            }
            for deletion in changes.deletions {
                log("Zone deleted: \(deletion.zoneID.zoneName) reason \(deletion.reason)")
            }
        case .fetchedRecordZoneChanges(let changes):
            for modification in changes.modifications {
                let record: CKRecord = modification.record
                let fields: String   = record.encryptedValues.allKeys().sorted().map { key in
                    "\(key)=\(String(describing: record.encryptedValues[key]))"
                }.joined(separator: ", ")
                log("Record \(record.recordType) \(record.recordID.recordName): \(fields)")
            }
            for deletion in changes.deletions {
                log("Record deleted: \(deletion.recordID.recordName)")
            }
        case .accountChange(let change):
            log("Account change: \(change)")
        case .stateUpdate:
            log("State updated (not persisted in the spike)")
        default:
            log("Event: \(event)")
        }
    }

    func nextRecordZoneChangeBatch(
        _ context:  CKSyncEngine.SendChangesContext,
        syncEngine: CKSyncEngine
    ) async -> CKSyncEngine.RecordZoneChangeBatch? {
        nil
    }
}
#endif
