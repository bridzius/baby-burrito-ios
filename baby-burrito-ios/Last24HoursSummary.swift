import BabyCore
import SwiftData
import SwiftUI

struct Last24HoursSummary: View {
    nonisolated static let window: TimeInterval = 24 * 60 * 60

    let now: Date

    @Query private var feedingsInWindow: [LocalFeeding]
    @State private var totals: FeedingTotals = FeedingTotals()
    @Environment(\.accessibilityReduceMotion) private var reduceMotion: Bool

    init(now: Date) {
        self.now = now
        let windowStart: Date = now.addingTimeInterval(-Self.window)
        _feedingsInWindow = Query(
            filter: #Predicate<LocalFeeding> { $0.fedAt >= windowStart },
            sort:   \.fedAt
        )
    }

    var body: some View {
        let feedings: [Feeding] = feedingsInWindow.map(\.feeding)

        VStack(alignment: .leading, spacing: 12) {
            Last24HoursTotals(totals: totals)
            FeedingTimeline(
                feedings:    feedings,
                windowStart: now.addingTimeInterval(-Self.window),
                now:         now
            )
        }
        .task(id: SummaryInput(feedings: feedings, now: now)) {
            let newTotals: FeedingTotals = await Self.summary(of: feedings, now: now)
            withAnimation(.spring(reducingMotion: reduceMotion)) {
                totals = newTotals
            }
        }
    }

    @concurrent
    private static func summary(of feedings: [Feeding], now: Date) async -> FeedingTotals {
        Statistics.summary(of: feedings, window: window, now: now)
    }
}

private struct SummaryInput: Equatable {
    let feedings: [Feeding]
    let now: Date
}
