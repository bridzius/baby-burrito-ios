import BabyCore
import OSLog
import SwiftUI
import WidgetKit

extension View {
    // Keeps the Live Activity and the Home Screen widget in step with the baby, the last
    // feeding, the preference and whether the app is in the foreground.
    func liveActivityRefresh(
        baby:        LocalBaby,
        lastFeeding: Feeding?,
        canLog:      Bool,
        controller:  FeedingActivityController
    ) -> some View {
        modifier(LiveActivityRefresh(
            baby:        baby,
            lastFeeding: lastFeeding,
            canLog:      canLog,
            controller:  controller
        ))
    }
}

private struct LiveActivityRefresh: ViewModifier {
    static let logger: Logger = Logger(subsystem: "com.bridzius.babyburrito", category: "activity")

    let baby: LocalBaby
    let lastFeeding: Feeding?
    let canLog: Bool
    let controller: FeedingActivityController

    @AppStorage(LockScreenPreference.key, store: LockScreenPreference.defaults)
    private var isPreferenceOn: Bool = false
    @Environment(\.scenePhase) private var scenePhase: ScenePhase

    private var desired: FeedingActivityState {
        FeedingActivityState(
            attributes: FeedingActivityAttributes(
                babyName: baby.name,
                zoneName: baby.zoneName,
                canLog:   canLog
            ),
            content:    FeedingActivityContent(
                lastFeeding:            lastFeeding,
                feedingIntervalMinutes: baby.feedingIntervalMinutes,
                lastLoggedBy:           nil
            )
        )
    }

    func body(content: Content) -> some View {
        let input: RefreshInput = RefreshInput(
            desired:        desired,
            isPreferenceOn: isPreferenceOn,
            isForeground:   scenePhase == .active
        )
        content
            .task(id: input) {
                await refresh(input)
            }
            .onChange(of: input.desired) {
                WidgetCenter.shared.reloadAllTimelines()
            }
    }

    // A refused start means Live Activities are off for the app; Settings explains that.
    private func refresh(_ input: RefreshInput) async {
        do {
            try await controller.refresh(
                to:             input.desired,
                isPreferenceOn: input.isPreferenceOn,
                isForeground:   input.isForeground
            )
        } catch {
            Self.logger.error("The Live Activity didn't start: \(error)")
        }
    }
}

private struct RefreshInput: Equatable {
    let desired: FeedingActivityState
    let isPreferenceOn: Bool
    let isForeground: Bool
}
