import BabyCore
import SwiftUI

struct QuickLogBar: View {
    static let buttonHeight: CGFloat    = 60
    static let repeatIdentifier: String = "repeatButton"

    let nextRepeat: FeedingDetails?
    let repeatLast: () -> Void
    let openLogSheet: () -> Void

    var body: some View {
        GlassEffectContainer {
            HStack(spacing: 12) {
                if let nextRepeat {
                    Button(action: repeatLast) {
                        Label(Self.title(of: nextRepeat), systemImage: "arrow.clockwise")
                            .font(.headline)
                            .monospacedDigit()
                            .frame(maxWidth: .infinity, minHeight: Self.buttonHeight)
                    }
                    .buttonStyle(.glassProminent)
                    .accessibilityLabel(Text("Repeat \(Self.title(of: nextRepeat))"))
                    .accessibilityIdentifier(Self.repeatIdentifier)
                }

                Button(action: openLogSheet) {
                    Label("Log feeding", systemImage: "plus")
                        .labelStyle(.iconOnly)
                        .font(.title2.weight(.semibold))
                        .frame(width: Self.buttonHeight, height: Self.buttonHeight)
                }
                .buttonStyle(.glass)
            }
        }
        .padding(.horizontal)
    }

    // "Right · 15 min" for a nursing, "Formula · 90 mL" for a bottle.
    static func title(of details: FeedingDetails) -> String {
        let separator: String = FeedingDetails.summarySeparator
        if let amountMl = details.amountMl {
            return String(localized: details.kind.name) + separator + amountMl.formattedMillilitres
        }
        let side: String     = details.side.map { String(localized: $0.title) } ?? ""
        let duration: String = details.durationMinutes.map {
            Duration.minutes($0).formatted(.hoursAndMinutes)
        } ?? ""
        return [side, duration].filter { !$0.isEmpty }.joined(separator: separator)
    }
}
