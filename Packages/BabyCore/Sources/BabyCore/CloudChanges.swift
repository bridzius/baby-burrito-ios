import CloudKit
import Foundation

public struct CloudChanges: Equatable, Sendable {
    public var zoneChanges: [CKSyncEngine.PendingDatabaseChange]         = []
    public var recordChanges: [CKSyncEngine.PendingRecordZoneChange]     = []

    static func translating(_ change: PendingChange, calendar: Calendar) -> CloudChanges {
        switch change {
        case .saveBaby(let zoneName):
            let zoneID: CKRecordZone.ID = RecordMapping.zoneID(zoneName: zoneName)
            return CloudChanges(
                zoneChanges:   [.saveZone(CKRecordZone(zoneID: zoneID))],
                recordChanges: [.saveRecord(RecordMapping.babyRecordID(zoneName: zoneName))]
            )
        case .saveFeeding(let id, let zoneName):
            return CloudChanges(recordChanges: [
                .saveRecord(RecordMapping.feedingRecordID(id: id, zoneName: zoneName)),
            ])
        case .deleteFeeding(let id, let zoneName):
            return CloudChanges(recordChanges: [
                .deleteRecord(RecordMapping.feedingRecordID(id: id, zoneName: zoneName)),
            ])
        case .saveWeighing(let weighedOn, let zoneName):
            return CloudChanges(recordChanges: [.saveRecord(RecordMapping.weighingRecordID(
                weighedOn: weighedOn, zoneName: zoneName, calendar: calendar
            ))])
        case .deleteWeighing(let weighedOn, let zoneName):
            return CloudChanges(recordChanges: [.deleteRecord(RecordMapping.weighingRecordID(
                weighedOn: weighedOn, zoneName: zoneName, calendar: calendar
            ))])
        case .deleteBabyLog(let zoneName):
            return CloudChanges(zoneChanges: [
                .deleteZone(RecordMapping.zoneID(zoneName: zoneName)),
            ])
        }
    }
}
