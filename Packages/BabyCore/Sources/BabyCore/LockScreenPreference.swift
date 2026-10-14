import Foundation

// "Show on Lock Screen": per phone, in the App Group so the widget extension could read it,
// and never synced.
public enum LockScreenPreference {
    public static let key: String = "showOnLockScreen"

    public static var defaults: UserDefaults {
        guard let defaults = UserDefaults(suiteName: LocalStore.appGroupIdentifier) else {
            preconditionFailure("The App Group \(LocalStore.appGroupIdentifier) has no defaults")
        }
        return defaults
    }
}
