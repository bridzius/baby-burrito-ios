public struct FeedingDetails: Equatable, Sendable {
    public static let allowedAmountsMl: ClosedRange<Int>      = 1...500
    public static let allowedNursingMinutes: ClosedRange<Int> = 1...120

    public var kind: FeedingKind
    public var amountMl: Int?
    public var durationMinutes: Int?
    public var side: Side?

    public init(
        kind:            FeedingKind,
        amountMl:        Int?  = nil,
        durationMinutes: Int?  = nil,
        side:            Side? = nil
    ) {
        self.kind            = kind
        self.amountMl        = amountMl
        self.durationMinutes = durationMinutes
        self.side            = side
    }

    public func changingKind(to newKind: FeedingKind) -> FeedingDetails {
        guard newKind != kind else { return self }
        return FeedingDetails(kind: newKind)
    }

    public func validated() throws(FeedingValidationError) -> FeedingDetails {
        kind.isBottle ? try validatedBottle() : try validatedNursing()
    }

    private func validatedNursing() throws(FeedingValidationError) -> FeedingDetails {
        guard amountMl == nil else { throw .amountOnlyForBottles }
        guard let durationMinutes else { throw .missingDuration }
        guard Self.allowedNursingMinutes.contains(durationMinutes) else {
            throw .durationOutOfRange
        }
        guard side != nil else { throw .missingSide }
        return self
    }

    private func validatedBottle() throws(FeedingValidationError) -> FeedingDetails {
        guard durationMinutes == nil, side == nil else { throw .nursingFieldsOnlyForNursing }
        guard let amountMl else { throw .missingAmount }
        guard Self.allowedAmountsMl.contains(amountMl) else { throw .amountOutOfRange }
        return self
    }
}
