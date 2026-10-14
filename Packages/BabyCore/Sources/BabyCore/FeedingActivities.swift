// The running Live Activity, behind a protocol so the controller's decisions test without
// ActivityKit.
@MainActor
public protocol FeedingActivities {
    var running: FeedingActivityState? { get }
    func start(_ state: FeedingActivityState) throws
    func update(to content: FeedingActivityContent) async
    func end() async
}
