#if DEBUG
import CloudKit
import SwiftUI
import UIKit

// Shares arrive through the scene delegate: on a cold launch in the connection options,
// otherwise in windowScene(_:userDidAcceptCloudKitShareWith:).
final class SharingSpikeAppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application:                   UIApplication,
        configurationForConnecting session: UISceneSession,
        options:                         UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        let configuration: UISceneConfiguration = UISceneConfiguration(
            name: nil, sessionRole: session.role
        )
        configuration.delegateClass = SharingSpikeSceneDelegate.self
        return configuration
    }
}

final class SharingSpikeSceneDelegate: NSObject, UIWindowSceneDelegate {
    func scene(
        _ scene:            UIScene,
        willConnectTo session: UISceneSession,
        options:            UIScene.ConnectionOptions
    ) {
        guard let metadata = options.cloudKitShareMetadata else { return }
        Task { @MainActor in await SharingSpike.shared.accept(metadata) }
    }

    func windowScene(
        _ windowScene:                         UIWindowScene,
        userDidAcceptCloudKitShareWith metadata: CKShare.Metadata
    ) {
        Task { @MainActor in await SharingSpike.shared.accept(metadata) }
    }
}
#endif
