import BabyCore
import SwiftData
import SwiftUI

struct TodayView: View {
    static let undoWindow: Duration    = .seconds(5)
    static let noticeDuration: Duration = .seconds(5)
    // Viewers come with sharing roles (#33); until then this phone always owns its baby log.
    static let canLog: Bool             = true

    let baby: LocalBaby
    let feedingStore: FeedingStore

    @Query(Self.lastFeedingDescriptor) private var lastFeedings: [LocalFeeding]
    @State private var isEditingFeedingInterval: Bool = false
    @State private var historyFetchLimit: Int        = FeedingHistory.pageSize
    @State private var pendingDeletion: DeletedFeeding?
    @State private var isShowingSaveFailure: Bool     = false
    @State private var logSheetMode: LogSheetMode?
    @State private var savedFeedingCount: Int         = 0
    @State private var undoneRepeatCount: Int         = 0
    @State private var scrollTargetDay: Date?
    @State private var deepLinkNotice: DeepLinkRoute.Notice?
    @Environment(\.accessibilityReduceMotion) private var reduceMotion: Bool

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
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        NavigationLink {
                            SettingsView(localBaby: baby, feedingStore: feedingStore)
                        } label: {
                            Label("Settings", systemImage: "gearshape")
                        }
                    }
                }
                .sheet(isPresented: $isEditingFeedingInterval) {
                    FeedingIntervalEditor(
                        saveFeedingInterval:    saveFeedingInterval,
                        feedingIntervalMinutes: baby.feedingIntervalMinutes
                    )
                }
                .safeAreaInset(edge: .bottom) {
                    VStack(spacing: 0) {
                        if let deepLinkNotice {
                            DeepLinkNoticeBar(notice: deepLinkNotice)
                        }
                        if pendingDeletion != nil {
                            UndoDeleteBar(undo: undoDeletion)
                        }
                        QuickLogBar(
                            nextRepeat:   nextRepeat?.details,
                            repeatLast:   repeatLastFeeding,
                            openLogSheet: openLogSheet
                        )
                    }
                }
                .onOpenURL(perform: openDeepLink)
                .task(id: deepLinkNotice) {
                    await clearDeepLinkNoticeAfterAWhile()
                }
                .task(id: pendingDeletion?.feeding.id) {
                    await confirmDeletionAfterUndoWindow()
                }
                .sensoryFeedback(trigger: pendingDeletion?.feeding.id) { _, deletedID in
                    deletedID == nil ? nil : .impact(weight: .light)
                }
                .alert("Couldn't save. Try again.", isPresented: $isShowingSaveFailure) {}
                .sheet(item: $logSheetMode, content: logSheet)
                .sensoryFeedback(.success, trigger: savedFeedingCount)
                .sensoryFeedback(.impact(weight: .light), trigger: undoneRepeatCount)
        }
    }

    @ViewBuilder
    private var content: some View {
        if let lastFeeding = lastFeedings.first?.feeding {
            ScrollViewReader { scrollProxy in
                feedingList(lastFeeding: lastFeeding, scrollProxy: scrollProxy)
            }
        } else {
            ContentUnavailableView {
                Label {
                    Text("No feedings yet")
                } icon: {
                    Image(systemName: "teddybear.fill")
                        .symbolEffect(.breathe)
                }
            } actions: {
                Button("Log the first feeding") {
                    logSheetMode = .log(after: nil)
                }
                .buttonStyle(.glassProminent)
            }
        }
    }

    private func feedingList(lastFeeding: Feeding, scrollProxy: ScrollViewProxy) -> some View {
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
                        TrendsView(now: .now, showDay: showDay)
                    } label: {
                        Label("Trends", systemImage: "chart.bar.xaxis")
                            .labelStyle(.iconOnly)
                    }
                }
            }
            FeedingHistory(
                fetchLimit:      historyFetchLimit,
                scrollProxy:     scrollProxy,
                scrollTargetDay: $scrollTargetDay,
                loadNextPage:    { historyFetchLimit += FeedingHistory.pageSize },
                edit:            { logSheetMode = .edit($0) },
                delete:          delete
            )
        }
        .listStyle(.plain)
    }

    // Loads enough history to hold that day before scrolling to it.
    private func showDay(_ dayStart: Date, feedingsSinceDayStart: Int) {
        historyFetchLimit = max(historyFetchLimit, feedingsSinceDayStart + FeedingHistory.pageSize)
        scrollTargetDay   = dayStart
    }

    @ViewBuilder
    private func logSheet(_ mode: LogSheetMode) -> some View {
        switch mode {
        case .log(let lastFeeding):
            LogSheet(
                title:     "Log feeding",
                birthDate: baby.birthDate,
                save:      { fedAt, details in
                    _ = try feedingStore.log(fedAt: fedAt, details: details)
                    savedFeedingCount += 1
                },
                draft:     .logging(after: lastFeeding, now: .now)
            )
        case .edit(let localFeeding):
            LogSheet(
                title:     "Edit feeding",
                birthDate: baby.birthDate,
                save:      { fedAt, details in
                    try feedingStore.update(localFeeding, fedAt: fedAt, details: details)
                    savedFeedingCount += 1
                },
                draft:     .editing(localFeeding.feeding)
            )
        case .logged(let localFeeding):
            LoggedConfirmation(
                birthDate: baby.birthDate,
                update:    { fedAt, details in
                    try feedingStore.update(localFeeding, fedAt: fedAt, details: details)
                },
                undo:      { undoRepeat(localFeeding) },
                draft:     .editing(localFeeding.feeding)
            )
        }
    }

    // First run has no Today, so a link opened then is simply not handled.
    private func openDeepLink(_ url: URL) {
        guard let link = DeepLink(url: url) else { return }
        let route: DeepLinkRoute = DeepLinkRoute(
            link:            link,
            babyLogZoneName: baby.zoneName,
            canLog:          Self.canLog,
            hasLastFeeding:  !lastFeedings.isEmpty
        )

        switch route {
        case .firstRun:
            return
        case .today(let notice):
            deepLinkNotice = notice
        case .openLogSheet:
            openLogSheet()
        case .logRepeat:
            repeatLastFeeding()
        }
    }

    private func clearDeepLinkNoticeAfterAWhile() async {
        guard deepLinkNotice != nil else { return }
        do {
            try await Task.sleep(for: Self.noticeDuration)
        } catch {
            return
        }
        deepLinkNotice = nil
    }

    private func openLogSheet() {
        logSheetMode = .log(after: lastFeedings.first?.feeding)
    }

    private var nextRepeat: Feeding? {
        Feeding.repeating(lastFeedings.first?.feeding, id: UUID(), now: .now)
    }

    private func repeatLastFeeding() {
        guard let nextRepeat else { return }
        do {
            let logged: LocalFeeding = try feedingStore.log(
                fedAt:   nextRepeat.fedAt,
                details: nextRepeat.details
            )
            savedFeedingCount += 1
            logSheetMode       = .logged(logged)
        } catch {
            isShowingSaveFailure = true
        }
    }

    // The sheet closes before the delete, so it never reads a deleted feeding. Nothing undoes
    // this Undo, so the CloudKit delete is confirmed at once.
    private func undoRepeat(_ localFeeding: LocalFeeding) {
        logSheetMode = nil
        do {
            let deleted: DeletedFeeding = try withAnimation(.spring(reducingMotion: reduceMotion)) {
                try feedingStore.delete(localFeeding)
            }
            feedingStore.confirmDeletion(deleted)
            undoneRepeatCount += 1
        } catch {
            isShowingSaveFailure = true
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
