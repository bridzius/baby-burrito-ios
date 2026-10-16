import CloudKit

// The imperative shell around the owner's private database. Nothing here runs until the app
// calls start(), after Today's first frame.
@MainActor
public final class PrivateSync {
    public static let containerIdentifier: String              = "iCloud.com.bridzius.babyburrito"
    public static let accountChangedNotification: Notification.Name = .CKAccountChanged

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
            database:       CKContainer(identifier: Self.containerIdentifier).privateCloudDatabase,
            savedState:     savedState,
            stateStore:     stateStore,
            coordinator:    coordinator,
            accountChanged: { [weak self] change in self?.handleAccountChange(change) }
        )
        engine = startedEngine
        try coordinator.start(with: startedEngine, uploadingEverything: savedState == nil)
    }

    public func fetchChanges() async throws {
        guard let engine else { preconditionFailure("Fetching before the private sync started") }
        try await engine.fetchChanges()
    }

    public func accountStatus() async -> ICloudAccount {
        do {
            return ICloudAccount(
                try await CKContainer(identifier: Self.containerIdentifier).accountStatus()
            )
        } catch {
            SyncLog.logger.error("Couldn't read the iCloud account status: \(error)")
            return .unavailable
        }
    }

    // After a sign-out or a switch the old engine state belongs to someone else, so a fresh
    // engine starts from nothing; a sign-in keeps the engine and uploads what's here.
    private func handleAccountChange(_ change: AccountChange) {
        do {
            try coordinator.handle(.accountChanged(change))
            guard change != .signedIn else { return }
            try stateStore.delete()
            engine = nil
            try start()
        } catch {
            SyncLog.logger.error("Couldn't handle the account change: \(error)")
        }
    }
}
