#if os(iOS)
import ActivityKit

public struct FeedingActivityAttributes: ActivityAttributes {
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
#endif
