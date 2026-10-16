import BabyCore
import SwiftUI

struct WeighingSheet: View {
    static let defaultGrams: Int   = 3_500
    static let gramsStep: Int      = 10

    let mode: WeighingSheetMode
    let birthDate: Date
    let feedingStore: FeedingStore

    @State private var weighedOn: Date
    @State private var grams: Int
    @State private var isShowingSaveFailure: Bool = false
    @Environment(\.dismiss) private var dismiss: DismissAction

    init(mode: WeighingSheetMode, birthDate: Date, feedingStore: FeedingStore) {
        self.mode         = mode
        self.birthDate    = birthDate
        self.feedingStore = feedingStore

        switch mode {
        case .log(let latestGrams):
            _weighedOn = State(initialValue: .now)
            _grams     = State(initialValue: latestGrams ?? Self.defaultGrams)
        case .edit(let weighing):
            _weighedOn = State(initialValue: weighing.weighedOn)
            _grams     = State(initialValue: weighing.grams)
        }
    }

    private var isEditing: Bool {
        guard case .edit = mode else { return false }
        return true
    }

    private var invalidReason: String? {
        do {
            _ = try Weighing.validated(
                weighedOn: weighedOn,
                grams:     grams,
                birthDate: birthDate,
                now:       .now,
                calendar:  .autoupdatingCurrent
            )
            return nil
        } catch {
            return error.reason
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    DatePicker(
                        "Day",
                        selection:           $weighedOn,
                        in:                  birthDate...Date.now,
                        displayedComponents: .date
                    )
                    .disabled(isEditing)

                    Stepper(value: $grams, in: Weighing.allowedGrams, step: Self.gramsStep) {
                        Text(WeightText.grams(grams))
                            .numerals(.title3)
                            .contentTransition(.numericText(value: Double(grams)))
                    }

                    TextField("Weight in grams", value: $grams, format: .number)
                        .keyboardType(.numberPad)
                } footer: {
                    if let invalidReason {
                        Text(invalidReason)
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit weighing" : "Log weighing")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done", role: .confirm, action: save)
                        .disabled(invalidReason != nil)
                }
            }
            .alert("Couldn't save. Try again.", isPresented: $isShowingSaveFailure) {}
        }
        .presentationDetents([.medium, .large])
    }

    private func save() {
        do {
            _ = try feedingStore.logWeighing(weighedOn: weighedOn, grams: grams)
            dismiss()
        } catch {
            isShowingSaveFailure = true
        }
    }
}
