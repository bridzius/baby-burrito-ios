import BabyCore
import Charts
import SwiftUI

struct BottlesChart: View {
    static let averageDash: [CGFloat]          = [4, 4]
    static let accessibilityIdentifier: String = "bottlesChart"

    let figures: TrendsFigures
    let selectDay: (Date) -> Void

    private var breastMilk: String { String(localized: FeedingKind.breastMilk.name) }
    private var formula: String    { String(localized: FeedingKind.formula.name) }
    private var average: String    { Int(figures.averageDailyMl.rounded()).formattedMillilitres }

    var body: some View {
        Chart {
            ForEach(figures.days, id: \.start) { day in
                BarMark(
                    x: .value("Day", day.start, unit: .day),
                    y: .value("Millilitres", day.totals.breastMilkMl)
                )
                .foregroundStyle(by: .value("Kind", breastMilk))

                BarMark(
                    x: .value("Day", day.start, unit: .day),
                    y: .value("Millilitres", day.totals.formulaMl)
                )
                .foregroundStyle(by: .value("Kind", formula))
            }

            RuleMark(y: .value("Daily average", figures.averageDailyMl))
                .foregroundStyle(.secondary)
                .lineStyle(StrokeStyle(lineWidth: 1, dash: Self.averageDash))
                .annotation(position: .top, alignment: .leading) {
                    Text("Average \(average)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
        }
        .chartForegroundStyleScale([
            breastMilk: FeedingKind.breastMilk.color,
            formula:    FeedingKind.formula.color,
        ])
        .trendsDayAxis(days: figures.days)
        .selectsDay(selectDay)
        .accessibilityChartDescriptor(descriptor)
        .accessibilityIdentifier(Self.accessibilityIdentifier)
    }

    private var descriptor: DailyChartDescriptor {
        DailyChartDescriptor(
            title:          String(localized: "Bottles"),
            valueAxisTitle: String(localized: "Millilitres"),
            valueFormat:    { Int($0).formattedMillilitres },
            series:         [
                .init(name: breastMilk, values: figures.days.map {
                    ($0.start, Double($0.totals.breastMilkMl))
                }),
                .init(name: formula, values: figures.days.map {
                    ($0.start, Double($0.totals.formulaMl))
                }),
            ]
        )
    }
}
