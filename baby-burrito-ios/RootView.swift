import BabyCore
import SwiftData
import SwiftUI

struct RootView: View {
    let feedingStore: FeedingStore

    @Query private var babies: [LocalBaby]

    var body: some View {
        if let baby = babies.first {
            TodayView(baby: baby, feedingStore: feedingStore)
        } else {
            FirstRunView { baby in
                _ = try feedingStore.createBaby(baby)
            }
        }
    }
}
