import BabyCore
import SwiftUI

// No system view draws a circular timer ring inside an app (a circular
// ProgressView(timerInterval:) shows a spinner), so the parent's minute schedule moves the gauge
// and it animates between values.
struct FeedingRing: View {
    static let diameter: CGFloat = 72

    let kind: FeedingKind
    let fractionElapsed: Double
    let isPulsing: Bool

    var body: some View {
        Gauge(value: fractionElapsed) {
            Image(systemName: kind.symbolName)
                .foregroundStyle(kind.color)
                .symbolEffect(.pulse, isActive: isPulsing)
        }
        .gaugeStyle(.accessoryCircularCapacity)
        .tint(kind.color)
        .animation(.linear, value: fractionElapsed)
        .frame(width: Self.diameter, height: Self.diameter)
        .accessibilityHidden(true)
    }
}
