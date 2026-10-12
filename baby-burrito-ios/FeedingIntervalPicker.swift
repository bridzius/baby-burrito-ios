import BabyCore
import SwiftUI

struct FeedingIntervalPicker: View {
    static let chipMinutes: [Int] = [120, 150, 180, 210, 240]

    @Binding var feedingIntervalMinutes: Int

    var body: some View {
        Stepper(
            value: $feedingIntervalMinutes,
            in:    Baby.allowedFeedingIntervalMinutes,
            step:  Baby.feedingIntervalStepMinutes
        ) {
            Text(Self.formatted(minutes: feedingIntervalMinutes))
                .numerals(.title3)
        }

        HStack {
            ForEach(Self.chipMinutes, id: \.self) { minutes in
                chip(minutes: minutes)
            }
        }
    }

    private func chip(minutes: Int) -> some View {
        Button(Self.formatted(minutes: minutes)) {
            feedingIntervalMinutes = minutes
        }
        .buttonStyle(.bordered)
        .tint(minutes == feedingIntervalMinutes ? .accentColor : .secondary)
        .monospacedDigit()
    }

    private static func formatted(minutes: Int) -> String {
        Duration.seconds(minutes * 60)
            .formatted(.units(allowed: [.hours, .minutes], width: .narrow))
    }
}
