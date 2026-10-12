import BabyCore
import SwiftData
import SwiftUI

struct RootView: View {
    let feedingStore: FeedingStore

    @Query private var babies: [LocalBaby]

    var body: some View {
        if let baby = babies.first {
            TodayView(baby: baby) { updatedBaby in
                try feedingStore.updateBaby(baby, to: updatedBaby)
            }
        } else {
            FirstRunView { baby in
                _ = try feedingStore.createBaby(baby)
            }
        }
    }
}
