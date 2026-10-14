import BabyCore
import Foundation
import Testing

struct FeedingActivityDecisionTests {
    let attributes: FeedingActivityAttributes = FeedingActivityAttributes(
        babyName: "Ona", zoneName: "BabyLog-1", canLog: true
    )

    func state(fedAtHour hour: Int?, details: FeedingDetails = .formula90) -> FeedingActivityState {
        let lastFeeding: Feeding? = hour.map {
            Feeding(id: UUID(), fedAt: .vilnius(2026, 4, 2, hour: $0), details: details)
        }
        return FeedingActivityState(
            attributes: attributes,
            content:    FeedingActivityContent(
                lastFeeding:            lastFeeding,
                feedingIntervalMinutes: 180,
                lastLoggedBy:           nil
            )
        )
    }

    func command(
        isPreferenceOn: Bool = true,
        isForeground:   Bool = true,
        running:        FeedingActivityState?,
        desired:        FeedingActivityState
    ) -> FeedingActivityCommand {
        FeedingActivityCommand(
            isPreferenceOn: isPreferenceOn,
            isForeground:   isForeground,
            running:        running,
            desired:        desired
        )
    }

    @Test func starts_in_the_foreground_when_none_runs() {
        #expect(command(running: nil, desired: state(fedAtHour: 9)) == .start)
    }

    @Test func never_starts_from_the_background() {
        #expect(command(isForeground: false, running: nil, desired: state(fedAtHour: 9)) == .none)
    }

    @Test func ends_when_the_preference_is_off() {
        let running: FeedingActivityState = state(fedAtHour: 9)

        #expect(command(isPreferenceOn: false, running: running, desired: running) == .end)
        #expect(command(isPreferenceOn: false, running: nil, desired: running) == .none)
    }

    @Test func leaves_an_unchanged_activity_alone() {
        #expect(command(running: state(fedAtHour: 9), desired: state(fedAtHour: 9)) == .none)
    }

    @Test func restarts_after_a_newer_feeding_is_logged_in_the_foreground() {
        #expect(command(running: state(fedAtHour: 9), desired: state(fedAtHour: 12)) == .restart)
    }

    @Test func restarts_after_the_first_feeding_is_logged() {
        #expect(command(running: state(fedAtHour: nil), desired: state(fedAtHour: 12)) == .restart)
    }

    @Test func updates_after_a_newer_feeding_arrives_in_the_background() {
        let command: FeedingActivityCommand = command(
            isForeground: false, running: state(fedAtHour: 9), desired: state(fedAtHour: 12)
        )

        #expect(command == .update)
    }

    @Test func updates_back_to_the_previous_state_after_an_undo() {
        let beforeRepeat: FeedingActivityState = state(fedAtHour: 9)
        let afterRepeat: FeedingActivityState  = state(fedAtHour: 12)

        #expect(command(running: beforeRepeat, desired: afterRepeat) == .restart)
        #expect(command(running: afterRepeat, desired: beforeRepeat) == .update)
    }

    @Test func updates_after_an_edit_to_the_same_feeding() {
        let edited: FeedingActivityState = state(fedAtHour: 9, details: .nursingLeft)

        #expect(command(running: state(fedAtHour: 9), desired: edited) == .update)
    }

    @Test func restarts_in_the_foreground_when_the_baby_is_renamed() {
        var renamed: FeedingActivityState = state(fedAtHour: 9)
        renamed.attributes.babyName       = "Burrito"

        #expect(command(running: state(fedAtHour: 9), desired: renamed) == .restart)
        #expect(
            command(isForeground: false, running: state(fedAtHour: 9), desired: renamed) == .none
        )
    }
}
