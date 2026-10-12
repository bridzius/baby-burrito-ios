import BabyCore
import SwiftData
import SwiftUI

@main
struct BabyBurritoApp: App {
    let modelContainer: ModelContainer
    let feedingStore: FeedingStore

    init() {
        do {
            modelContainer = try LocalStore.container(
                at:       LocalStore.appGroupStoreURL(),
                readOnly: false
            )
        } catch {
            preconditionFailure("The local store didn't open: \(error)")
        }

        feedingStore = FeedingStore(
            modelContext: modelContainer.mainContext,
            syncQueue:    NoSyncQueue(),
            calendar:     .autoupdatingCurrent,
            now:          Date.init
        )
    }

    var body: some Scene {
        WindowGroup {
            RootView(feedingStore: feedingStore)
                .symbolEffectsFollowReduceMotion()
        }
        .modelContainer(modelContainer)
    }
}
