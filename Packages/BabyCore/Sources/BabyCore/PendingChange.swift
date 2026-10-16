import Foundation

public enum PendingChange: Equatable, Sendable {
    case saveBaby(zoneName: String)
    case saveFeeding(id: UUID, zoneName: String)
    case deleteFeeding(id: UUID, zoneName: String)
    case saveWeighing(weighedOn: Date, zoneName: String)
    case deleteWeighing(weighedOn: Date, zoneName: String)
    case deleteBabyLog(zoneName: String)
}
