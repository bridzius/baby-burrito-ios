import BabyCore
import SwiftData
import SwiftUI

@main
struct BabyBurritoApp: App {
    let modelContainer: ModelContainer
    let feedingStore: FeedingStore
    let activityController: FeedingActivityController
    let privateSync: PrivateSync?

    @UIApplicationDelegateAdaptor(RemoteNotificationsAppDelegate.self)
    private var remoteNotificationsAppDelegate: RemoteNotificationsAppDelegate

    init() {
        let calendar: Calendar = .autoupdatingCurrent
        modelContainer         = Self.openModelContainer()

        let syncCoordinator: SyncCoordinator = SyncCoordinator(
            modelContext: modelContainer.mainContext,
            calendar:     calendar
        )
        privateSync  = Self.isSeededForUITests ? nil : PrivateSync(
            coordinator: syncCoordinator,
            stateStore:  .privateDatabase()
        )
        let syncQueue: any SyncQueue = Self.isSeededForUITests ? NoSyncQueue() : syncCoordinator
        feedingStore = FeedingStore(
            modelContext: modelContainer.mainContext,
            syncQueue:    syncQueue,
            calendar:     calendar,
            now:          Date.init
        )
        activityController = FeedingActivityController(activities: SystemFeedingActivities())

        #if DEBUG
        if let seededFeedingCount = UITestSeed.requestedFeedingCount {
            UITestSeed.seed(
                seededFeedingCount,
                weighingCount: UITestSeed.requestedWeighingCount,
                into:          feedingStore
            )
        }
        #endif
    }

    private static var isSeededForUITests: Bool {
        #if DEBUG
        UITestSeed.requestedFeedingCount != nil
        #else
        false
        #endif
    }

    private static func openModelContainer() -> ModelContainer {
        do {
            if isSeededForUITests {
                return try LocalStore.inMemoryContainer()
            }
            return try LocalStore.container(at: LocalStore.appGroupStoreURL(), readOnly: false)
        } catch {
            preconditionFailure("The local store didn't open: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView(feedingStore: feedingStore, activityController: activityController)
                .symbolEffectsFollowReduceMotion()
                .privateSync(privateSync)
        }
        .modelContainer(modelContainer)
    }
}
