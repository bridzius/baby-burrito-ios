import AppIntents
import BabyCore

enum BottleKindAppEnum: String, AppEnum {
    case breastMilk
    case formula

    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Bottle"
    static let caseDisplayRepresentations: [BottleKindAppEnum: DisplayRepresentation] = [
        .breastMilk: "breast milk",
        .formula:    "formula",
    ]

    var feedingKind: FeedingKind {
        switch self {
        case .breastMilk: .breastMilk
        case .formula:    .formula
        }
    }
}
