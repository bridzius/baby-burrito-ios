import Foundation

public enum ChipSuggestions {
    public static let count: Int                   = 5
    public static let lookback: TimeInterval       = 14 * 24 * 60 * 60
    public static let defaultBottleMl: [Int]       = [30, 60, 90, 120, 150]
    public static let defaultNursingMinutes: [Int] = [5, 10, 15, 20, 30]

    public static func values(
        for kind:      FeedingKind,
        from feedings: [Feeding],
        now:           Date
    ) -> [Int] {
        let lookbackStart: Date = now.addingTimeInterval(-lookback)
        let recentValues: [Int] = feedings
            .filter { $0.details.kind == kind && $0.fedAt >= lookbackStart }
            .sorted { $0.fedAt > $1.fedAt }
            .compactMap { kind.isBottle ? $0.details.amountMl : $0.details.durationMinutes }

        let defaults: [Int]     = kind.isBottle ? defaultBottleMl : defaultNursingMinutes
        let mostFrequent: [Int] = mostFrequentFirst(newestFirst: recentValues)
        let candidates: [Int]   = mostFrequent + defaults.filter { !mostFrequent.contains($0) }

        return Array(candidates.prefix(count)).sorted()
    }

    private static func mostFrequentFirst(newestFirst values: [Int]) -> [Int] {
        let counts: [Int: Int]         = values.reduce(into: [:]) { $0[$1, default: 0] += 1 }
        let distinctNewestFirst: [Int] = values.reduce(into: []) { distinct, value in
            if !distinct.contains(value) { distinct.append(value) }
        }

        return distinctNewestFirst.enumerated()
            .sorted { lhs, rhs in
                let lhsCount: Int = counts[lhs.element, default: 0]
                let rhsCount: Int = counts[rhs.element, default: 0]
                return lhsCount == rhsCount ? lhs.offset < rhs.offset : lhsCount > rhsCount
            }
            .map(\.element)
    }
}
