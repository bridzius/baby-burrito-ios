import CloudKit
import Foundation
import SwiftData

// Turns local changes into CloudKit pending changes and applies what the engine reports.
// Created at launch without touching CloudKit; changes wait until the engine starts.
@MainActor
public final class SyncCoordinator: SyncQueue {
    private let records: SyncedRecords
    private let calendar: Calendar
    private var engine: (any SyncEngine)?
    private var changesBeforeStart: [PendingChange] = []

    public init(modelContext: ModelContext, calendar: Calendar) {
        self.records  = SyncedRecords(modelContext: modelContext, calendar: calendar)
        self.calendar = calendar
    }

    public func enqueue(_ change: PendingChange) {
        guard let engine else { return changesBeforeStart.append(change) }
        engine.add(.translating(change, calendar: calendar))
    }

    // With no saved engine state, everything already on the phone is uploaded once.
    public func start(with engine: any SyncEngine, uploadingEverything: Bool) throws {
        let everything: [PendingChange] = uploadingEverything ? try records.everyChange() : []
        let waiting: [PendingChange]    = changesBeforeStart
        self.engine                     = engine
        changesBeforeStart              = []

        for change in everything + waiting {
            enqueue(change)
        }
    }

    // Nil when the row is gone, which makes the engine drop the pending save.
    public func recordToSend(_ recordID: CKRecord.ID) -> CKRecord? {
        do {
            return try records.record(for: recordID)
        } catch {
            SyncLog.logger.error("Couldn't build \(recordID.recordName): \(error)")
            return nil
        }
    }

    public func handle(_ event: SyncEvent) throws {
        switch event {
        case .fetched(let saved, let deleted):
            try records.save(saved)
            try records.delete(deleted)
        case .sent(let saved, let failed):
            try records.storeSystemFields(of: saved)
            for failure in failed {
                try retry(failure)
            }
        }
    }

    private func retry(_ failure: FailedRecordSave) throws {
        guard let engine else { preconditionFailure("A send failed before the engine started") }
        let recordID: CKRecord.ID = failure.record.recordID

        switch failure.errorCode {
        case .zoneNotFound:
            engine.add(CloudChanges(
                zoneChanges:   [.saveZone(CKRecordZone(zoneID: recordID.zoneID))],
                recordChanges: [.saveRecord(recordID)]
            ))
        case .serverRecordChanged:
            guard let serverRecord = failure.serverRecord else {
                preconditionFailure("CloudKit reported a changed server record without it")
            }
            try resolveConflict(with: serverRecord, engine: engine)
        case .unknownItem:
            try records.clearSystemFields(of: recordID)
            engine.add(CloudChanges(recordChanges: [.saveRecord(recordID)]))
        default:
            let code: Int = failure.errorCode.rawValue
            SyncLog.logger.error("Sending \(recordID.recordName) failed with code \(code)")
        }
    }

    private func resolveConflict(with serverRecord: CKRecord, engine: any SyncEngine) throws {
        let recordID: CKRecord.ID = serverRecord.recordID
        let resolution: ConflictResolution = ConflictResolver.resolve(
            localModifiedAt:  try records.clientModifiedAt(of: recordID),
            serverModifiedAt: RecordMapping.clientModifiedAt(of: serverRecord)
        )

        switch resolution {
        case .keepServer:
            try records.save([serverRecord])
        case .resendLocal:
            try records.storeSystemFields(of: [serverRecord])
            engine.add(CloudChanges(recordChanges: [.saveRecord(recordID)]))
        case .keepLocalDeletion:
            break
        }
    }
}
