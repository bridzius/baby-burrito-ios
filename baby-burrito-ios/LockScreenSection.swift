import ActivityKit
import BabyCore
import SwiftUI

struct LockScreenSection: View {
    let babyName: String
    let content: FeedingActivityContent

    @AppStorage(LockScreenPreference.key, store: LockScreenPreference.defaults)
    private var isPreferenceOn: Bool = false
    @Environment(\.openURL) private var openURL: OpenURLAction

    private var areActivitiesEnabled: Bool {
        ActivityAuthorizationInfo().areActivitiesEnabled
    }

    var body: some View {
        Section {
            Toggle("Show on Lock Screen", isOn: $isPreferenceOn)
            LockScreenPreview(babyName: babyName, content: content)
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
        } header: {
            Text("Lock Screen")
        } footer: {
            if !areActivitiesEnabled {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Live Activities are off for Baby Burrito. Turn them on in Settings.")
                    Button("Open Settings", action: openSystemSettings)
                }
            }
        }
    }

    private func openSystemSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
            preconditionFailure("The system settings URL is always valid")
        }
        openURL(settingsURL)
    }
}
