import CloudKit

// CKSyncEngine's own events have no public initializers, so the engine adapter translates
// the few the coordinator handles into these.
public enum SyncEvent: Sendable {
    case fetched(saved: [CKRecord], deleted: [DeletedRecord])
    case sent(saved: [CKRecord], failed: [FailedRecordSave])
}

public struct DeletedRecord: Sendable {
    public let recordID: CKRecord.ID
    public let recordType: CKRecord.RecordType

    public init(recordID: CKRecord.ID, recordType: CKRecord.RecordType) {
        self.recordID   = recordID
        self.recordType = recordType
    }
}

public struct FailedRecordSave: Sendable {
    public let record: CKRecord
    public let errorCode: CKError.Code

    public init(record: CKRecord, errorCode: CKError.Code) {
        self.record    = record
        self.errorCode = errorCode
    }
}
