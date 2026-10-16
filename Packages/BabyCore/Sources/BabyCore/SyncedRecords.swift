import CloudKit
import Foundation
import SwiftData

// The local rows behind CloudKit records: builds outgoing records from them and stores
// incoming ones, as they arrive (ADR 0005), keeping a local edit that is newer.
@MainActor
struct SyncedRecords {
    let modelContext: ModelContext
    let calendar: Calendar

    // MARK: Outgoing

    func record(for recordID: CKRecord.ID) throws -> CKRecord? {
        let recordName: String = recordID.recordName
        if recordName == RecordMapping.babyRecordName {
            guard let localBaby = try localBaby(zoneName: recordID.zoneID.zoneName) else {
                return nil
            }
            return try RecordMapping.babyRecord(
                localBaby.baby,
                zoneName:     localBaby.zoneName,
                systemFields: localBaby.encodedSystemFields
            )
        }
        if recordName.hasPrefix(RecordMapping.weighingRecordPrefix) {
            guard let localWeighing = try localWeighing(recordID: recordID) else { return nil }
            return try RecordMapping.weighingRecord(
                localWeighing.synced,
                zoneName:     localWeighing.zoneName,
                systemFields: localWeighing.encodedSystemFields,
                calendar:     calendar
            )
        }
        guard let id = UUID(uuidString: recordName), let localFeeding = try localFeeding(id: id)
        else { return nil }
        return try RecordMapping.feedingRecord(
            localFeeding.synced,
            zoneName:     localFeeding.zoneName,
            systemFields: localFeeding.encodedSystemFields
        )
    }

    func everyChange() throws -> [PendingChange] {
        let babies: [LocalBaby]        = try modelContext.fetch(FetchDescriptor<LocalBaby>())
        let feedings: [LocalFeeding]   = try modelContext.fetch(FetchDescriptor<LocalFeeding>())
        let weighings: [LocalWeighing] = try modelContext.fetch(FetchDescriptor<LocalWeighing>())

        return babies.map { .saveBaby(zoneName: $0.zoneName) }
            + feedings.map { .saveFeeding(id: $0.id, zoneName: $0.zoneName) }
            + weighings.map { .saveWeighing(weighedOn: $0.weighedOn, zoneName: $0.zoneName) }
    }

    // Nil when the row is gone. Baby records carry no clientModifiedAt, so the server's
    // baby always wins.
    func clientModifiedAt(of recordID: CKRecord.ID) throws -> Date? {
        let recordName: String = recordID.recordName
        if recordName == RecordMapping.babyRecordName {
            let localBaby: LocalBaby? = try localBaby(zoneName: recordID.zoneID.zoneName)
            return localBaby == nil ? nil : RecordMapping.missingModificationDate
        }
        if recordName.hasPrefix(RecordMapping.weighingRecordPrefix) {
            return try localWeighing(recordID: recordID)?.clientModifiedAt
        }
        guard let id = UUID(uuidString: recordName) else { return nil }
        return try localFeeding(id: id)?.clientModifiedAt
    }

    func storeSystemFields(of records: [CKRecord]) throws {
        for record in records {
            try storeSystemFields(SystemFields.encoded(record), for: record.recordID)
        }
        try modelContext.save()
    }

    func clearSystemFields(of recordID: CKRecord.ID) throws {
        try storeSystemFields(nil, for: recordID)
        try modelContext.save()
    }

    // MARK: Incoming

    func save(_ records: [CKRecord]) throws {
        for record in records {
            switch record.recordType {
            case RecordMapping.RecordType.baby:     try saveBaby(record)
            case RecordMapping.RecordType.feeding:  try saveFeeding(record)
            case RecordMapping.RecordType.weighing: try saveWeighing(record)
            default: SyncLog.logger.error("Skipped a record of unknown type \(record.recordType)")
            }
        }
        try modelContext.save()
    }

    func delete(_ deletedRecords: [DeletedRecord]) throws {
        for deleted in deletedRecords {
            switch deleted.recordType {
            case RecordMapping.RecordType.feeding:
                guard let id = UUID(uuidString: deleted.recordID.recordName) else { continue }
                try localFeeding(id: id).map(modelContext.delete)
            case RecordMapping.RecordType.weighing:
                try localWeighing(recordID: deleted.recordID).map(modelContext.delete)
            default:
                SyncLog.logger.error("Ignored a deleted \(deleted.recordType) record")
            }
        }
        try modelContext.save()
    }

    // A different person's data must never stay on the phone, and none of it is sent anywhere.
    func deleteEverything() throws {
        try modelContext.delete(model: LocalFeeding.self)
        try modelContext.delete(model: LocalWeighing.self)
        try modelContext.delete(model: LocalBaby.self)
        try modelContext.save()
    }

    // MARK: Helpers

    private func saveBaby(_ record: CKRecord) throws {
        guard let baby = RecordMapping.baby(from: record) else {
            return SyncLog.logger.error("Skipped an unreadable Baby record")
        }
        let zoneName: String = record.recordID.zoneID.zoneName
        let localBaby: LocalBaby
        if let existing = try self.localBaby(zoneName: zoneName) {
            localBaby = existing
            localBaby.apply(baby)
        } else {
            localBaby = LocalBaby(baby: baby, zoneName: zoneName)
            modelContext.insert(localBaby)
        }
        localBaby.storeSystemFields(SystemFields.encoded(record))
    }

    private func saveFeeding(_ record: CKRecord) throws {
        guard let synced = RecordMapping.feeding(from: record) else {
            return SyncLog.logger.error("Skipped an unreadable Feeding record")
        }
        let localFeeding: LocalFeeding
        if let existing = try self.localFeeding(id: synced.feeding.id) {
            localFeeding = existing
            if synced.clientModifiedAt >= existing.clientModifiedAt { localFeeding.apply(synced) }
        } else {
            localFeeding = LocalFeeding(
                feeding:          synced.feeding,
                zoneName:         record.recordID.zoneID.zoneName,
                clientModifiedAt: synced.clientModifiedAt,
                authorRecordName: synced.authorRecordName
            )
            modelContext.insert(localFeeding)
        }
        localFeeding.storeSystemFields(SystemFields.encoded(record))
    }

    private func saveWeighing(_ record: CKRecord) throws {
        guard let synced = RecordMapping.weighing(from: record) else {
            return SyncLog.logger.error("Skipped an unreadable Weighing record")
        }
        let localWeighing: LocalWeighing
        if let existing = try self.localWeighing(weighedOn: synced.weighing.weighedOn) {
            localWeighing = existing
            if synced.clientModifiedAt >= existing.clientModifiedAt {
                localWeighing.apply(synced.weighing, modifiedAt: synced.clientModifiedAt)
            }
        } else {
            localWeighing = LocalWeighing(
                weighing:         synced.weighing,
                zoneName:         record.recordID.zoneID.zoneName,
                clientModifiedAt: synced.clientModifiedAt
            )
            modelContext.insert(localWeighing)
        }
        localWeighing.storeSystemFields(SystemFields.encoded(record))
    }

    private func storeSystemFields(_ encoded: Data?, for recordID: CKRecord.ID) throws {
        let recordName: String = recordID.recordName
        if recordName == RecordMapping.babyRecordName {
            try localBaby(zoneName: recordID.zoneID.zoneName)?.storeSystemFields(encoded)
        } else if recordName.hasPrefix(RecordMapping.weighingRecordPrefix) {
            try localWeighing(recordID: recordID)?.storeSystemFields(encoded)
        } else if let id = UUID(uuidString: recordName) {
            try localFeeding(id: id)?.storeSystemFields(encoded)
        }
    }

    private func localBaby(zoneName: String) throws -> LocalBaby? {
        try first(FetchDescriptor<LocalBaby>(predicate: #Predicate { $0.zoneName == zoneName }))
    }

    private func localFeeding(id: UUID) throws -> LocalFeeding? {
        try first(FetchDescriptor<LocalFeeding>(predicate: #Predicate { $0.id == id }))
    }

    private func localWeighing(weighedOn: Date) throws -> LocalWeighing? {
        try first(FetchDescriptor<LocalWeighing>(
            predicate: #Predicate { $0.weighedOn == weighedOn }
        ))
    }

    // Weighing records are named by day, so the row is found by naming each candidate's day.
    private func localWeighing(recordID: CKRecord.ID) throws -> LocalWeighing? {
        let zoneName: String = recordID.zoneID.zoneName
        let candidates: [LocalWeighing] = try modelContext.fetch(
            FetchDescriptor<LocalWeighing>(predicate: #Predicate { $0.zoneName == zoneName })
        )
        return candidates.first { candidate in
            RecordMapping.weighingRecordID(
                weighedOn: candidate.weighedOn, zoneName: zoneName, calendar: calendar
            ) == recordID
        }
    }

    private func first<Model: PersistentModel>(_ descriptor: FetchDescriptor<Model>) throws
        -> Model?
    {
        var limited: FetchDescriptor<Model> = descriptor
        limited.fetchLimit                  = 1
        return try modelContext.fetch(limited).first
    }
}
