import BabyCore
import SwiftUI

struct FeedingRow: View {
    static let accessibilityIdentifier: String = "feedingRow"

    let feeding: Feeding

    private var detail: String {
        let details: FeedingDetails = feeding.details
        if let amountMl = details.amountMl {
            return amountMl.formattedMillilitres
        }

        var parts: [String] = []
        if let side = details.side {
            parts.append(String(localized: side.shortName))
        }
        if let durationMinutes = details.durationMinutes {
            parts.append(Duration.minutes(durationMinutes).formatted(.hoursAndMinutes))
        }
        return parts.joined(separator: FeedingDetails.summarySeparator)
    }

    var body: some View {
        HStack(spacing: 12) {
            Text(feeding.fedAt, format: .dateTime.hour().minute())
                .monospacedDigit()
                .foregroundStyle(.secondary)

            Image(systemName: feeding.details.kind.symbolName)
                .foregroundStyle(feeding.details.kind.color)

            Text(feeding.details.kind.name)

            Spacer()

            Text(detail)
                .monospacedDigit()
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier(Self.accessibilityIdentifier)
    }
}
