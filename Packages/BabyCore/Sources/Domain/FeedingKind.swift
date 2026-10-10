public enum FeedingKind: String, CaseIterable, Codable, Sendable {
    case nursing
    case breastMilk = "breast_milk"
    case formula

    public var isBottle: Bool { self != .nursing }
}
