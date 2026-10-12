import BabyCore
import SwiftUI

struct FeedingIntervalPicker: View {
    static let chipMinutes: [Int]                    = [120, 150, 180, 210, 240]
    static let chipFormat: Duration.UnitsFormatStyle = .units(
        allowed: [.hours, .minutes], width: .narrow
    )

    @Binding var feedingIntervalMinutes: Int

    var body: some View {
        Stepper(
            value: $feedingIntervalMinutes,
            in:    Baby.allowedFeedingIntervalMinutes,
            step:  Baby.feedingIntervalStepMinutes
        ) {
            Text(Duration.minutes(feedingIntervalMinutes).formatted(.hoursAndMinutes))
                .numerals(.title3)
        }

        HStack {
            ForEach(Self.chipMinutes, id: \.self) { minutes in
                chip(minutes: minutes)
            }
        }
    }

    private func chip(minutes: Int) -> some View {
        Button(Duration.minutes(minutes).formatted(Self.chipFormat)) {
            feedingIntervalMinutes = minutes
        }
        .buttonStyle(.bordered)
        .tint(minutes == feedingIntervalMinutes ? .accentColor : .secondary)
        .monospacedDigit()
    }
}
