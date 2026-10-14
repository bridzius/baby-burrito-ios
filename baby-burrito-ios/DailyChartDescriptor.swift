import Accessibility
import SwiftUI

// One audio graph per Trends chart: days along x, one data series per plotted value.
struct DailyChartDescriptor: AXChartDescriptorRepresentable {
    struct Series {
        let name: String
        let values: [(day: Date, value: Double)]
    }

    let title: String
    let valueAxisTitle: String
    let valueFormat: (Double) -> String
    let series: [Series]

    func makeChartDescriptor() -> AXChartDescriptor {
        let days: [Date]         = series.first?.values.map(\.day) ?? []
        let allValues: [Double]  = series.flatMap { $0.values.map(\.value) }
        let highestValue: Double = allValues.max() ?? 0

        let dayAxis: AXCategoricalDataAxisDescriptor = AXCategoricalDataAxisDescriptor(
            title:         String(localized: "Day"),
            categoryOrder: days.map(Self.dayLabel)
        )
        let valueAxis: AXNumericDataAxisDescriptor = AXNumericDataAxisDescriptor(
            title:                    valueAxisTitle,
            range:                    0...max(highestValue, 1),
            gridlinePositions:        [],
            valueDescriptionProvider: valueFormat
        )
        let dataSeries: [AXDataSeriesDescriptor] = series.map { series in
            AXDataSeriesDescriptor(
                name:         series.name,
                isContinuous: false,
                dataPoints:   series.values.map { point in
                    AXDataPoint(x: Self.dayLabel(point.day), y: point.value)
                }
            )
        }

        return AXChartDescriptor(
            title:          title,
            summary:        nil,
            xAxis:          dayAxis,
            yAxis:          valueAxis,
            additionalAxes: [],
            series:         dataSeries
        )
    }

    private static func dayLabel(_ day: Date) -> String {
        day.formatted(.dateTime.weekday(.abbreviated).day().month(.abbreviated))
    }
}
