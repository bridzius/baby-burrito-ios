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
}
