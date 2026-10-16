import BabyCore
import SwiftUI

extension EnvironmentValues {
    // Nil until private sync has asked, and always in previews and UI tests.
    @Entry var iCloudAccount: ICloudAccount? = nil
}
