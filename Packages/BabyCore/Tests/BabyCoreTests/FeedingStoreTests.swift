import BabyCore
import Foundation
import SwiftData
import Testing

@MainActor
struct FeedingStoreTests {
    let now: Date                     = .vilnius(2026, 4, 2, hour: 9)
    let container: ModelContainer
    let syncQueue: RecordingSyncQueue = RecordingSyncQueue()
    let store: FeedingStore

    init() throws {
        container = try LocalStore.inMemoryContainer()
        store     = FeedingStore(
            modelContext: container.mainContext,
            syncQueue:    syncQueue,
            calendar:     .vilnius,
            now:          { [now] in now }
        )
    }

    func feedings() throws -> [LocalFeeding] {
        try container.mainContext.fetch(FetchDescriptor<LocalFeeding>())
    }

    func babies() throws -> [LocalBaby] {
        try container.mainContext.fetch(FetchDescriptor<LocalBaby>())
    }

    // MARK: Baby

    @Test func creates_the_baby_in_a_new_baby_log() throws {
        let baby: LocalBaby = try store.createBaby(.ona)

        #expect(try babies().map(\.baby) == [.ona])
        #expect(baby.zoneName.hasPrefix("BabyLog-"))
        #expect(syncQueue.changes == [.saveBaby(zoneName: baby.zoneName)])
    }

    @Test func refuses_a_second_baby() throws {
        _ = try store.createBaby(.ona)

        #expect(throws: FeedingStoreError.babyLogAlreadyExists) {
            try store.createBaby(.ona)
        }
        #expect(try babies().count == 1)
    }

    @Test func rejects_an_invalid_baby() throws {
        var unnamed: Baby = .ona
        unnamed.name      = " "

        #expect(throws: BabyValidationError.emptyName) {
            try store.createBaby(unnamed)
        }
        #expect(try babies().isEmpty)
        #expect(syncQueue.changes.isEmpty)
    }

    @Test func updates_the_baby() throws {
        let baby: LocalBaby            = try store.createBaby(.ona)
        var renamed: Baby              = .ona
        renamed.name                   = "Burrito"
        renamed.feedingIntervalMinutes = 150

        try store.updateBaby(baby, to: renamed)

        #expect(try babies().map(\.baby) == [renamed])
        #expect(syncQueue.changes.last == .saveBaby(zoneName: baby.zoneName))
    }

    @Test func rejects_an_invalid_baby_update() throws {
        let baby: LocalBaby                = try store.createBaby(.ona)
        var tooFrequent: Baby              = .ona
        tooFrequent.feedingIntervalMinutes = 10

        #expect(throws: BabyValidationError.feedingIntervalNotAllowed) {
            try store.updateBaby(baby, to: tooFrequent)
        }
        #expect(baby.baby == .ona)
    }

    // MARK: Feedings

    @Test func logs_a_feeding_in_the_baby_log() throws {
        let baby: LocalBaby = try store.createBaby(.ona)

        let logged: LocalFeeding = try store.log(fedAt: now, details: .formula90)

        #expect(try feedings().map(\.feeding) == [logged.feeding])
        #expect(logged.feeding.details == .formula90)
        #expect(logged.zoneName == baby.zoneName)
        #expect(logged.clientModifiedAt == now)
        #expect(syncQueue.changes.last == .saveFeeding(id: logged.id, zoneName: baby.zoneName))
    }

    @Test func refuses_to_log_without_a_baby() throws {
        #expect(throws: FeedingStoreError.noBabyLog) {
            try store.log(fedAt: now, details: .formula90)
        }
    }

    @Test func rejects_an_invalid_feeding() throws {
        _ = try store.createBaby(.ona)
        let beforeBirth: Date = .vilnius(2026, 3, 13, hour: 23)

        #expect(throws: FeedingValidationError.fedAtBeforeBirthDay) {
            try store.log(fedAt: beforeBirth, details: .formula90)
        }
        #expect(throws: FeedingValidationError.missingSide) {
            try store.log(fedAt: now, details: FeedingDetails(kind: .nursing, durationMinutes: 10))
        }
        #expect(try feedings().isEmpty)
        #expect(syncQueue.changes.count == 1)
    }

    @Test func updates_a_feeding() throws {
        _ = try store.createBaby(.ona)
        let logged: LocalFeeding = try store.log(fedAt: now, details: .formula90)
        let earlier: Date        = now.addingTimeInterval(-30 * 60)

        try store.update(logged, fedAt: earlier, details: .nursingLeft)

        #expect(try feedings().map(\.feeding) == [
            Feeding(id: logged.id, fedAt: earlier, details: .nursingLeft),
        ])
        #expect(syncQueue.changes.last == .saveFeeding(id: logged.id, zoneName: logged.zoneName))
    }

    @Test func rejects_an_invalid_feeding_update() throws {
        _ = try store.createBaby(.ona)
        let logged: LocalFeeding        = try store.log(fedAt: now, details: .formula90)
        let emptyBottle: FeedingDetails = FeedingDetails(kind: .formula, amountMl: 0)

        #expect(throws: FeedingValidationError.amountOutOfRange) {
            try store.update(logged, fedAt: now, details: emptyBottle)
        }
        #expect(logged.feeding.details == .formula90)
    }

    @Test func deletes_a_feeding_locally_and_queues_the_delete_only_once_confirmed() throws {
        _ = try store.createBaby(.ona)
        let logged: LocalFeeding = try store.log(fedAt: now, details: .formula90)
        let changesBefore: Int   = syncQueue.changes.count

        let deleted: DeletedFeeding = try store.delete(logged)

        #expect(try feedings().isEmpty)
        #expect(syncQueue.changes.count == changesBefore)

        store.confirmDeletion(deleted)

        #expect(syncQueue.changes.last == .deleteFeeding(
            id:       deleted.feeding.id,
            zoneName: deleted.zoneName
        ))
    }

    @Test func restore_after_delete_keeps_the_id_and_fields() throws {
        _ = try store.createBaby(.ona)
        let logged: LocalFeeding = try store.log(fedAt: now, details: .nursingLeft)
        let original: Feeding    = logged.feeding

        let deleted: DeletedFeeding = try store.delete(logged)
        let restored: LocalFeeding  = try store.restore(deleted)

        #expect(restored.feeding == original)
        #expect(restored.zoneName == deleted.zoneName)
        #expect(try feedings().map(\.feeding) == [original])
    }

    // MARK: Everything

    @Test func deletes_everything() throws {
        let baby: LocalBaby = try store.createBaby(.ona)
        _ = try store.log(fedAt: now, details: .formula90)
        _ = try store.log(fedAt: now, details: .nursingLeft)

        try store.deleteEverything()

        #expect(try babies().isEmpty)
        #expect(try feedings().isEmpty)
        #expect(syncQueue.changes.last == .deleteBabyLog(zoneName: baby.zoneName))
        _ = try store.createBaby(.ona)
    }
}
