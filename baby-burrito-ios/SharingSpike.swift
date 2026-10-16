#if DEBUG
import CloudKit
import Observation

// Spike #25, never merged: one zone with a zone-wide share, accepted on a second phone and
// fetched there with a shared-database CKSyncEngine. A singleton because the scene delegate
// that receives the accepted share has no other way to reach it.
@MainActor
@Observable
final class SharingSpike {
    static let shared: SharingSpike         = SharingSpike()
    static let containerIdentifier: String  = "iCloud.com.bridzius.babyburrito"
    static let spikeBabyName: String        = "Spike"
    static let testAmountMl: Int            = 90

    let container: CKContainer = CKContainer(identifier: containerIdentifier)

    private(set) var logLines: [String] = []
    private(set) var share: CKShare?
    private(set) var ownedZoneID: CKRecordZone.ID?
    private var sharedEngine: CKSyncEngine?
    private var engineDelegate: SharingSpikeEngineDelegate?

    func log(_ line: String) {
        let time: String = Date.now.formatted(date: .omitted, time: .standard)
        logLines.append("\(time) \(line)")
    }

    // Owner: a fresh zone holding the baby record, shared as a whole with no public access.
    func createSharedZone() async {
        let database: CKDatabase = container.privateCloudDatabase
        let zone: CKRecordZone   = CKRecordZone(zoneName: "BabyLog-\(UUID())")
        do {
            _ = try await database.modifyRecordZones(saving: [zone], deleting: [])
            log("Saved zone \(zone.zoneID.zoneName)")

            let baby: CKRecord = CKRecord(
                recordType: "Baby",
                recordID:   CKRecord.ID(recordName: "baby", zoneID: zone.zoneID)
            )
            baby.encryptedValues["name"] = Self.spikeBabyName

            let zoneShare: CKShare                       = CKShare(recordZoneID: zone.zoneID)
            zoneShare.publicPermission                   = .none
            zoneShare[CKShare.SystemFieldKey.title]      = Self.spikeBabyName

            let (saveResults, _) = try await database.modifyRecords(
                saving: [baby, zoneShare], deleting: []
            )
            for (recordID, result) in saveResults {
                switch result {
                case .success(let record):
                    log("Saved \(record.recordType) \(recordID.recordName)")
                    if let savedShare = record as? CKShare { share = savedShare }
                case .failure(let error):
                    log("Failed \(recordID.recordName): \(error)")
                }
            }
            ownedZoneID = zone.zoneID
        } catch {
            log("Create failed: \(error)")
        }
    }

    // Owner, after the participant accepted: a new feeding must reach the participant's fetch.
    func saveTestFeeding() async {
        guard let ownedZoneID else { return log("Create the shared zone first") }
        let feeding: CKRecord = CKRecord(
            recordType: "Feeding",
            recordID:   CKRecord.ID(recordName: UUID().uuidString, zoneID: ownedZoneID)
        )
        feeding.encryptedValues["fedAt"]    = Date.now
        feeding.encryptedValues["kind"]     = "formula"
        feeding.encryptedValues["amountMl"] = Self.testAmountMl
        do {
            _ = try await container.privateCloudDatabase.save(feeding)
            log("Saved feeding \(feeding.recordID.recordName)")
        } catch {
            log("Feeding save failed: \(error)")
        }
    }

    // Participant: called by the scene delegate with the metadata from the tapped invite.
    func accept(_ metadata: CKShare.Metadata) async {
        log("Accepting share of \(metadata.share.recordID.zoneID.zoneName)")
        do {
            let acceptedShare: CKShare = try await container.accept(metadata)
            log("Accepted; permission \(acceptedShare.currentUserParticipant?.permission.rawValue ?? -1)")
            startSharedEngine()
            await fetchSharedChanges()
        } catch {
            log("Accept failed: \(error)")
        }
    }

    func startSharedEngine() {
        guard sharedEngine == nil else { return }
        let delegate: SharingSpikeEngineDelegate = SharingSpikeEngineDelegate { line in
            Task { @MainActor in SharingSpike.shared.log(line) }
        }
        let configuration: CKSyncEngine.Configuration = CKSyncEngine.Configuration(
            database:           container.sharedCloudDatabase,
            stateSerialization: nil,
            delegate:           delegate
        )
        engineDelegate = delegate
        sharedEngine   = CKSyncEngine(configuration)
        log("Started the shared-database engine")
    }

    func fetchSharedChanges() async {
        guard let sharedEngine else { return log("Start the shared engine first") }
        do {
            try await sharedEngine.fetchChanges()
            log("Fetch finished")
        } catch {
            log("Fetch failed: \(error)")
        }
    }
}
#endif
