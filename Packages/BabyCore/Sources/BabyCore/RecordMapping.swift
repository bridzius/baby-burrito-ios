import CloudKit
import Foundation

// Every user field goes through encryptedValues, so only the phones can read it.
public enum RecordMapping {
    static let babyRecordName: String          = "baby"
    static let weighingRecordPrefix: String    = "weighing-"
    // A synced record with no clientModifiedAt loses every conflict to a local edit.
    static let missingModificationDate: Date   = .distantPast

    enum RecordType {
        static let baby: String     = "Baby"
        static let feeding: String  = "Feeding"
        static let weighing: String = "Weighing"
    }

    enum Field {
        static let name: String                   = "name"
        static let birthDate: String              = "birthDate"
        static let feedingIntervalMinutes: String = "feedingIntervalMinutes"
        static let fedAt: String                  = "fedAt"
        static let kind: String                   = "kind"
        static let amountMl: String               = "amountMl"
        static let durationMinutes: String        = "durationMinutes"
        static let side: String                   = "side"
        static let weighedOn: String              = "weighedOn"
        static let grams: String                  = "grams"
        static let clientModifiedAt: String       = "clientModifiedAt"
    }

    // MARK: IDs

    public static func zoneID(zoneName: String) -> CKRecordZone.ID {
        CKRecordZone.ID(zoneName: zoneName, ownerName: CKCurrentUserDefaultName)
    }

    static func babyRecordID(zoneName: String) -> CKRecord.ID {
        CKRecord.ID(recordName: babyRecordName, zoneID: zoneID(zoneName: zoneName))
    }

    static func feedingRecordID(id: UUID, zoneName: String) -> CKRecord.ID {
        CKRecord.ID(recordName: id.uuidString, zoneID: zoneID(zoneName: zoneName))
    }

    // Named by the local day, so two phones weighing on the same day write the same record.
    static func weighingRecordID(
        weighedOn: Date,
        zoneName:  String,
        calendar:  Calendar
    ) -> CKRecord.ID {
        let day: DateComponents = calendar.dateComponents([.year, .month, .day], from: weighedOn)
        guard let year = day.year, let month = day.month, let dayOfMonth = day.day else {
            preconditionFailure("The calendar gave no year, month or day for \(weighedOn)")
        }
        let dayName: String = String(format: "%04d-%02d-%02d", year, month, dayOfMonth)
        return CKRecord.ID(
            recordName: weighingRecordPrefix + dayName,
            zoneID:     zoneID(zoneName: zoneName)
        )
    }

    // MARK: Outgoing

    static func babyRecord(_ baby: Baby, zoneName: String, systemFields: Data?) throws -> CKRecord {
        let record: CKRecord = try SystemFields.record(from: systemFields) ?? CKRecord(
            recordType: RecordType.baby,
            recordID:   babyRecordID(zoneName: zoneName)
        )
        let values: any CKRecordKeyValueSetting  = record.encryptedValues
        values[Field.name]                       = baby.name
        values[Field.birthDate]                  = baby.birthDate
        values[Field.feedingIntervalMinutes]     = baby.feedingIntervalMinutes
        return record
    }

    static func feedingRecord(_ synced: SyncedFeeding, zoneName: String, systemFields: Data?) throws
        -> CKRecord
    {
        let record: CKRecord = try SystemFields.record(from: systemFields) ?? CKRecord(
            recordType: RecordType.feeding,
            recordID:   feedingRecordID(id: synced.feeding.id, zoneName: zoneName)
        )
        let details: FeedingDetails             = synced.feeding.details
        let values: any CKRecordKeyValueSetting = record.encryptedValues
        values[Field.fedAt]                     = synced.feeding.fedAt
        values[Field.kind]                      = details.kind.rawValue
        values[Field.amountMl]                  = details.amountMl
        values[Field.durationMinutes]           = details.durationMinutes
        values[Field.side]                      = details.side?.rawValue
        values[Field.clientModifiedAt]          = synced.clientModifiedAt
        return record
    }

    static func weighingRecord(
        _ synced:     SyncedWeighing,
        zoneName:     String,
        systemFields: Data?,
        calendar:     Calendar
    ) throws -> CKRecord {
        let record: CKRecord = try SystemFields.record(from: systemFields) ?? CKRecord(
            recordType: RecordType.weighing,
            recordID:   weighingRecordID(
                weighedOn: synced.weighing.weighedOn, zoneName: zoneName, calendar: calendar
            )
        )
        let values: any CKRecordKeyValueSetting = record.encryptedValues
        values[Field.weighedOn]                 = synced.weighing.weighedOn
        values[Field.grams]                     = synced.weighing.grams
        values[Field.clientModifiedAt]          = synced.clientModifiedAt
        return record
    }

    // MARK: Incoming

    // Records are stored as they arrive (ADR 0005); only a record missing a field the app
    // can't do without comes back nil.
    static func baby(from record: CKRecord) -> Baby? {
        let values: any CKRecordKeyValueSetting = record.encryptedValues
        guard let name = values[Field.name] as? String,
              let birthDate = values[Field.birthDate] as? Date,
              let feedingIntervalMinutes = values[Field.feedingIntervalMinutes] as? Int
        else { return nil }

        return Baby(
            name:                   name,
            birthDate:              birthDate,
            feedingIntervalMinutes: feedingIntervalMinutes
        )
    }

    static func feeding(from record: CKRecord) -> SyncedFeeding? {
        let values: any CKRecordKeyValueSetting = record.encryptedValues
        guard let id = UUID(uuidString: record.recordID.recordName),
              let fedAt = values[Field.fedAt] as? Date,
              let kindName = values[Field.kind] as? String,
              let kind = FeedingKind(rawValue: kindName)
        else { return nil }

        let details: FeedingDetails = FeedingDetails(
            kind:            kind,
            amountMl:        values[Field.amountMl] as? Int,
            durationMinutes: values[Field.durationMinutes] as? Int,
            side:            (values[Field.side] as? String).flatMap(Side.init(rawValue:))
        )
        return SyncedFeeding(
            feeding:          Feeding(id: id, fedAt: fedAt, details: details),
            clientModifiedAt: values[Field.clientModifiedAt] as? Date ?? missingModificationDate,
            authorRecordName: record.creatorUserRecordID?.recordName
        )
    }

    static func weighing(from record: CKRecord) -> SyncedWeighing? {
        let values: any CKRecordKeyValueSetting = record.encryptedValues
        guard let weighedOn = values[Field.weighedOn] as? Date,
              let grams = values[Field.grams] as? Int
        else { return nil }

        return SyncedWeighing(
            weighing:         Weighing(weighedOn: weighedOn, grams: grams),
            clientModifiedAt: values[Field.clientModifiedAt] as? Date ?? missingModificationDate
        )
    }
}
