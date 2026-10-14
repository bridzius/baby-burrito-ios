import BabyCore
import SwiftUI

// Fills from the last feeding to the next, drawn by the system; full once due, never pulsing.
struct ActivityRing: View {
    let kind: FeedingKind
    let lastFedAt: Date
    let nextFeedingAt: Date
    let isDue: Bool

    @Environment(\.isLuminanceReduced) private var isLuminanceReduced: Bool

    private var tint: Color { isLuminanceReduced ? .secondary : kind.color }

    var body: some View {
        Group {
            if isDue {
                ProgressView(value: 1) { symbol }
            } else {
                ProgressView(timerInterval: lastFedAt...nextFeedingAt, countsDown: false) {
                    symbol
                } currentValueLabel: {
                    symbol
                }
            }
        }
        .progressViewStyle(.circular)
        .tint(tint)
        .accessibilityHidden(true)
    }

    private var symbol: some View {
        Image(systemName: kind.symbolName)
            .foregroundStyle(tint)
    }
}
