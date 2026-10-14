import BabyCore
import SwiftUI

struct FeedingIntervalPicker: View {
    static let chipMinutes: [Int]                    = [120, 150, 180, 210, 240]
    static let chipFormat: Duration.UnitsFormatStyle = .units(
        allowed: [.hours, .minutes], width: .narrow
    )

    @Binding var feedingIntervalMinutes: Int

    var body: some View {
        ChipStepper(
            chipValues: Self.chipMinutes,
            range:      Baby.allowedFeedingIntervalMinutes,
            step:       Baby.feedingIntervalStepMinutes,
            tint:       .accentColor,
            valueLabel: { Duration.minutes($0).formatted(.hoursAndMinutes) },
            chipLabel:  { Duration.minutes($0).formatted(Self.chipFormat) },
            value:      $feedingIntervalMinutes
        )
    }
}
