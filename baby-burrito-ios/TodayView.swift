import BabyCore
import SwiftData
import SwiftUI

struct TodayView: View {
    let baby: LocalBaby
    let updateBaby: (Baby) throws -> Void

    @Query(Self.lastFeedingDescriptor) private var lastFeedings: [LocalFeeding]
    @State private var isEditingFeedingInterval: Bool = false

    static var lastFeedingDescriptor: FetchDescriptor<LocalFeeding> {
        var descriptor: FetchDescriptor<LocalFeeding> = FetchDescriptor(
            sortBy: [SortDescriptor(\.fedAt, order: .reverse)]
        )
        descriptor.fetchLimit = 1
        return descriptor
    }

    var body: some View {
        NavigationStack {
            content
                .navigationTitle(baby.name)
                .sheet(isPresented: $isEditingFeedingInterval) {
                    FeedingIntervalEditor(
                        saveFeedingInterval:    saveFeedingInterval,
                        feedingIntervalMinutes: baby.feedingIntervalMinutes
                    )
                }
        }
    }

    @ViewBuilder
    private var content: some View {
        if let lastFeeding = lastFeedings.first?.feeding {
            List {
                Section("Next feeding") {
                    NextFeedingView(
                        lastFeeding:            lastFeeding,
                        feedingIntervalMinutes: baby.feedingIntervalMinutes,
                        editFeedingInterval:    { isEditingFeedingInterval = true }
                    )
                }
                Section("Last") {
                    LastFeedingCard(feeding: lastFeeding)
                }
            }
            .listStyle(.plain)
        } else {
            ContentUnavailableView {
                Label {
                    Text("No feedings yet")
                } icon: {
                    Image(systemName: "teddybear.fill")
                        .symbolEffect(.breathe)
                }
            }
        }
    }

    private func saveFeedingInterval(_ minutes: Int) throws {
        var updatedBaby: Baby              = baby.baby
        updatedBaby.feedingIntervalMinutes = minutes
        try updateBaby(updatedBaby)
    }
}
