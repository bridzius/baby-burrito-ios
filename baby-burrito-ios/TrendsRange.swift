import Foundation

enum TrendsRange: Int, CaseIterable, Identifiable {
    case week  = 7
    case month = 30

    var id: Int { rawValue }
    var days: Int { rawValue }

    var title: LocalizedStringResource {
        switch self {
        case .week:  "7 days"
        case .month: "30 days"
        }
    }
}
