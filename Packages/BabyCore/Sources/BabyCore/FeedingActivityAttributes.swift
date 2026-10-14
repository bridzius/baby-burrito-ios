// Plain data on every platform so the lifecycle decisions test on macOS; ActivityKit below.
public struct FeedingActivityAttributes: Codable, Hashable, Sendable {
    public typealias ContentState = FeedingActivityContent

    public var babyName: String
    public var zoneName: String
    public var canLog: Bool

    public init(babyName: String, zoneName: String, canLog: Bool) {
        self.babyName = babyName
        self.zoneName = zoneName
        self.canLog   = canLog
    }
}

#if os(iOS)
import ActivityKit

extension FeedingActivityAttributes: ActivityAttributes {}
#endif
