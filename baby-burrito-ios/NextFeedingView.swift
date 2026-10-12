import BabyCore
import SwiftUI

struct NextFeedingView: View {
    static let refreshSeconds: TimeInterval  = 60
    static let minimumDueForScale: CGFloat   = 0.8

    let lastFeeding: Feeding
    let feedingIntervalMinutes: Int
    let editFeedingInterval: () -> Void

    private var nextFeedingAt: Date {
        lastFeeding.nextFeedingAt(feedingIntervalMinutes: feedingIntervalMinutes)
    }

    private var nextFeedingTime: Text {
        Text(nextFeedingAt, format: .dateTime.hour().minute())
    }

    private var feedingInterval: Text {
        Text(Duration.minutes(feedingIntervalMinutes), format: .hoursAndMinutes)
    }

    // Whole-minute intervals put the due time and the minute after it on this schedule, so it
    // also switches the due state. The countdown itself is rendered by the system.
    private var everyMinuteSinceLastFeeding: PeriodicTimelineSchedule {
        .periodic(from: lastFeeding.fedAt, by: Self.refreshSeconds)
    }

    private func fractionElapsed(now: Date) -> Double {
        let interval: TimeInterval = nextFeedingAt.timeIntervalSince(lastFeeding.fedAt)
        guard interval > 0 else { return 1 }
        return min(max(now.timeIntervalSince(lastFeeding.fedAt) / interval, 0), 1)
    }

    var body: some View {
        TimelineView(everyMinuteSinceLastFeeding) { _ in
            let now: Date          = .now
            let dueState: DueState = DueState(nextFeedingAt: nextFeedingAt, now: now)

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    headline(dueState: dueState)
                    Spacer()
                    FeedingRing(
                        kind:            lastFeeding.details.kind,
                        fractionElapsed: fractionElapsed(now: now),
                        isPulsing:       dueState == .dueNow
                    )
                }

                Button(action: editFeedingInterval) {
                    Text("at \(nextFeedingTime) · every \(feedingInterval)")
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel(
                NextFeedingAccessibility.label(nextFeedingAt: nextFeedingAt, now: now)
            )
        }
    }

    @ViewBuilder
    private func headline(dueState: DueState) -> some View {
        switch dueState {
        case .notDue:
            Text("in \(Text(timerInterval: Date.now...nextFeedingAt, countsDown: true))")
                .numerals(.largeTitle)
        case .dueNow:
            Text("Due now")
                .numerals(.largeTitle)
        case .dueFor:
            ElapsedText(since: nextFeedingAt)
                .numerals(.title2)
                .lineLimit(1)
                .minimumScaleFactor(Self.minimumDueForScale)
        }
    }
}
