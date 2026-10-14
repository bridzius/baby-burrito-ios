public struct FeedingActivityState: Equatable, Sendable {
    public var attributes: FeedingActivityAttributes
    public var content: FeedingActivityContent

    public init(attributes: FeedingActivityAttributes, content: FeedingActivityContent) {
        self.attributes = attributes
        self.content    = content
    }
}
