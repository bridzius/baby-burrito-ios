import BabyCore
import Charts
import SwiftUI

struct WeightChart: View {
    static let chartHeight: CGFloat   = 200
    static let identifier: String     = "weightChart"

    let weighings: [Weighing]

    var body: some View {
        Chart(weighings, id: \.weighedOn) { weighing in
            LineMark(
                x: .value("Day", weighing.weighedOn, unit: .day),
                y: .value("Grams", weighing.grams)
            )
            PointMark(
                x: .value("Day", weighing.weighedOn, unit: .day),
                y: .value("Grams", weighing.grams)
            )
        }
        .foregroundStyle(Color.accentColor)
        .chartYScale(domain: .automatic(includesZero: false))
        .chartYAxisLabel("Grams")
        .frame(height: Self.chartHeight)
        .accessibilityIdentifier(Self.identifier)
        .accessibilityChartDescriptor(descriptor)
    }

    private var descriptor: DailyChartDescriptor {
        DailyChartDescriptor(
            title:          String(localized: "Weight"),
            valueAxisTitle: String(localized: "Weight"),
            valueFormat:    { WeightText.grams(Int($0)) },
            series:         [
                .init(name: String(localized: "Weight"), values: weighings.map {
                    ($0.weighedOn, Double($0.grams))
                }),
            ]
        )
    }
}
