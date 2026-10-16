import Foundation

public struct Weighing: Equatable, Sendable {
    public static let allowedGrams: ClosedRange<Int> = 500...25_000

    public let weighedOn: Date
    public let grams: Int

    public init(weighedOn: Date, grams: Int) {
        self.weighedOn = weighedOn
        self.grams     = grams
    }

    public static func validated(
        weighedOn: Date,
        grams:     Int,
        birthDate: Date,
        now:       Date,
        calendar:  Calendar
    ) throws(WeighingValidationError) -> Weighing {
        let dayStart: Date = calendar.startOfDay(for: weighedOn)

        guard allowedGrams.contains(grams) else { throw .weightOutOfRange }
        guard dayStart >= calendar.startOfDay(for: birthDate) else {
            throw .weighedOnBeforeBirthDay
        }
        guard dayStart <= calendar.startOfDay(for: now) else { throw .weighedOnInFuture }

        return Weighing(weighedOn: dayStart, grams: grams)
    }
}
