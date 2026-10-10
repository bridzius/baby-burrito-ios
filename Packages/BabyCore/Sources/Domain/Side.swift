public enum Side: String, CaseIterable, Codable, Sendable {
    case left
    case right
    case both

    public var other: Side {
        switch self {
        case .left:  .right
        case .right: .left
        case .both:  .both
        }
    }
}
