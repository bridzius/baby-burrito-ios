import BabyCore
import SwiftData
import SwiftUI

// Sections per local day, newest first. Fetches a page at a time so two years of feedings
// never load at once; the last row asks for the next page when it appears.
struct FeedingHistory: View {
    static let pageSize: Int = 200

    let fetchLimit: Int
    let loadNextPage: () -> Void
    let edit: (LocalFeeding) -> Void
    let delete: (LocalFeeding) -> Void

    @Query private var feedings: [LocalFeeding]

    init(
        fetchLimit:   Int,
        loadNextPage: @escaping () -> Void,
        edit:         @escaping (LocalFeeding) -> Void,
        delete:       @escaping (LocalFeeding) -> Void
    ) {
        self.fetchLimit   = fetchLimit
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

        ForEach(FeedingDay.grouping(feedings, calendar: calendar)) { day in
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
        }

        if feedings.count == fetchLimit {
            ProgressView()
                .frame(maxWidth: .infinity)
                .onAppear(perform: loadNextPage)
        }
    }
}
