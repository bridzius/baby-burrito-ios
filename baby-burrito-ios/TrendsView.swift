import BabyCore
import SwiftData
import SwiftUI

struct TrendsView: View {
    // One day before the longest range, so its first day's interval has a previous feeding.
    static let lookbackDays: Int = TrendsRange.month.days + 1

    let showDay: (_ dayStart: Date, _ feedingsSinceDayStart: Int) -> Void

    @Query private var recentFeedings: [LocalFeeding]
    @State private var range: TrendsRange = .week
    @State private var figures: TrendsFigures?
    @Environment(\.dismiss) private var dismiss: DismissAction

    init(now: Date, showDay: @escaping (_ dayStart: Date, _ feedingsSinceDayStart: Int) -> Void) {
        self.showDay = showDay

        let calendar: Calendar  = .autoupdatingCurrent
        let today: Date         = calendar.startOfDay(for: now)
        let lookbackStart: Date = calendar.date(
            byAdding: .day, value: -Self.lookbackDays, to: today
        ) ?? today
        _recentFeedings = Query(filter: #Predicate<LocalFeeding> { $0.fedAt >= lookbackStart })
    }

    var body: some View {
        let feedings: [Feeding] = recentFeedings.map(\.feeding)

        List {
            Picker("Range", selection: $range) {
                ForEach(TrendsRange.allCases) { range in
                    Text(range.title).tag(range)
                }
            }
            .pickerStyle(.segmented)
            .listRowSeparator(.hidden)

            if let figures {
                Section("Bottles") {
                    BottlesChart(figures: figures, selectDay: select)
                }
                Section("Nursing") {
                    NursingChart(figures: figures, selectDay: select)
                }
                Section("Rhythm") {
                    RhythmChart(figures: figures, selectDay: select)
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle("Trends")
        .task(id: TrendsInput(feedings: feedings, days: range.days)) {
            figures = await Self.daily(of: feedings, days: range.days, now: .now)
        }
    }

    private func select(_ dayStart: Date) {
        let feedingsSinceDayStart: Int = recentFeedings.count { $0.fedAt >= dayStart }
        showDay(dayStart, feedingsSinceDayStart)
        dismiss()
    }

    @concurrent
    private static func daily(of feedings: [Feeding], days: Int, now: Date) async -> TrendsFigures {
        Statistics.daily(of: feedings, calendar: .autoupdatingCurrent, days: days, now: now)
    }
}

private struct TrendsInput: Equatable {
    let feedings: [Feeding]
    let days: Int
}
