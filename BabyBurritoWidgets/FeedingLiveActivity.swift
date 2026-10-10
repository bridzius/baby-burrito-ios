import ActivityKit
import SwiftUI
import WidgetKit

// Stand-in until #20 adds FeedingActivityAttributes to BabyCore.
struct PlaceholderActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {}
}

struct FeedingLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: PlaceholderActivityAttributes.self) { _ in
            EmptyView()
        } dynamicIsland: { _ in
            DynamicIsland {
                DynamicIslandExpandedRegion(.center) {
                    EmptyView()
                }
            } compactLeading: {
                EmptyView()
            } compactTrailing: {
                EmptyView()
            } minimal: {
                EmptyView()
            }
        }
    }
}
