import Foundation

public struct DeletedFeeding: Equatable, Sendable {
    public let feeding: Feeding
    public let zoneName: String
    public let clientModifiedAt: Date
    public let authorRecordName: String?
}
