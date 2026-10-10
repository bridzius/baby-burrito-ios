import Foundation

public enum FeedingValidationError: Error, CaseIterable, Equatable, Sendable {
    case amountOnlyForBottles
    case missingAmount
    case amountOutOfRange
    case nursingFieldsOnlyForNursing
    case missingDuration
    case durationOutOfRange
    case missingSide
    case fedAtBeforeBirthDay
    case fedAtInFuture

    public var reason: String {
        let fewestMl: Int      = FeedingDetails.allowedAmountsMl.lowerBound
        let mostMl: Int        = FeedingDetails.allowedAmountsMl.upperBound
        let fewestMinutes: Int = FeedingDetails.allowedNursingMinutes.lowerBound
        let mostMinutes: Int   = FeedingDetails.allowedNursingMinutes.upperBound

        switch self {
        case .amountOnlyForBottles:
            return String(localized: "Only a bottle has an amount.", bundle: .module)
        case .missingAmount:
            return String(localized: "Enter an amount.", bundle: .module)
        case .amountOutOfRange:
            return String(
                localized: "Enter an amount from \(fewestMl) to \(mostMl) ml.",
                bundle: .module
            )
        case .nursingFieldsOnlyForNursing:
            return String(
                localized: "Only a nursing has a duration and a side.",
                bundle: .module
            )
        case .missingDuration:
            return String(localized: "Enter a duration.", bundle: .module)
        case .durationOutOfRange:
            return String(
                localized: "Enter a duration from \(fewestMinutes) to \(mostMinutes) min.",
                bundle: .module
            )
        case .missingSide:
            return String(localized: "Choose a side.", bundle: .module)
        case .fedAtBeforeBirthDay:
            return String(
                localized: "A feeding can't be before the birth date.",
                bundle: .module
            )
        case .fedAtInFuture:
            return String(localized: "A feeding can't be in the future.", bundle: .module)
        }
    }
}
