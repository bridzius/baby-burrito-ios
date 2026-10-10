public struct FeedingTotals: Equatable, Sendable {
    public var breastMilkMl: Int = 0
    public var formulaMl: Int    = 0
    public var bottleCount: Int  = 0
    public var leftMinutes: Int  = 0
    public var rightMinutes: Int = 0
    public var bothMinutes: Int  = 0
    public var nursingCount: Int = 0

    public init() {}

    public var totalMl: Int        { breastMilkMl + formulaMl }
    public var nursingMinutes: Int { leftMinutes + rightMinutes + bothMinutes }

    // Synced feedings are stored unvalidated (ADR 0005), so a missing field counts as zero.
    mutating func add(_ details: FeedingDetails) {
        let amountMl: Int        = details.amountMl ?? 0
        let durationMinutes: Int = details.durationMinutes ?? 0

        switch details.kind {
        case .breastMilk:
            breastMilkMl += amountMl
            bottleCount  += 1
        case .formula:
            formulaMl   += amountMl
            bottleCount += 1
        case .nursing:
            nursingCount += 1
            addNursingMinutes(durationMinutes, side: details.side)
        }
    }

    private mutating func addNursingMinutes(_ minutes: Int, side: Side?) {
        switch side {
        case .left:  leftMinutes  += minutes
        case .right: rightMinutes += minutes
        case .both:  bothMinutes  += minutes
        case nil:    break
        }
    }
}
