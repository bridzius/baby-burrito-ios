import BabyCore
import SwiftUI

struct LastFeedingCard: View {
    let feeding: Feeding

    private var fedAtTime: Text {
        Text(feeding.fedAt, format: .dateTime.hour().minute())
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: feeding.details.kind.symbolName)
                .font(.title2)
                .foregroundStyle(feeding.details.kind.color)

            VStack(alignment: .leading, spacing: 4) {
                Text(feeding.details.summary)
                    .font(.headline)
                    .monospacedDigit()

                HStack(spacing: 0) {
                    Text("\(fedAtTime) · ")
                    ElapsedText(since: feeding.fedAt)
                }
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }
        }
        .accessibilityElement(children: .combine)
    }
}
