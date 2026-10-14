import Foundation

public enum BabyValidationError: Error, CaseIterable, Equatable, Sendable {
    case emptyName
    case birthDateTooEarly
    case birthDateAfterEarliestFeeding
    case feedingIntervalNotAllowed

    public var reason: String {
        switch self {
        case .emptyName:
            return String(localized: "Enter the baby's name.", bundle: .module)
        case .birthDateTooEarly:
            return String(
                localized: "Choose a birth date on or after 1 January 2026.",
                bundle: .module
            )
        case .birthDateAfterEarliestFeeding:
            return String(
                localized: "Choose a birth date on or before the first feeding.",
                bundle: .module
            )
        case .feedingIntervalNotAllowed:
            return String(
                localized: "Choose an interval from 15 min to 12 h, in 15-minute steps.",
                bundle: .module
            )
        }
    }
}
