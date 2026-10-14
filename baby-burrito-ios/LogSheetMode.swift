import BabyCore
import Foundation

enum LogSheetMode: Identifiable {
    case log(after: Feeding?)
    case edit(LocalFeeding)
    case logged(LocalFeeding)

    var id: String {
        switch self {
        case .log:                      "log"
        case .edit(let localFeeding):   "edit-\(localFeeding.id)"
        case .logged(let localFeeding): "logged-\(localFeeding.id)"
        }
    }
}
