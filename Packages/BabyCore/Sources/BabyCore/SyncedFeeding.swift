import Foundation

public struct SyncedFeeding: Equatable, Sendable {
    public let feeding: Feeding
    public let clientModifiedAt: Date
    public let authorRecordName: String?
}
