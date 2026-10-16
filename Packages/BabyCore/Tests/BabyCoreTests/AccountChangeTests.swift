import CloudKit
import Foundation
import SwiftData
import Testing
@testable import BabyCore

@MainActor
struct AccountChangeTests {
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

    func rowCount() throws -> Int {
        let context: ModelContext = container.mainContext
        return try context.fetchCount(FetchDescriptor<LocalBaby>())
            + context.fetchCount(FetchDescriptor<LocalFeeding>())
            + context.fetchCount(FetchDescriptor<LocalWeighing>())
    }

    func seedBabyLog() throws -> LocalBaby {
        let baby: LocalBaby = try store.createBaby(.ona)
        _ = try store.log(fedAt: now, details: .formula90)
        _ = try store.logWeighing(weighedOn: .vilnius(2026, 3, 20), grams: 4_250)
        return baby
    }

    @Test(arguments: [AccountChange.signedOut, .switchedAccounts])
    func leaving_the_account_wipes_the_phone_and_sends_nothing(change: AccountChange) throws {
        _ = try seedBabyLog()
        try coordinator.start(with: engine, uploadingEverything: false)
        let changesBefore: Int = engine.added.count

        try coordinator.handle(.accountChanged(change))

        #expect(try rowCount() == 0)
        #expect(engine.added.count == changesBefore)
    }

    @Test func changes_after_leaving_wait_for_a_fresh_engine() throws {
        try coordinator.start(with: engine, uploadingEverything: false)
        try coordinator.handle(.accountChanged(.signedOut))
        let baby: LocalBaby = try store.createBaby(.ona)
        let changesBefore: Int = engine.added.count

        let freshEngine: RecordingSyncEngine = RecordingSyncEngine()
        try coordinator.start(with: freshEngine, uploadingEverything: false)

        #expect(engine.added.count == changesBefore)
        #expect(freshEngine.recordChanges == [
            .saveRecord(RecordMapping.babyRecordID(zoneName: baby.zoneName)),
        ])
    }

    @Test func signing_in_queues_everything_on_the_phone() throws {
        let baby: LocalBaby = try seedBabyLog()
        try coordinator.start(with: engine, uploadingEverything: false)
        let changesBefore: Int = engine.recordChanges.count

        try coordinator.handle(.accountChanged(.signedIn))

        let queuedBySignIn: [CKSyncEngine.PendingRecordZoneChange] = Array(
            engine.recordChanges.dropFirst(changesBefore)
        )
        #expect(try rowCount() == 3)
        #expect(queuedBySignIn.count == 3)
        #expect(queuedBySignIn.contains(
            .saveRecord(RecordMapping.babyRecordID(zoneName: baby.zoneName))
        ))
    }

    @Test(arguments: [
        (CKAccountStatus.available, ICloudAccount.available),
        (.noAccount, .signedOut),
        (.restricted, .restricted),
        (.couldNotDetermine, .unavailable),
        (.temporarilyUnavailable, .unavailable),
    ])
    func account_status_maps_to_what_settings_shows(
        status:   CKAccountStatus,
        expected: ICloudAccount
    ) {
        #expect(ICloudAccount(status) == expected)
    }

    @Test func only_an_available_account_needs_no_attention() {
        #expect(!ICloudAccount.available.needsAttention)
        #expect(ICloudAccount.signedOut.needsAttention)
        #expect(ICloudAccount.restricted.needsAttention)
        #expect(ICloudAccount.unavailable.needsAttention)
    }
}
