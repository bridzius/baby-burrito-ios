import AppIntents
import SwiftUI
import WidgetKit

// Control Center and the Action button run the same intent as the app's shortcut.
struct LogFeedingControl: ControlWidget {
    static let kind: String = "LogFeedingControl"

    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(kind: Self.kind) {
            ControlWidgetButton(action: LogFeedingIntent()) {
                Label("Log feeding", systemImage: "arrow.clockwise")
            }
        }
        .displayName("Log feeding")
        .description("Repeats the last feeding in Baby Burrito.")
    }
}
