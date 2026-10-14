import BabyCore
import SwiftData
import SwiftUI

// The Log sheet's form sections, shared by logging, editing and the logged confirmation.
struct FeedingFields: View {
    static let amountStepMl: Int        = 10
    static let durationStepMinutes: Int = 1

    @Binding var draft: LogSheetDraft
    let birthDate: Date

    @Query private var recentFeedings: [LocalFeeding]

    init(draft: Binding<LogSheetDraft>, birthDate: Date) {
        _draft         = draft
        self.birthDate = birthDate

        let lookbackStart: Date = Date.now.addingTimeInterval(-ChipSuggestions.lookback)
        _recentFeedings = Query(filter: #Predicate<LocalFeeding> { $0.fedAt >= lookbackStart })
    }

    private var chipValues: [Int] {
        ChipSuggestions.values(for: draft.kind, from: recentFeedings.map(\.feeding), now: .now)
    }

    private var fedAtRange: ClosedRange<Date> {
        let birthDayStart: Date = Calendar.autoupdatingCurrent.startOfDay(for: birthDate)
        return birthDayStart...Date.now.addingTimeInterval(Feeding.maximumFutureDrift)
    }

    private var fedAtBinding: Binding<Date> {
        Binding {
            draft.fedAt
        } set: { chosenFedAt in
            draft.fedAt         = chosenFedAt
            draft.isFedAtChosen = true
        }
    }

    var body: some View {
        Section {
            KindPicker(kind: $draft.kind)
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
        }

        if draft.kind.isBottle {
            Section("Amount") {
                ChipStepper(
                    chipValues: chipValues,
                    range:      FeedingDetails.allowedAmountsMl,
                    step:       Self.amountStepMl,
                    tint:       draft.kind.color,
                    valueLabel: { $0.formattedMillilitres },
                    chipLabel:  { String($0) },
                    value:      $draft.amountMl
                )
            }
        } else {
            Section("Side") {
                SidePicker(side: $draft.side)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
            }
            Section("Duration") {
                ChipStepper(
                    chipValues: chipValues,
                    range:      FeedingDetails.allowedNursingMinutes,
                    step:       Self.durationStepMinutes,
                    tint:       draft.kind.color,
                    valueLabel: { Duration.minutes($0).formatted(.hoursAndMinutes) },
                    chipLabel:  { String($0) },
                    value:      $draft.durationMinutes
                )
            }
        }

        Section {
            DatePicker("Started", selection: fedAtBinding, in: fedAtRange)
        } footer: {
            if let invalidReason = draft.invalidReason(birthDate: birthDate, now: .now) {
                Text(invalidReason)
            }
        }
    }
}
