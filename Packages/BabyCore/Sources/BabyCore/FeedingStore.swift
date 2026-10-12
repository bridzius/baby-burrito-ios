import Foundation
import SwiftData

@MainActor
public final class FeedingStore {
    private let modelContext: ModelContext
    private let syncQueue: any SyncQueue
    private let calendar: Calendar
    private let now: () -> Date

    public init(
        modelContext: ModelContext,
        syncQueue:    any SyncQueue,
        calendar:     Calendar,
        now:          @escaping () -> Date
    ) {
        self.modelContext = modelContext
        self.syncQueue    = syncQueue
        self.calendar     = calendar
        self.now          = now
    }

    // MARK: Baby

    public func createBaby(_ baby: Baby) throws -> LocalBaby {
        let validBaby: Baby = try baby.validated(calendar: calendar)
        guard try existingBaby() == nil else { throw FeedingStoreError.babyLogAlreadyExists }

        let localBaby: LocalBaby = LocalBaby(baby: validBaby, zoneName: "BabyLog-\(UUID())")
        modelContext.insert(localBaby)
        try save()

        syncQueue.enqueue(.saveBaby(zoneName: localBaby.zoneName))
        return localBaby
    }

    public func updateBaby(_ localBaby: LocalBaby, to baby: Baby) throws {
        localBaby.apply(try baby.validated(calendar: calendar))
        try save()

        syncQueue.enqueue(.saveBaby(zoneName: localBaby.zoneName))
    }

    // MARK: Feedings

    public func log(fedAt: Date, details: FeedingDetails) throws -> LocalFeeding {
        let localBaby: LocalBaby = try currentBaby()
        let feeding: Feeding     = try validated(
            UUID(), fedAt: fedAt, details: details, in: localBaby
        )

        let localFeeding: LocalFeeding = LocalFeeding(
            feeding:          feeding,
            zoneName:         localBaby.zoneName,
            clientModifiedAt: now()
        )
        modelContext.insert(localFeeding)
        try save()

        syncQueue.enqueue(.saveFeeding(id: feeding.id, zoneName: localFeeding.zoneName))
        return localFeeding
    }

    public func update(_ localFeeding: LocalFeeding, fedAt: Date, details: FeedingDetails) throws {
        let localBaby: LocalBaby = try currentBaby()
        let feeding: Feeding     = try validated(
            localFeeding.id, fedAt: fedAt, details: details, in: localBaby
        )

        localFeeding.apply(feeding, modifiedAt: now())
        try save()

        syncQueue.enqueue(.saveFeeding(id: feeding.id, zoneName: localFeeding.zoneName))
    }

    // The CloudKit delete waits for confirmDeletion, after the Undo window, so an undone delete
    // never reaches the other phone.
    public func delete(_ localFeeding: LocalFeeding) throws -> DeletedFeeding {
        let deleted: DeletedFeeding = DeletedFeeding(
            feeding:          localFeeding.feeding,
            zoneName:         localFeeding.zoneName,
            clientModifiedAt: localFeeding.clientModifiedAt,
            authorRecordName: localFeeding.authorRecordName
        )
        modelContext.delete(localFeeding)
        try save()

        return deleted
    }

    public func confirmDeletion(_ deleted: DeletedFeeding) {
        syncQueue.enqueue(.deleteFeeding(id: deleted.feeding.id, zoneName: deleted.zoneName))
    }

    public func restore(_ deleted: DeletedFeeding) throws -> LocalFeeding {
        let localFeeding: LocalFeeding = LocalFeeding(
            feeding:          deleted.feeding,
            zoneName:         deleted.zoneName,
            clientModifiedAt: deleted.clientModifiedAt,
            authorRecordName: deleted.authorRecordName
        )
        modelContext.insert(localFeeding)
        try save()

        return localFeeding
    }

    // MARK: Everything

    public func deleteEverything() throws {
        let localBabies: [LocalBaby] = try modelContext.fetch(FetchDescriptor<LocalBaby>())
        let zoneNames: [String]      = localBabies.map(\.zoneName)

        try modelContext.delete(model: LocalFeeding.self)
        try modelContext.delete(model: LocalBaby.self)
        try save()

        for zoneName in zoneNames {
            syncQueue.enqueue(.deleteBabyLog(zoneName: zoneName))
        }
    }

    // MARK: Helpers

    private func currentBaby() throws -> LocalBaby {
        guard let localBaby = try existingBaby() else { throw FeedingStoreError.noBabyLog }
        return localBaby
    }

    // Not fetchCount: after a rollback it still counts the discarded insert.
    private func existingBaby() throws -> LocalBaby? {
        var descriptor: FetchDescriptor<LocalBaby> = FetchDescriptor()
        descriptor.fetchLimit                      = 1
        return try modelContext.fetch(descriptor).first
    }

    private func validated(
        _ id:         UUID,
        fedAt:        Date,
        details:      FeedingDetails,
        in localBaby: LocalBaby
    ) throws -> Feeding {
        try Feeding.validated(
            id:        id,
            fedAt:     fedAt,
            details:   details,
            birthDate: localBaby.birthDate,
            now:       now(),
            calendar:  calendar
        )
    }

    private func save() throws {
        do {
            try modelContext.save()
        } catch {
            modelContext.rollback()
            throw error
        }
    }
}
