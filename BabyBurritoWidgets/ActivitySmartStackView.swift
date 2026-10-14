import BabyCore
import SwiftUI

// The Apple Watch Smart Stack's .small layout: kind symbol, next feeding time and the countdown.
struct ActivitySmartStackView: View {
    static let minimumHeadlineScale: CGFloat = 0.6

    let content: FeedingActivityContent
    let isDue: Bool

    @Environment(\.isLuminanceReduced) private var isLuminanceReduced: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 4) {
                if let kind = content.lastKind {
                    Image(systemName: kind.symbolName)
                        .foregroundStyle(isLuminanceReduced ? .secondary : kind.color)
                }
                if let nextFeedingAt = content.nextFeedingAt {
                    Text("Next \(nextFeedingAt, format: .dateTime.hour().minute())")
                        .font(.caption)
                }
            }

            if let nextFeedingAt = content.nextFeedingAt {
                ActivityTimer.headline(
                    nextFeedingAt:      nextFeedingAt,
                    isDue:              isDue,
                    isLuminanceReduced: isLuminanceReduced
                )
                .numerals(.headline)
                .lineLimit(1)
                .minimumScaleFactor(Self.minimumHeadlineScale)
            } else {
                Text("No feedings yet")
                    .font(.headline)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
