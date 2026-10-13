import BabyCore
import SwiftUI

struct Last24HoursTotals: View {
    let totals: FeedingTotals

    private var text: String {
        let nursing: String = Duration.minutes(totals.nursingMinutes).formatted(.hoursAndMinutes)

        return [
            totals.totalMl.formattedMillilitres,
            String(localized: "\(totals.bottleCount) bottles"),
            String(localized: "\(nursing) nursing"),
        ].joined(separator: FeedingDetails.summarySeparator)
    }

    var body: some View {
        Text(text)
            .numerals(.headline)
            .contentTransition(.numericText())
    }
}
