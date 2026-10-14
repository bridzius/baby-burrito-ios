import BabyCore
import Foundation

// Keeps every kind's fields while the sheet is open, so switching kind and back loses nothing.
struct LogSheetDraft {
    static let defaultKind: FeedingKind    = .nursing
    static let defaultAmountMl: Int        = 90
    static let defaultDurationMinutes: Int = 15
    static let defaultSide: Side           = .left

    var kind: FeedingKind
    var amountMl: Int
    var durationMinutes: Int
    var side: Side
    var fedAt: Date
    var isFedAtChosen: Bool

    var details: FeedingDetails {
        guard kind.isBottle else {
            return FeedingDetails(kind: .nursing, durationMinutes: durationMinutes, side: side)
        }
        return FeedingDetails(kind: kind, amountMl: amountMl)
    }

    // Prefilled with what the Repeat rule would log next.
    static func logging(after lastFeeding: Feeding?, now: Date) -> LogSheetDraft {
        let next: FeedingDetails? = Feeding.repeating(lastFeeding, id: UUID(), now: now)?.details
        var draft: LogSheetDraft  = LogSheetDraft(
            details:       next ?? FeedingDetails(kind: defaultKind),
            fedAt:         now,
            isFedAtChosen: false
        )
        draft.refreshDefaultFedAt(now: now)
        return draft
    }

    static func editing(_ feeding: Feeding) -> LogSheetDraft {
        LogSheetDraft(details: feeding.details, fedAt: feeding.fedAt, isFedAtChosen: true)
    }

    func invalidReason(birthDate: Date, now: Date) -> String? {
        do {
            _ = try Feeding.validated(
                id:        UUID(),
                fedAt:     fedAt,
                details:   details,
                birthDate: birthDate,
                now:       now,
                calendar:  .autoupdatingCurrent
            )
            return nil
        } catch {
            return error.reason
        }
    }

    mutating func refreshDefaultFedAt(now: Date) {
        guard !isFedAtChosen else { return }
        fedAt = details.defaultFedAt(now: now)
    }

    private init(details: FeedingDetails, fedAt: Date, isFedAtChosen: Bool) {
        self.kind            = details.kind
        self.amountMl        = details.amountMl ?? Self.defaultAmountMl
        self.durationMinutes = details.durationMinutes ?? Self.defaultDurationMinutes
        self.side            = details.side ?? Self.defaultSide
        self.fedAt           = fedAt
        self.isFedAtChosen   = isFedAtChosen
    }
}
