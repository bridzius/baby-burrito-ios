import UIKit

// CKSyncEngine subscribes to its database and handles the silent pushes itself; the app only
// has to register for them.
final class RemoteNotificationsAppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application:                 UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        application.registerForRemoteNotifications()
        return true
    }
}
