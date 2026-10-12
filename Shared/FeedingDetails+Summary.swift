import BabyCore
import Foundation

extension FeedingDetails {
    static let summarySeparator: String = " · "

    // Synced feedings are stored unvalidated (ADR 0005), so missing fields are left out.
    var summary: String {
        var parts: [String] = [String(localized: kind.name)]

        if let side {
            parts.append(String(localized: side.name))
        }
        if let durationMinutes {
            parts.append(Duration.minutes(durationMinutes).formatted(.hoursAndMinutes))
        }
        if let amountMl {
            let amount: Measurement<UnitVolume> = Measurement(
                value: Double(amountMl), unit: .milliliters
            )
            parts.append(amount.formatted(.measurement(width: .abbreviated)))
        }
        return parts.joined(separator: Self.summarySeparator)
    }
}
