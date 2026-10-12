import BabyCore
import SwiftUI

extension FeedingKind {
    var color: Color {
        switch self {
        case .nursing:    Color(.kindRose)
        case .breastMilk: Color(.kindAmber)
        case .formula:    Color(.kindTeal)
        }
    }

    // Nursing gets a custom template symbol at design time; heart.fill stands in until then.
    var symbolName: String {
        switch self {
        case .nursing:    "heart.fill"
        case .breastMilk: "drop.fill"
        case .formula:    "waterbottle.fill"
        }
    }

    var name: LocalizedStringResource {
        switch self {
        case .nursing:    LocalizedStringResource("Nursing", table: "Shared")
        case .breastMilk: LocalizedStringResource("Breast milk", table: "Shared")
        case .formula:    LocalizedStringResource("Formula", table: "Shared")
        }
    }
}
