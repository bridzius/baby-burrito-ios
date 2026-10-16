import CloudKit

@MainActor
final class CloudSyncEngine: SyncEngine {
    private let engine: CKSyncEngine
    private let delegate: CloudSyncEngineDelegate

    init(
        database:   CKDatabase,
        savedState: CKSyncEngine.State.Serialization?,
        stateStore: SyncStateStore,
        coordinator: SyncCoordinator
    ) {
        delegate = CloudSyncEngineDelegate(coordinator: coordinator, stateStore: stateStore)
        engine   = CKSyncEngine(CKSyncEngine.Configuration(
            database:           database,
            stateSerialization: savedState,
            delegate:           delegate
        ))
    }

    func add(_ changes: CloudChanges) {
        engine.state.add(pendingDatabaseChanges: changes.zoneChanges)
        engine.state.add(pendingRecordZoneChanges: changes.recordChanges)
    }

    func fetchChanges() async throws {
        try await engine.fetchChanges()
    }
}

// CKSyncEngine has no way to take an error back from its delegate, so failures here are
// logged; the engine itself retries network and server errors.
private final class CloudSyncEngineDelegate: CKSyncEngineDelegate {
    private let coordinator: SyncCoordinator
    private let stateStore: SyncStateStore

    init(coordinator: SyncCoordinator, stateStore: SyncStateStore) {
        self.coordinator = coordinator
        self.stateStore  = stateStore
    }

    func handleEvent(_ event: CKSyncEngine.Event, syncEngine: CKSyncEngine) async {
        switch event {
        case .stateUpdate(let update):
            do {
                try stateStore.save(update.stateSerialization)
            } catch {
                SyncLog.logger.error("Couldn't save the sync state: \(error)")
            }
        case .fetchedRecordZoneChanges(let changes):
            await handle(.fetched(
                saved:   changes.modifications.map(\.record),
                deleted: changes.deletions.map {
                    DeletedRecord(recordID: $0.recordID, recordType: $0.recordType)
                }
            ))
        case .sentRecordZoneChanges(let sent):
            await handle(.sent(
                saved:  sent.savedRecords,
                failed: sent.failedRecordSaves.map {
                    FailedRecordSave(record: $0.record, errorCode: $0.error.code)
                }
            ))
        case .accountChange(let change):
            SyncLog.logger.notice("iCloud account changed: \(change)")
        case .fetchedDatabaseChanges(let changes):
            for deletion in changes.deletions {
                SyncLog.logger.notice("Zone \(deletion.zoneID.zoneName) was deleted")
            }
        default:
            break
        }
    }

    func nextRecordZoneChangeBatch(
        _ context:  CKSyncEngine.SendChangesContext,
        syncEngine: CKSyncEngine
    ) async -> CKSyncEngine.RecordZoneChangeBatch? {
        let scope: CKSyncEngine.SendChangesOptions.Scope            = context.options.scope
        let pending: [CKSyncEngine.PendingRecordZoneChange] = syncEngine.state
            .pendingRecordZoneChanges.filter { scope.contains($0) }

        return await CKSyncEngine.RecordZoneChangeBatch(pendingChanges: pending) {
            [coordinator] recordID in
            await coordinator.recordToSend(recordID)
        }
    }

    @MainActor
    private func handle(_ event: SyncEvent) {
        do {
            try coordinator.handle(event)
        } catch {
            SyncLog.logger.error("Couldn't apply a sync event: \(error)")
        }
    }
}
