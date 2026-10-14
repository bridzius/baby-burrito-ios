import AppIntents
import BabyCore

enum SideAppEnum: String, AppEnum {
    case left
    case right
    case both

    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Side"
    static let caseDisplayRepresentations: [SideAppEnum: DisplayRepresentation] = [
        .left:  "left",
        .right: "right",
        .both:  "both",
    ]

    var side: Side {
        switch self {
        case .left:  .left
        case .right: .right
        case .both:  .both
        }
    }
}
