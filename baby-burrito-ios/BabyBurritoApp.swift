import BabyCore
import SwiftData
import SwiftUI

@main
struct BabyBurritoApp: App {
    let modelContainer: ModelContainer
    let feedingStore: FeedingStore
    let activityController: FeedingActivityController

    init() {
        modelContainer = Self.openModelContainer()
        feedingStore   = FeedingStore(
            modelContext: modelContainer.mainContext,
            syncQueue:    NoSyncQueue(),
            calendar:     .autoupdatingCurrent,
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

    private static func openModelContainer() -> ModelContainer {
        do {
            #if DEBUG
            if UITestSeed.requestedFeedingCount != nil {
                return try LocalStore.inMemoryContainer()
            }
            #endif
            return try LocalStore.container(at: LocalStore.appGroupStoreURL(), readOnly: false)
        } catch {
            preconditionFailure("The local store didn't open: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView(feedingStore: feedingStore, activityController: activityController)
                .symbolEffectsFollowReduceMotion()
        }
        .modelContainer(modelContainer)
    }
}
