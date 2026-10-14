import BabyCore
import SwiftData
import SwiftUI

struct TodayView: View {
    static let undoWindow: Duration = .seconds(5)

    let baby: LocalBaby
    let feedingStore: FeedingStore

    @Query(Self.lastFeedingDescriptor) private var lastFeedings: [LocalFeeding]
    @State private var isEditingFeedingInterval: Bool = false
    @State private var historyFetchLimit: Int        = FeedingHistory.pageSize
    @State private var pendingDeletion: DeletedFeeding?
    @State private var isShowingSaveFailure: Bool     = false

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
                .safeAreaInset(edge: .bottom) {
                    if pendingDeletion != nil {
                        UndoDeleteBar(undo: undoDeletion)
                    }
                }
                .task(id: pendingDeletion?.feeding.id) {
                    await confirmDeletionAfterUndoWindow()
                }
                .sensoryFeedback(trigger: pendingDeletion?.feeding.id) { _, deletedID in
                    deletedID == nil ? nil : .impact(weight: .light)
                }
                .alert("Couldn't save. Try again.", isPresented: $isShowingSaveFailure) {}
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
                Section {
                    TimelineView(.everyMinute) { context in
                        Last24HoursSummary(now: context.date)
                    }
                } header: {
                    HStack {
                        Text("Last 24 h")
                        Spacer()
                        NavigationLink {
                            TrendsView()
                        } label: {
                            Label("Trends", systemImage: "chart.bar.xaxis")
                                .labelStyle(.iconOnly)
                        }
                    }
                }
                FeedingHistory(
                    fetchLimit:   historyFetchLimit,
                    loadNextPage: { historyFetchLimit += FeedingHistory.pageSize },
                    delete:       delete
                )
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
        try feedingStore.updateBaby(baby, to: updatedBaby)
    }

    // A delete made inside another's Undo window confirms the earlier one, so it still syncs.
    private func delete(_ localFeeding: LocalFeeding) {
        if let pendingDeletion {
            feedingStore.confirmDeletion(pendingDeletion)
        }
        do {
            pendingDeletion = try feedingStore.delete(localFeeding)
        } catch {
            pendingDeletion      = nil
            isShowingSaveFailure = true
        }
    }

    private func undoDeletion() {
        guard let deleted = pendingDeletion else { return }
        do {
            _ = try feedingStore.restore(deleted)
            pendingDeletion = nil
        } catch {
            isShowingSaveFailure = true
        }
    }

    private func confirmDeletionAfterUndoWindow() async {
        guard let deleted = pendingDeletion else { return }
        do {
            try await Task.sleep(for: Self.undoWindow)
        } catch {
            return
        }
        feedingStore.confirmDeletion(deleted)
        pendingDeletion = nil
    }
}
