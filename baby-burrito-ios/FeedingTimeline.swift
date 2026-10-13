import BabyCore
import Charts
import SwiftUI

struct FeedingTimeline: View {
    static let height: CGFloat      = 56
    static let barHeight: CGFloat   = 14
    static let axisStrideHours: Int = 6
    static let row: String          = "feedings"

    let feedings: [Feeding]
    let windowStart: Date
    let now: Date

    var body: some View {
        Chart(feedings) { feeding in
            mark(for: feeding)
                .foregroundStyle(feeding.details.kind.color)
        }
        .chartXScale(domain: windowStart...now)
        .chartYAxis(.hidden)
        .chartXAxis {
            AxisMarks(values: .stride(by: .hour, count: Self.axisStrideHours)) {
                AxisGridLine()
                AxisValueLabel(format: .dateTime.hour())
            }
        }
        .frame(height: Self.height)
        .accessibilityHidden(true)
    }

    @ChartContentBuilder
    private func mark(for feeding: Feeding) -> some ChartContent {
        if let durationMinutes = feeding.details.durationMinutes {
            let endedAt: Date = feeding.fedAt.addingTimeInterval(Double(durationMinutes * 60))
            RectangleMark(
                xStart: .value("Started", feeding.fedAt),
                xEnd:   .value("Ended", endedAt),
                y:      .value("Row", Self.row),
                height: .fixed(Self.barHeight)
            )
        } else {
            PointMark(
                x: .value("Fed at", feeding.fedAt),
                y: .value("Row", Self.row)
            )
        }
    }
}
