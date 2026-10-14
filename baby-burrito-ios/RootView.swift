import BabyCore
import SwiftData
import SwiftUI

struct RootView: View {
    let feedingStore: FeedingStore
    let activityController: FeedingActivityController

    @Query private var babies: [LocalBaby]

    var body: some View {
        if let baby = babies.first {
            TodayView(
                baby:               baby,
                feedingStore:       feedingStore,
                activityController: activityController
            )
        } else {
            FirstRunView { baby in
                _ = try feedingStore.createBaby(baby)
            }
            .task {
                await activityController.end()
            }
        }
    }
}
