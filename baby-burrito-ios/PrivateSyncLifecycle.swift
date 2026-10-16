import BabyCore
import os
import SwiftUI

extension View {
    // Starts private sync after the first frame and fetches on every return to the foreground
    // and on pull-to-refresh. Nil in UI tests, which never touch CloudKit.
    func privateSync(_ privateSync: PrivateSync?) -> some View {
        modifier(PrivateSyncLifecycle(privateSync: privateSync))
    }
}

private struct PrivateSyncLifecycle: ViewModifier {
    static let logger: Logger = Logger(subsystem: "com.bridzius.babyburrito", category: "Sync")

    let privateSync: PrivateSync?

    @Environment(\.scenePhase) private var scenePhase: ScenePhase

    func body(content: Content) -> some View {
        if let privateSync {
            content
                .task(id: scenePhase) {
                    guard scenePhase == .active else { return }
                    await startAndFetch(privateSync)
                }
                .refreshable {
                    await startAndFetch(privateSync)
                }
        } else {
            content
        }
    }

    // Offline or signed out, the fetch fails and the engine retries by itself, so the
    // failure is only logged; the app keeps working locally.
    private func startAndFetch(_ privateSync: PrivateSync) async {
        do {
            try privateSync.start()
            try await privateSync.fetchChanges()
        } catch {
            PrivateSyncLifecycle.logger.error("Private sync fetch failed: \(error)")
        }
    }
}
