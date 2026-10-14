import BabyCore
import Foundation

extension Side {
    var name: LocalizedStringResource {
        switch self {
        case .left:  LocalizedStringResource("left", table: "Shared")
        case .right: LocalizedStringResource("right", table: "Shared")
        case .both:  LocalizedStringResource("both", table: "Shared")
        }
    }

    // Keyed by meaning: a literal "Both" key would collide with "both" in generated symbols.
    var shortName: LocalizedStringResource {
        switch self {
        case .left:
            LocalizedStringResource("side.short.left", defaultValue: "L", table: "Shared")
        case .right:
            LocalizedStringResource("side.short.right", defaultValue: "R", table: "Shared")
        case .both:
            LocalizedStringResource("side.short.both", defaultValue: "Both", table: "Shared")
        }
    }
}
