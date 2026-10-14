import BabyCore
import Charts
import SwiftUI

struct RhythmChart: View {
    static let minutesPerHour: Double = 60

    let figures: TrendsFigures
    let selectDay: (Date) -> Void

    private var averageName: String { String(localized: "Average interval") }
    private var longestName: String { String(localized: "Longest interval") }

    var body: some View {
        Chart {
            ForEach(figures.days, id: \.start) { day in
                if let averageMinutes = day.averageIntervalMinutes {
                    LineMark(
                        x: .value("Day", day.start, unit: .day),
                        y: .value("Hours", averageMinutes / Self.minutesPerHour)
                    )
                    .foregroundStyle(by: .value("Interval", averageName))
                    .symbol(by: .value("Interval", averageName))
                }
                if let longestMinutes = day.longestIntervalMinutes {
                    LineMark(
                        x: .value("Day", day.start, unit: .day),
                        y: .value("Hours", Double(longestMinutes) / Self.minutesPerHour)
                    )
                    .foregroundStyle(by: .value("Interval", longestName))
                    .symbol(by: .value("Interval", longestName))
                }
            }
        }
        .chartForegroundStyleScale([
            averageName: Color.accentColor,
            longestName: Color.secondary,
        ])
        .chartYAxisLabel("Hours")
        .trendsDayAxis(days: figures.days)
        .selectsDay(selectDay)
        .accessibilityChartDescriptor(descriptor)
    }

    // Days without an interval read as zero rather than leaving holes in the audio graph.
    private var descriptor: DailyChartDescriptor {
        DailyChartDescriptor(
            title:          String(localized: "Rhythm"),
            valueAxisTitle: String(localized: "Interval"),
            valueFormat:    { Duration.minutes(Int($0)).formatted(.hoursAndMinutes) },
            series:         [
                .init(name: averageName, values: figures.days.map {
                    ($0.start, $0.averageIntervalMinutes ?? 0)
                }),
                .init(name: longestName, values: figures.days.map {
                    ($0.start, Double($0.longestIntervalMinutes ?? 0))
                }),
            ]
        )
    }
}
