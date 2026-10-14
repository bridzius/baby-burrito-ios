import SwiftUI

// A stepper over the full range plus one-tap chips for common values.
struct ChipStepper: View {
    let chipValues: [Int]
    let range: ClosedRange<Int>
    let step: Int
    let tint: Color
    let valueLabel: (Int) -> String
    let chipLabel: (Int) -> String

    @Binding var value: Int

    var body: some View {
        Stepper(value: $value, in: range, step: step) {
            Text(valueLabel(value))
                .numerals(.title3)
                .contentTransition(.numericText(value: Double(value)))
        }

        HStack {
            ForEach(chipValues, id: \.self) { chipValue in
                Button(chipLabel(chipValue)) {
                    value = chipValue
                }
                .buttonStyle(.bordered)
                .tint(chipValue == value ? tint : .secondary)
                .monospacedDigit()
                .accessibilityAddTraits(chipValue == value ? .isSelected : [])
            }
        }
    }
}
