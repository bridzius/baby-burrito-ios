import BabyCore
import Foundation

enum WeighingSheetMode: Identifiable {
    case log(latestGrams: Int?)
    case edit(Weighing)

    var id: String {
        switch self {
        case .log:                   "log"
        case .edit(let weighing):    "edit-\(weighing.weighedOn.timeIntervalSinceReferenceDate)"
        }
    }
}
