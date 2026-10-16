import CloudKit

// The imperative shell around the owner's private database. Nothing here runs until the app
// calls start(), after Today's first frame.
@MainActor
public final class PrivateSync {
    public static let containerIdentifier: String = "iCloud.com.bridzius.babyburrito"

    private let coordinator: SyncCoordinator
    private let stateStore: SyncStateStore
    private var engine: CloudSyncEngine?

    public init(coordinator: SyncCoordinator, stateStore: SyncStateStore) {
        self.coordinator = coordinator
        self.stateStore  = stateStore
    }

    public func start() throws {
        guard engine == nil else { return }
        let savedState: CKSyncEngine.State.Serialization? = try stateStore.load()
        let startedEngine: CloudSyncEngine                 = CloudSyncEngine(
            database:    CKContainer(identifier: Self.containerIdentifier).privateCloudDatabase,
            savedState:  savedState,
            stateStore:  stateStore,
            coordinator: coordinator
        )
        engine = startedEngine
        try coordinator.start(with: startedEngine, uploadingEverything: savedState == nil)
    }

    public func fetchChanges() async throws {
        guard let engine else { preconditionFailure("Fetching before the private sync started") }
        try await engine.fetchChanges()
    }
}
