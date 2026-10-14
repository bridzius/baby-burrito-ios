import BabyCore
import Charts
import SwiftUI

extension View {
    // Every day in the range keeps its slot, so a day with no feedings shows as a zero bar.
    func trendsDayAxis(days: [DayFigures]) -> some View {
        let chartHeight: CGFloat = 200
        let firstDay: Date       = days.first?.start ?? .now
        let lastDay: Date        = days.last?.start ?? .now
        let endOfLastDay: Date   = Calendar.autoupdatingCurrent.date(
            byAdding: .day, value: 1, to: lastDay
        ) ?? lastDay

        return chartXScale(domain: firstDay...endOfLastDay)
            .frame(height: chartHeight)
    }
}
