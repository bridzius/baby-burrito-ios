import BabyCore
import Foundation
import SwiftData
import Testing

@MainActor
struct WeighingStoreTests {
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

    func weighings() throws -> [Weighing] {
        try container.mainContext.fetch(FetchDescriptor<LocalWeighing>()).map(\.weighing)
    }

    @Test func logs_a_weighing_on_its_day() throws {
        let baby: LocalBaby = try store.createBaby(.ona)

        _ = try store.logWeighing(weighedOn: .vilnius(2026, 3, 20, hour: 15), grams: 4_250)

        #expect(try weighings() == [Weighing(weighedOn: .vilnius(2026, 3, 20), grams: 4_250)])
        #expect(syncQueue.changes.last == .saveWeighing(
            weighedOn: .vilnius(2026, 3, 20), zoneName: baby.zoneName
        ))
    }

    @Test func logging_the_same_day_again_replaces_its_weight() throws {
        _ = try store.createBaby(.ona)

        _ = try store.logWeighing(weighedOn: .vilnius(2026, 3, 20, hour: 8), grams: 4_250)
        _ = try store.logWeighing(weighedOn: .vilnius(2026, 3, 20, hour: 18), grams: 4_300)

        #expect(try weighings() == [Weighing(weighedOn: .vilnius(2026, 3, 20), grams: 4_300)])
    }

    @Test func rejects_an_invalid_weighing() throws {
        _ = try store.createBaby(.ona)

        #expect(throws: WeighingValidationError.weighedOnBeforeBirthDay) {
            try store.logWeighing(weighedOn: .vilnius(2026, 3, 1), grams: 4_250)
        }
        #expect(try weighings().isEmpty)
        #expect(syncQueue.changes.count == 1)
    }

    @Test func refuses_to_log_a_weighing_without_a_baby() {
        #expect(throws: FeedingStoreError.noBabyLog) {
            try store.logWeighing(weighedOn: .vilnius(2026, 3, 20), grams: 4_250)
        }
    }

    @Test func deletes_a_weighing_and_queues_the_delete() throws {
        let baby: LocalBaby               = try store.createBaby(.ona)
        let localWeighing: LocalWeighing  = try store.logWeighing(
            weighedOn: .vilnius(2026, 3, 20), grams: 4_250
        )

        try store.deleteWeighing(localWeighing)

        #expect(try weighings().isEmpty)
        #expect(syncQueue.changes.last == .deleteWeighing(
            weighedOn: .vilnius(2026, 3, 20), zoneName: baby.zoneName
        ))
    }

    @Test func refuses_to_move_the_birth_date_after_the_earliest_weighing() throws {
        let baby: LocalBaby = try store.createBaby(.ona)
        _ = try store.logWeighing(weighedOn: .vilnius(2026, 3, 14), grams: 3_400)
        var laterBirth: Baby = .ona
        laterBirth.birthDate = .vilnius(2026, 3, 15)

        #expect(throws: BabyValidationError.birthDateAfterEarliestWeighing) {
            try store.updateBaby(baby, to: laterBirth)
        }
    }

    @Test func deleting_everything_removes_weighings() throws {
        _ = try store.createBaby(.ona)
        _ = try store.logWeighing(weighedOn: .vilnius(2026, 3, 20), grams: 4_250)

        try store.deleteEverything()

        #expect(try weighings().isEmpty)
    }
}
