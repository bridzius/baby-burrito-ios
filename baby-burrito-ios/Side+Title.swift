import BabyCore
import Foundation

extension Side {
    var title: LocalizedStringResource {
        switch self {
        case .left:  "Left"
        case .right: "Right"
        case .both:  "Both"
        }
    }

    var spokenName: LocalizedStringResource {
        switch self {
        case .left:  "left breast"
        case .right: "right breast"
        case .both:  "both breasts"
        }
    }
}
