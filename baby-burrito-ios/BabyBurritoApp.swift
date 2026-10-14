import BabyCore
import SwiftData
import SwiftUI

@main
struct BabyBurritoApp: App {
    let modelContainer: ModelContainer
    let feedingStore: FeedingStore

    init() {
        modelContainer = Self.openModelContainer()
        feedingStore   = FeedingStore(
            modelContext: modelContainer.mainContext,
            syncQueue:    NoSyncQueue(),
            calendar:     .autoupdatingCurrent,
            now:          Date.init
        )

        #if DEBUG
        if let seededFeedingCount = UITestSeed.requestedFeedingCount {
            UITestSeed.seed(seededFeedingCount, into: feedingStore)
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
            RootView(feedingStore: feedingStore)
                .symbolEffectsFollowReduceMotion()
        }
        .modelContainer(modelContainer)
    }
}
