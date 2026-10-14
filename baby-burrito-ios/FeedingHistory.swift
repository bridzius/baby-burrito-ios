import BabyCore
import SwiftData
import SwiftUI

// Sections per local day, newest first. Fetches a page at a time so two years of feedings
// never load at once; the last row asks for the next page when it appears.
struct FeedingHistory: View {
    static let pageSize: Int = 200

    let fetchLimit: Int
    let scrollProxy: ScrollViewProxy
    @Binding var scrollTargetDay: Date?
    let loadNextPage: () -> Void
    let edit: (LocalFeeding) -> Void
    let delete: (LocalFeeding) -> Void

    @Query private var feedings: [LocalFeeding]

    init(
        fetchLimit:      Int,
        scrollProxy:     ScrollViewProxy,
        scrollTargetDay: Binding<Date?>,
        loadNextPage:    @escaping () -> Void,
        edit:            @escaping (LocalFeeding) -> Void,
        delete:          @escaping (LocalFeeding) -> Void
    ) {
        self.fetchLimit   = fetchLimit
        self.scrollProxy  = scrollProxy
        _scrollTargetDay  = scrollTargetDay
        self.loadNextPage = loadNextPage
        self.edit         = edit
        self.delete       = delete

        var descriptor: FetchDescriptor<LocalFeeding> = FetchDescriptor(
            sortBy: [SortDescriptor(\.fedAt, order: .reverse)]
        )
        descriptor.fetchLimit = fetchLimit
        _feedings             = Query(descriptor)
    }

    var body: some View {
        let calendar: Calendar = .autoupdatingCurrent
        let now: Date          = .now
        let days: [FeedingDay] = FeedingDay.grouping(feedings, calendar: calendar)

        ForEach(days) { day in
            Section(day.title(calendar: calendar, now: now)) {
                ForEach(day.feedings) { localFeeding in
                    FeedingRow(feeding: localFeeding.feeding)
                        .swipeActions(edge: .trailing) {
                            Button("Delete", systemImage: "trash", role: .destructive) {
                                delete(localFeeding)
                            }
                            Button("Edit", systemImage: "pencil") {
                                edit(localFeeding)
                            }
                        }
                }
            }
            .id(day.start)
        }
        .onChange(of: scrollTargetDay, initial: true) {
            scrollToTargetDay(in: days)
        }

        if feedings.count == fetchLimit {
            ProgressView()
                .frame(maxWidth: .infinity)
                .onAppear(perform: loadNextPage)
        }
    }

    // A day with no feedings has no section, so the nearest earlier day stands in.
    private func scrollToTargetDay(in days: [FeedingDay]) {
        guard let scrollTargetDay else { return }
        guard let day = days.first(where: { $0.start <= scrollTargetDay }) ?? days.last else {
            return
        }
        scrollProxy.scrollTo(day.start, anchor: .top)
        self.scrollTargetDay = nil
    }
}
