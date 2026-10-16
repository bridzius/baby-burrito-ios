import Foundation

public enum WeighingValidationError: Error, CaseIterable, Equatable, Sendable {
    case weightOutOfRange
    case weighedOnBeforeBirthDay
    case weighedOnInFuture

    public var reason: String {
        let fewestGrams: Int = Weighing.allowedGrams.lowerBound
        let mostGrams: Int   = Weighing.allowedGrams.upperBound

        switch self {
        case .weightOutOfRange:
            return String(
                localized: "Enter a weight from \(fewestGrams) to \(mostGrams) g.",
                bundle: .module
            )
        case .weighedOnBeforeBirthDay:
            return String(
                localized: "A weighing can't be before the birth date.",
                bundle: .module
            )
        case .weighedOnInFuture:
            return String(localized: "A weighing can't be in the future.", bundle: .module)
        }
    }
}
