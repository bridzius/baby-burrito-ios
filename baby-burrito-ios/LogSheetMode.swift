import BabyCore
import Foundation

enum LogSheetMode: Identifiable {
    case log(after: Feeding?)
    case edit(LocalFeeding)

    var id: String {
        switch self {
        case .log:                    "log"
        case .edit(let localFeeding): localFeeding.id.uuidString
        }
    }
}
