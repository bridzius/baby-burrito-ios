import BabyCore
import Charts
import SwiftUI

struct NursingChart: View {
    static let sideOpacities: [Side: Double] = [.left: 1, .right: 0.6, .both: 0.3]

    let figures: TrendsFigures
    let selectDay: (Date) -> Void

    private static func minutes(on day: DayFigures, side: Side) -> Int {
        switch side {
        case .left:  day.totals.leftMinutes
        case .right: day.totals.rightMinutes
        case .both:  day.totals.bothMinutes
        }
    }

    private static func sideName(_ side: Side) -> String {
        String(localized: side.title)
    }

    var body: some View {
        Chart {
            ForEach(figures.days, id: \.start) { day in
                ForEach(Side.allCases, id: \.self) { side in
                    BarMark(
                        x: .value("Day", day.start, unit: .day),
                        y: .value("Minutes", Self.minutes(on: day, side: side))
                    )
                    .foregroundStyle(by: .value("Side", Self.sideName(side)))
                }
            }
        }
        .chartForegroundStyleScale(
            domain: Side.allCases.map(Self.sideName),
            range:  Side.allCases.map { side in
                FeedingKind.nursing.color.opacity(Self.sideOpacities[side] ?? 1)
            }
        )
        .trendsDayAxis(days: figures.days)
        .selectsDay(selectDay)
        .accessibilityChartDescriptor(descriptor)
    }

    private var descriptor: DailyChartDescriptor {
        DailyChartDescriptor(
            title:          String(localized: "Nursing"),
            valueAxisTitle: String(localized: "Minutes"),
            valueFormat:    { Duration.minutes(Int($0)).formatted(.hoursAndMinutes) },
            series:         Side.allCases.map { side in
                .init(name: Self.sideName(side), values: figures.days.map {
                    ($0.start, Double(Self.minutes(on: $0, side: side)))
                })
            }
        )
    }
}
