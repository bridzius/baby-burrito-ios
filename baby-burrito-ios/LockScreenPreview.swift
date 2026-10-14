import BabyCore
import SwiftUI

// The Live Activity's Lock Screen view, framed the way it shows on the Lock Screen.
struct LockScreenPreview: View {
    static let cornerRadius: CGFloat = 24

    let babyName: String
    let content: FeedingActivityContent

    var body: some View {
        ActivityLockScreenView(
            babyName:  babyName,
            content:   content,
            canLog:    true,
            isDue:     false,
            showsRing: false
        )
            .background(.fill.tertiary, in: RoundedRectangle(cornerRadius: Self.cornerRadius))
            .accessibilityElement(children: .combine)
            .accessibilityLabel(Text("Lock Screen preview"))
    }
}
