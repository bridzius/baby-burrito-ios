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
}
