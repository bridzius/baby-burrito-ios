import BabyCore
import SwiftUI

// "Last 14:05 · Nursing · left · 15 min · Dad"; the author only when someone else logged it.
struct LastFeedingLine: View {
    let content: FeedingActivityContent

    var body: some View {
        if let lastFedAt = content.lastFedAt, let details = content.lastDetails {
            let time: Text     = Text(lastFedAt, format: .dateTime.hour().minute())
            let author: String = content.lastLoggedBy
                .map { FeedingDetails.summarySeparator + $0 } ?? ""
            Text("Last \(time) · \(details.summary)\(author)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
    }
}
