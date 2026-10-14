import BabyCore
import SwiftUI

// Lock Screen, expanded Dynamic Island, Always-On and StandBy. The countdown is the largest
// element so it reads from across the room in StandBy.
struct ActivityLockScreenView: View {
    static let ringSize: CGFloat             = 52
    static let minimumHeadlineScale: CGFloat = 0.7

    let babyName: String
    let content: FeedingActivityContent
    let canLog: Bool
    let isDue: Bool

    @Environment(\.isLuminanceReduced) private var isLuminanceReduced: Bool

    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(babyName)
                    .font(.headline)

                if let nextFeedingAt = content.nextFeedingAt {
                    ActivityTimer.headline(
                        nextFeedingAt:      nextFeedingAt,
                        isDue:              isDue,
                        isLuminanceReduced: isLuminanceReduced
                    )
                    .numerals(.title)
                    .lineLimit(1)
                    .minimumScaleFactor(Self.minimumHeadlineScale)
                } else {
                    Text("No feedings yet")
                        .font(.title3.weight(.semibold))
                }

                LastFeedingLine(content: content)

                Text(canLog ? "Tap to log next feeding" : "Open")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)

            if let kind = content.lastKind,
               let lastFedAt = content.lastFedAt,
               let nextFeedingAt = content.nextFeedingAt {
                ActivityRing(
                    kind:          kind,
                    lastFedAt:     lastFedAt,
                    nextFeedingAt: nextFeedingAt,
                    isDue:         isDue
                )
                .frame(width: Self.ringSize, height: Self.ringSize)
            }
        }
        .padding()
    }
}
