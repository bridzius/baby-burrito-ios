import Foundation
import SwiftData

@Model
public final class LocalFeeding {
    @Attribute(.unique) public private(set) var id: UUID
    public private(set) var zoneName: String
    public private(set) var fedAt: Date
    public private(set) var kind: FeedingKind
    public private(set) var amountMl: Int?
    public private(set) var durationMinutes: Int?
    public private(set) var side: Side?
    public private(set) var clientModifiedAt: Date
    public private(set) var authorRecordName: String?
    private(set) var encodedSystemFields: Data?

    init(
        feeding:          Feeding,
        zoneName:         String,
        clientModifiedAt: Date,
        authorRecordName: String? = nil
    ) {
        self.id               = feeding.id
        self.zoneName         = zoneName
        self.fedAt            = feeding.fedAt
        self.kind             = feeding.details.kind
        self.amountMl         = feeding.details.amountMl
        self.durationMinutes  = feeding.details.durationMinutes
        self.side             = feeding.details.side
        self.clientModifiedAt = clientModifiedAt
        self.authorRecordName = authorRecordName
    }

    public var feeding: Feeding {
        let details: FeedingDetails = FeedingDetails(
            kind:            kind,
            amountMl:        amountMl,
            durationMinutes: durationMinutes,
            side:            side
        )
        return Feeding(id: id, fedAt: fedAt, details: details)
    }

    func apply(_ feeding: Feeding, modifiedAt: Date) {
        fedAt            = feeding.fedAt
        kind             = feeding.details.kind
        amountMl         = feeding.details.amountMl
        durationMinutes  = feeding.details.durationMinutes
        side             = feeding.details.side
        clientModifiedAt = modifiedAt
    }

    func apply(_ synced: SyncedFeeding) {
        apply(synced.feeding, modifiedAt: synced.clientModifiedAt)
        authorRecordName = synced.authorRecordName
    }

    var synced: SyncedFeeding {
        SyncedFeeding(
            feeding:          feeding,
            clientModifiedAt: clientModifiedAt,
            authorRecordName: authorRecordName
        )
    }

    func storeSystemFields(_ encodedSystemFields: Data?) {
        self.encodedSystemFields = encodedSystemFields
    }
}
