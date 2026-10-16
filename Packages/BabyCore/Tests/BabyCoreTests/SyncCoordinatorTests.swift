import CloudKit
import Foundation
import SwiftData
import Testing
@testable import BabyCore

@MainActor
struct SyncCoordinatorTests {
    let now: Date                      = .vilnius(2026, 4, 2, hour: 9)
    let container: ModelContainer
    let coordinator: SyncCoordinator
    let engine: RecordingSyncEngine    = RecordingSyncEngine()
    let store: FeedingStore

    init() throws {
        container   = try LocalStore.inMemoryContainer()
        coordinator = SyncCoordinator(modelContext: container.mainContext, calendar: .vilnius)
        store       = FeedingStore(
            modelContext: container.mainContext,
            syncQueue:    coordinator,
            calendar:     .vilnius,
            now:          { [now] in now }
        )
    }

    func feedings() throws -> [LocalFeeding] {
        try container.mainContext.fetch(FetchDescriptor<LocalFeeding>())
    }

    func remoteFeeding(
        id:         UUID           = UUID(),
        details:    FeedingDetails = .formula90,
        modifiedAt: Date,
        zoneName:   String
    ) throws -> CKRecord {
        let synced: SyncedFeeding = SyncedFeeding(
            feeding:          Feeding(
                id: id, fedAt: .vilnius(2026, 4, 2, hour: 7), details: details
            ),
            clientModifiedAt: modifiedAt,
            authorRecordName: nil
        )
        return try RecordMapping.feedingRecord(synced, zoneName: zoneName, systemFields: nil)
    }

    // MARK: Incoming

    @Test func incoming_save_inserts_the_feeding_with_its_system_fields() throws {
        let baby: LocalBaby  = try store.createBaby(.ona)
        let record: CKRecord = try remoteFeeding(modifiedAt: now, zoneName: baby.zoneName)

        try coordinator.handle(.fetched(saved: [record], deleted: []))

        let stored: [LocalFeeding] = try feedings()
        #expect(stored.map(\.id.uuidString) == [record.recordID.recordName])
        #expect(stored.first?.feeding.details == .formula90)
        #expect(stored.first?.encodedSystemFields != nil)
    }

    @Test func incoming_save_updates_an_older_local_feeding() throws {
        let baby: LocalBaby       = try store.createBaby(.ona)
        let local: LocalFeeding   = try store.log(fedAt: now, details: .formula90)
        let record: CKRecord      = try remoteFeeding(
            id: local.id, details: .nursingLeft, modifiedAt: now.addingTimeInterval(60),
            zoneName: baby.zoneName
        )

        try coordinator.handle(.fetched(saved: [record], deleted: []))

        #expect(try feedings().first?.feeding.details == .nursingLeft)
    }

    @Test func incoming_save_keeps_a_newer_local_edit() throws {
        let baby: LocalBaby     = try store.createBaby(.ona)
        let local: LocalFeeding = try store.log(fedAt: now, details: .formula90)
        let record: CKRecord    = try remoteFeeding(
            id: local.id, details: .nursingLeft, modifiedAt: now.addingTimeInterval(-60),
            zoneName: baby.zoneName
        )

        try coordinator.handle(.fetched(saved: [record], deleted: []))

        #expect(try feedings().first?.feeding.details == .formula90)
        #expect(try feedings().first?.encodedSystemFields != nil)
    }

    @Test func incoming_baby_creates_the_baby_log() throws {
        let record: CKRecord = try RecordMapping.babyRecord(
            .ona, zoneName: "BabyLog-remote", systemFields: nil
        )

        try coordinator.handle(.fetched(saved: [record], deleted: []))

        let babies: [LocalBaby] = try container.mainContext.fetch(FetchDescriptor<LocalBaby>())
        #expect(babies.map(\.baby) == [.ona])
        #expect(babies.map(\.zoneName) == ["BabyLog-remote"])
    }

    @Test func incoming_delete_removes_the_feeding() throws {
        let baby: LocalBaby     = try store.createBaby(.ona)
        let local: LocalFeeding = try store.log(fedAt: now, details: .formula90)
        let deleted: DeletedRecord = DeletedRecord(
            recordID:   RecordMapping.feedingRecordID(id: local.id, zoneName: baby.zoneName),
            recordType: "Feeding"
        )

        try coordinator.handle(.fetched(saved: [], deleted: [deleted]))

        #expect(try feedings().isEmpty)
    }

    @Test func incoming_weighing_save_and_delete() throws {
        let baby: LocalBaby = try store.createBaby(.ona)
        let record: CKRecord = try RecordMapping.weighingRecord(
            SyncedWeighing(
                weighing:         Weighing(weighedOn: .vilnius(2026, 3, 20), grams: 4_250),
                clientModifiedAt: now
            ),
            zoneName: baby.zoneName, systemFields: nil, calendar: .vilnius
        )

        try coordinator.handle(.fetched(saved: [record], deleted: []))
        let weighings: [LocalWeighing] = try container.mainContext.fetch(
            FetchDescriptor<LocalWeighing>()
        )
        #expect(weighings.map(\.weighing) == [
            Weighing(weighedOn: .vilnius(2026, 3, 20), grams: 4_250),
        ])

        try coordinator.handle(.fetched(saved: [], deleted: [
            DeletedRecord(recordID: record.recordID, recordType: "Weighing"),
        ]))
        #expect(try container.mainContext.fetch(FetchDescriptor<LocalWeighing>()).isEmpty)
    }

    // MARK: Outgoing

    @Test func changes_wait_for_the_engine_and_then_go_out_in_order() throws {
        let baby: LocalBaby     = try store.createBaby(.ona)
        let local: LocalFeeding = try store.log(fedAt: now, details: .formula90)
        #expect(engine.added.isEmpty)

        try coordinator.start(with: engine, uploadingEverything: false)

        #expect(engine.zoneChanges == [
            .saveZone(CKRecordZone(zoneID: RecordMapping.zoneID(zoneName: baby.zoneName))),
        ])
        #expect(engine.recordChanges == [
            .saveRecord(RecordMapping.babyRecordID(zoneName: baby.zoneName)),
            .saveRecord(RecordMapping.feedingRecordID(id: local.id, zoneName: baby.zoneName)),
        ])
    }

    @Test func the_first_start_uploads_everything_on_the_phone() throws {
        let baby: LocalBaby     = try store.createBaby(.ona)
        let local: LocalFeeding = try store.log(fedAt: now, details: .formula90)
        _ = try store.logWeighing(weighedOn: .vilnius(2026, 3, 20), grams: 4_250)
        let restarted: SyncCoordinator = SyncCoordinator(
            modelContext: container.mainContext, calendar: .vilnius
        )

        try restarted.start(with: engine, uploadingEverything: true)

        #expect(Set(engine.recordChanges) == [
            .saveRecord(RecordMapping.babyRecordID(zoneName: baby.zoneName)),
            .saveRecord(RecordMapping.feedingRecordID(id: local.id, zoneName: baby.zoneName)),
            .saveRecord(RecordMapping.weighingRecordID(
                weighedOn: .vilnius(2026, 3, 20), zoneName: baby.zoneName, calendar: .vilnius
            )),
        ])
    }

    @Test func the_outgoing_batch_is_built_from_the_local_rows() throws {
        let baby: LocalBaby     = try store.createBaby(.ona)
        let local: LocalFeeding = try store.log(fedAt: now, details: .nursingLeft)
        let recordID: CKRecord.ID = RecordMapping.feedingRecordID(
            id: local.id, zoneName: baby.zoneName
        )

        let record: CKRecord? = coordinator.recordToSend(recordID)

        #expect(record.flatMap(RecordMapping.feeding(from:))?.feeding == local.feeding)
        #expect(coordinator.recordToSend(RecordMapping.babyRecordID(zoneName: baby.zoneName))
            .flatMap(RecordMapping.baby(from:)) == .ona)
    }

    @Test func a_deleted_row_has_no_record_to_send() throws {
        let baby: LocalBaby = try store.createBaby(.ona)

        let recordID: CKRecord.ID = RecordMapping.feedingRecordID(
            id: UUID(), zoneName: baby.zoneName
        )

        #expect(coordinator.recordToSend(recordID) == nil)
    }

    @Test func sent_records_keep_their_system_fields() throws {
        let baby: LocalBaby     = try store.createBaby(.ona)
        let local: LocalFeeding = try store.log(fedAt: now, details: .formula90)
        let sent: CKRecord      = try #require(coordinator.recordToSend(
            RecordMapping.feedingRecordID(id: local.id, zoneName: baby.zoneName)
        ))

        try coordinator.handle(.sent(saved: [sent], failed: []))

        #expect(local.encodedSystemFields != nil)
    }

    @Test func undo_before_the_window_closes_sends_nothing() throws {
        _ = try store.createBaby(.ona)
        let local: LocalFeeding = try store.log(fedAt: now, details: .formula90)
        try coordinator.start(with: engine, uploadingEverything: false)
        let changesBeforeDelete: Int = engine.recordChanges.count

        let deleted: DeletedFeeding = try store.delete(local)
        _ = try store.restore(deleted)

        #expect(engine.recordChanges.count == changesBeforeDelete)
    }

    @Test func a_confirmed_delete_is_sent() throws {
        let baby: LocalBaby     = try store.createBaby(.ona)
        let local: LocalFeeding = try store.log(fedAt: now, details: .formula90)
        try coordinator.start(with: engine, uploadingEverything: false)

        store.confirmDeletion(try store.delete(local))

        #expect(engine.recordChanges.last == .deleteRecord(
            RecordMapping.feedingRecordID(id: local.id, zoneName: baby.zoneName)
        ))
    }

    @Test func a_missing_zone_is_saved_again_before_the_record() throws {
        let baby: LocalBaby     = try store.createBaby(.ona)
        let local: LocalFeeding = try store.log(fedAt: now, details: .formula90)
        try coordinator.start(with: engine, uploadingEverything: false)
        let record: CKRecord    = try #require(coordinator.recordToSend(
            RecordMapping.feedingRecordID(id: local.id, zoneName: baby.zoneName)
        ))

        try coordinator.handle(.sent(saved: [], failed: [
            FailedRecordSave(record: record, errorCode: .zoneNotFound),
        ]))

        #expect(engine.added.last == CloudChanges(
            zoneChanges:   [.saveZone(CKRecordZone(zoneID: record.recordID.zoneID))],
            recordChanges: [.saveRecord(record.recordID)]
        ))
    }
}

@MainActor
struct SyncConflictTests {
    let now: Date                      = .vilnius(2026, 4, 2, hour: 9)
    let container: ModelContainer
    let coordinator: SyncCoordinator
    let engine: RecordingSyncEngine    = RecordingSyncEngine()
    let store: FeedingStore

    init() throws {
        container   = try LocalStore.inMemoryContainer()
        coordinator = SyncCoordinator(modelContext: container.mainContext, calendar: .vilnius)
        store       = FeedingStore(
            modelContext: container.mainContext,
            syncQueue:    coordinator,
            calendar:     .vilnius,
            now:          { [now] in now }
        )
    }

    func conflict(
        on local:   LocalFeeding,
        serverEdit: FeedingDetails,
        modifiedAt: Date
    ) throws -> SyncEvent {
        let sent: CKRecord = try #require(coordinator.recordToSend(
            RecordMapping.feedingRecordID(id: local.id, zoneName: local.zoneName)
        ))
        let server: CKRecord = try RecordMapping.feedingRecord(
            SyncedFeeding(
                feeding:          Feeding(id: local.id, fedAt: local.fedAt, details: serverEdit),
                clientModifiedAt: modifiedAt,
                authorRecordName: nil
            ),
            zoneName:     local.zoneName,
            systemFields: nil
        )
        return .sent(saved: [], failed: [
            FailedRecordSave(record: sent, errorCode: .serverRecordChanged, serverRecord: server),
        ])
    }

    @Test func a_newer_local_edit_is_sent_again_on_top_of_the_server_record() throws {
        _ = try store.createBaby(.ona)
        let local: LocalFeeding = try store.log(fedAt: now, details: .formula90)
        try coordinator.start(with: engine, uploadingEverything: false)
        let event: SyncEvent    = try conflict(
            on: local, serverEdit: .nursingLeft, modifiedAt: now.addingTimeInterval(-60)
        )

        try coordinator.handle(event)

        #expect(local.feeding.details == .formula90)
        #expect(local.encodedSystemFields != nil)
        #expect(engine.recordChanges.last == .saveRecord(
            RecordMapping.feedingRecordID(id: local.id, zoneName: local.zoneName)
        ))
    }

    @Test func a_newer_server_edit_replaces_the_local_one() throws {
        _ = try store.createBaby(.ona)
        let local: LocalFeeding = try store.log(fedAt: now, details: .formula90)
        try coordinator.start(with: engine, uploadingEverything: false)
        let changesBefore: Int  = engine.recordChanges.count
        let event: SyncEvent    = try conflict(
            on: local, serverEdit: .nursingLeft, modifiedAt: now.addingTimeInterval(60)
        )

        try coordinator.handle(event)

        #expect(local.feeding.details == .nursingLeft)
        #expect(engine.recordChanges.count == changesBefore)
    }
}
