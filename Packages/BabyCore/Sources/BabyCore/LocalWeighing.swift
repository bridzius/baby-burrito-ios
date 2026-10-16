import Foundation
import SwiftData

@Model
public final class LocalWeighing {
    @Attribute(.unique) public private(set) var weighedOn: Date
    public private(set) var zoneName: String
    public private(set) var grams: Int
    public private(set) var clientModifiedAt: Date
    private(set) var encodedSystemFields: Data?

    init(weighing: Weighing, zoneName: String, clientModifiedAt: Date) {
        self.weighedOn        = weighing.weighedOn
        self.zoneName         = zoneName
        self.grams            = weighing.grams
        self.clientModifiedAt = clientModifiedAt
    }

    public var weighing: Weighing {
        Weighing(weighedOn: weighedOn, grams: grams)
    }

    func apply(_ weighing: Weighing, modifiedAt: Date) {
        grams            = weighing.grams
        clientModifiedAt = modifiedAt
    }

    var synced: SyncedWeighing {
        SyncedWeighing(weighing: weighing, clientModifiedAt: clientModifiedAt)
    }

    func storeSystemFields(_ encodedSystemFields: Data?) {
        self.encodedSystemFields = encodedSystemFields
    }
}
