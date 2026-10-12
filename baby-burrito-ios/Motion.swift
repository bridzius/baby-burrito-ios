import SwiftUI

extension Animation {
    static let crossFade: Animation = .easeInOut(duration: 0.2)

    static func spring(reducingMotion: Bool) -> Animation {
        reducingMotion ? crossFade : .spring
    }
}

extension View {
    func transition(_ transition: AnyTransition, crossFadingWhen reduceMotion: Bool) -> some View {
        self.transition(reduceMotion ? .opacity : transition)
    }

    func symbolEffectsFollowReduceMotion() -> some View {
        modifier(SymbolEffectsFollowReduceMotion())
    }
}

private struct SymbolEffectsFollowReduceMotion: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion: Bool

    func body(content: Content) -> some View {
        content.symbolEffectsRemoved(reduceMotion)
    }
}
