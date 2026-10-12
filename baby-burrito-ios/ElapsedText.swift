import SwiftUI

// "1 hr, 5 min ago", rendered and kept current by the system.
struct ElapsedText: View {
    static let fields: Set<Date.ComponentsFormatStyle.Field> = [.hour, .minute]

    let since: Date

    var body: some View {
        let elapsed: Text = Text(
            .currentDate,
            format: .offset(to: since, allowedFields: Self.fields, maxFieldCount: 2, sign: .never)
        )
        Text("\(elapsed) ago")
    }
}
