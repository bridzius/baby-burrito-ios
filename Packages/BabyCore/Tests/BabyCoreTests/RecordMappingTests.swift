import CloudKit
import Foundation
import Testing
@testable import BabyCore

struct RecordMappingTests {
    let zoneName: String       = "BabyLog-test"
    let modifiedAt: Date       = .vilnius(2026, 4, 2, hour: 9)
    let fedAt: Date            = .vilnius(2026, 4, 2, hour: 7)

    func synced(_ details: FeedingDetails) -> SyncedFeeding {
        SyncedFeeding(
            feeding:          Feeding(id: UUID(), fedAt: fedAt, details: details),
            clientModifiedAt: modifiedAt,
            authorRecordName: nil
        )
    }

    @Test func baby_round_trips() throws {
        let record: CKRecord = try RecordMapping.babyRecord(
            .ona, zoneName: zoneName, systemFields: nil
        )

        #expect(record.recordType == "Baby")
        #expect(record.recordID.recordName == "baby")
        #expect(record.recordID.zoneID.zoneName == zoneName)
        #expect(RecordMapping.baby(from: record) == .ona)
    }

    @Test(arguments: [
        FeedingDetails(kind: .formula, amountMl: 90),
        FeedingDetails(kind: .breastMilk, amountMl: 60),
        FeedingDetails(kind: .nursing, durationMinutes: 15, side: .left),
        FeedingDetails(kind: .nursing, durationMinutes: 20, side: .right),
        FeedingDetails(kind: .nursing, durationMinutes: 5, side: .both),
    ])
    func feeding_round_trips_for_every_kind_and_side(details: FeedingDetails) throws {
        let feeding: SyncedFeeding = synced(details)

        let record: CKRecord = try RecordMapping.feedingRecord(
            feeding, zoneName: zoneName, systemFields: nil
        )

        #expect(record.recordType == "Feeding")
        #expect(record.recordID.recordName == feeding.feeding.id.uuidString)
        #expect(RecordMapping.feeding(from: record) == feeding)
    }

    @Test func clearing_a_field_removes_it_from_the_record() throws {
        let nursing: SyncedFeeding = synced(.nursingLeft)
        let record: CKRecord       = try RecordMapping.feedingRecord(
            nursing, zoneName: zoneName, systemFields: nil
        )
        let bottle: SyncedFeeding  = SyncedFeeding(
            feeding:          Feeding(id: nursing.feeding.id, fedAt: fedAt, details: .formula90),
            clientModifiedAt: modifiedAt,
            authorRecordName: nil
        )

        let rewritten: CKRecord = try RecordMapping.feedingRecord(
            bottle, zoneName: zoneName, systemFields: SystemFields.encoded(record)
        )

        #expect(rewritten.encryptedValues["side"] == nil)
        #expect(rewritten.encryptedValues["durationMinutes"] == nil)
        #expect(RecordMapping.feeding(from: rewritten) == bottle)
    }

    @Test func weighing_round_trips_under_its_day_name() throws {
        let weighing: SyncedWeighing = SyncedWeighing(
            weighing:         Weighing(weighedOn: .vilnius(2026, 3, 20), grams: 4_250),
            clientModifiedAt: modifiedAt
        )

        let record: CKRecord = try RecordMapping.weighingRecord(
            weighing, zoneName: zoneName, systemFields: nil, calendar: .vilnius
        )

        #expect(record.recordType == "Weighing")
        #expect(record.recordID.recordName == "weighing-2026-03-20")
        #expect(RecordMapping.weighing(from: record) == weighing)
    }

    @Test func every_user_field_is_encrypted() throws {
        let record: CKRecord = try RecordMapping.feedingRecord(
            synced(.nursingLeft), zoneName: zoneName, systemFields: nil
        )

        // allKeys() lists encrypted keys too, so every key must be one of them.
        #expect(Set(record.allKeys()) == Set(record.encryptedValues.allKeys()))
        #expect(!record.encryptedValues.allKeys().isEmpty)
    }

    @Test func stored_system_fields_keep_the_record_identity() throws {
        let original: CKRecord = try RecordMapping.babyRecord(
            .ona, zoneName: zoneName, systemFields: nil
        )

        let rebuilt: CKRecord = try RecordMapping.babyRecord(
            .ona, zoneName: zoneName, systemFields: SystemFields.encoded(original)
        )

        #expect(rebuilt.recordID == original.recordID)
        #expect(rebuilt.recordType == original.recordType)
    }

    @Test func a_feeding_without_a_fed_at_cannot_be_read() {
        let record: CKRecord = CKRecord(
            recordType: "Feeding",
            recordID:   RecordMapping.feedingRecordID(id: UUID(), zoneName: zoneName)
        )
        record.encryptedValues["kind"] = "formula"

        #expect(RecordMapping.feeding(from: record) == nil)
    }

    @Test func a_feeding_without_a_modification_date_loses_every_conflict() throws {
        let record: CKRecord = try RecordMapping.feedingRecord(
            synced(.formula90), zoneName: zoneName, systemFields: nil
        )
        record.encryptedValues["clientModifiedAt"] = nil

        #expect(RecordMapping.feeding(from: record)?.clientModifiedAt == .distantPast)
    }
}
