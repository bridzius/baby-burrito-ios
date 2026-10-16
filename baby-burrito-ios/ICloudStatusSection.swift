import BabyCore
import SwiftUI

// Shown only when iCloud needs attention; the app keeps working on this phone either way.
struct ICloudStatusSection: View {
    let account: ICloudAccount?

    var body: some View {
        if let account, account.needsAttention {
            Section {
                Label(message(for: account), systemImage: "icloud.slash")
            }
        }
    }

    private func message(for account: ICloudAccount) -> String {
        switch account {
        case .available:
            preconditionFailure("An available account needs no status row")
        case .signedOut:
            String(localized: "Sign in to iCloud to sync and share. Feedings stay on this phone.")
        case .restricted:
            String(localized: "iCloud is restricted on this phone, so feedings stay on it.")
        case .unavailable:
            String(localized: "iCloud isn't available right now. Feedings sync when it's back.")
        }
    }
}

#Preview("Every status") {
    Form {
        ICloudStatusSection(account: .signedOut)
        ICloudStatusSection(account: .restricted)
        ICloudStatusSection(account: .unavailable)
        ICloudStatusSection(account: .available)
        ICloudStatusSection(account: nil)
    }
}
