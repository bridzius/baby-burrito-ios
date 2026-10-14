import BabyCore
import SwiftUI
import WidgetKit

// Opens the app and never logs: it is reachable without Face ID (ADR 0002).
struct FeedingWidget: Widget {
    static let kind: String = "FeedingWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: Self.kind, provider: FeedingWidgetProvider()) { entry in
            FeedingWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
                .widgetURL(DeepLink.today.url)
        }
        .configurationDisplayName("Next feeding")
        .description("The countdown to the next feeding and the last feeding.")
        .supportedFamilies([.systemSmall, .systemMedium])
        .contentMarginsDisabled()
    }
}

struct FeedingWidgetView: View {
    let entry: FeedingWidgetEntry

    @Environment(\.widgetFamily) private var widgetFamily: WidgetFamily

    var body: some View {
        if let babyName = entry.babyName {
            switch widgetFamily {
            case .systemSmall:
                ActivitySmartStackView(content: entry.content, isDue: entry.isDue)
                    .padding()
            default:
                ActivityLockScreenView(
                    babyName:  babyName,
                    content:   entry.content,
                    canLog:    false,
                    isDue:     entry.isDue,
                    showsRing: true
                )
            }
        } else {
            Text("Open Baby Burrito to get started")
                .font(.headline)
                .padding()
        }
    }
}
