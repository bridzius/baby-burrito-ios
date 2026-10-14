import BabyCore
import SwiftUI

struct FeedingRow: View {
    static let accessibilityIdentifier: String          = "feedingRow"
    static let spokenDuration: Duration.UnitsFormatStyle = .units(
        allowed: [.hours, .minutes], width: .wide
    )

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

    // "Nursing, left breast, 15 minutes, 14:05": words instead of the row's abbreviations.
    private var spokenLabel: String {
        let details: FeedingDetails = feeding.details
        var parts: [String]         = [String(localized: details.kind.name)]

        if let side = details.side {
            parts.append(String(localized: side.spokenName))
        }
        if let durationMinutes = details.durationMinutes {
            parts.append(Duration.minutes(durationMinutes).formatted(Self.spokenDuration))
        }
        if let amountMl = details.amountMl {
            parts.append(Measurement(value: Double(amountMl), unit: UnitVolume.milliliters)
                .formatted(.measurement(width: .wide, usage: .asProvided)))
        }
        parts.append(feeding.fedAt.formatted(date: .omitted, time: .shortened))
        return parts.joined(separator: ", ")
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
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(spokenLabel)
        .accessibilityIdentifier(Self.accessibilityIdentifier)
    }
}
