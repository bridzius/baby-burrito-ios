import BabyCore
import SwiftData
import SwiftUI

struct LogSheet: View {
    static let amountStepMl: Int        = 10
    static let durationStepMinutes: Int = 1

    let title: LocalizedStringKey
    let birthDate: Date
    let save: (_ fedAt: Date, _ details: FeedingDetails) throws -> Void

    @State private var draft: LogSheetDraft
    @State private var isShowingSaveFailure: Bool = false
    @Query private var recentFeedings: [LocalFeeding]
    @Environment(\.dismiss) private var dismiss: DismissAction

    init(
        title:     LocalizedStringKey,
        draft:     LogSheetDraft,
        birthDate: Date,
        save:      @escaping (_ fedAt: Date, _ details: FeedingDetails) throws -> Void
    ) {
        self.title     = title
        self.birthDate = birthDate
        self.save      = save
        _draft         = State(initialValue: draft)

        let lookbackStart: Date = Date.now.addingTimeInterval(-ChipSuggestions.lookback)
        _recentFeedings = Query(filter: #Predicate<LocalFeeding> { $0.fedAt >= lookbackStart })
    }

    private var chipValues: [Int] {
        ChipSuggestions.values(for: draft.kind, from: recentFeedings.map(\.feeding), now: .now)
    }

    private var fedAtRange: ClosedRange<Date> {
        let calendar: Calendar = .autoupdatingCurrent
        return calendar.startOfDay(for: birthDate)...Date.now.addingTimeInterval(
            Feeding.maximumFutureDrift
        )
    }

    private var invalidReason: String? {
        do {
            _ = try Feeding.validated(
                id:        UUID(),
                fedAt:     draft.fedAt,
                details:   draft.details,
                birthDate: birthDate,
                now:       .now,
                calendar:  .autoupdatingCurrent
            )
            return nil
        } catch {
            return error.reason
        }
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
        NavigationStack {
            Form {
                Section {
                    KindPicker(kind: $draft.kind)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                }

                if draft.kind.isBottle {
                    Section("Amount") {
                        amountStepper
                    }
                } else {
                    Section("Side") {
                        SidePicker(side: $draft.side)
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Color.clear)
                    }
                    Section("Duration") {
                        durationStepper
                    }
                }

                Section {
                    DatePicker("Started", selection: fedAtBinding, in: fedAtRange)
                } footer: {
                    if let invalidReason {
                        Text(invalidReason)
                    }
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done", role: .confirm, action: saveDraft)
                        .disabled(invalidReason != nil)
                }
            }
            .onChange(of: draft.details) {
                draft.refreshDefaultFedAt(now: .now)
            }
            .alert("Couldn't save. Try again.", isPresented: $isShowingSaveFailure) {}
        }
        .presentationDetents([.medium, .large])
    }

    private var amountStepper: some View {
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

    private var durationStepper: some View {
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

    private func saveDraft() {
        do {
            try save(draft.fedAt, draft.details)
            dismiss()
        } catch {
            isShowingSaveFailure = true
        }
    }
}
