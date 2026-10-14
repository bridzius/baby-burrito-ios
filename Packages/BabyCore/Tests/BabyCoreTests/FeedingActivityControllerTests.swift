import BabyCore
import Foundation
import Testing

@MainActor
final class FakeFeedingActivities: FeedingActivities {
    private(set) var running: FeedingActivityState?
    private(set) var calls: [String] = []

    func start(_ state: FeedingActivityState) throws {
        calls.append("start")
        running = state
    }

    func update(to content: FeedingActivityContent) async {
        calls.append("update")
        running?.content = content
    }

    func end() async {
        calls.append("end")
        running = nil
    }
}

@MainActor
struct FeedingActivityControllerTests {
    let activities: FakeFeedingActivities = FakeFeedingActivities()
    let attributes: FeedingActivityAttributes = FeedingActivityAttributes(
        babyName: "Ona", zoneName: "BabyLog-1", canLog: true
    )

    func state(fedAtHour hour: Int) -> FeedingActivityState {
        FeedingActivityState(
            attributes: attributes,
            content:    FeedingActivityContent(
                lastFeeding:            Feeding(
                    id:      UUID(),
                    fedAt:   .vilnius(2026, 4, 2, hour: hour),
                    details: .formula90
                ),
                feedingIntervalMinutes: 180,
                lastLoggedBy:           nil
            )
        )
    }

    func refreshInForeground(
        _ controller:   FeedingActivityController,
        fedAtHour hour: Int
    ) async throws {
        try await controller.refresh(
            to: state(fedAtHour: hour), isPreferenceOn: true, isForeground: true
        )
    }

    @Test func restarts_by_ending_then_starting() async throws {
        let controller: FeedingActivityController = FeedingActivityController(
            activities: activities
        )

        try await refreshInForeground(controller, fedAtHour: 9)
        try await refreshInForeground(controller, fedAtHour: 12)

        #expect(activities.calls == ["start", "end", "start"])
        #expect(activities.running == state(fedAtHour: 12))
    }

    @Test func undo_restores_the_previous_content() async throws {
        let controller: FeedingActivityController = FeedingActivityController(
            activities: activities
        )

        try await refreshInForeground(controller, fedAtHour: 9)
        try await refreshInForeground(controller, fedAtHour: 12)
        try await refreshInForeground(controller, fedAtHour: 9)

        #expect(activities.running == state(fedAtHour: 9))
    }
}
