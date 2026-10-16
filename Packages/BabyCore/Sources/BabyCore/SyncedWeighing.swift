import Foundation

public struct SyncedWeighing: Equatable, Sendable {
    public let weighing: Weighing
    public let clientModifiedAt: Date
}
