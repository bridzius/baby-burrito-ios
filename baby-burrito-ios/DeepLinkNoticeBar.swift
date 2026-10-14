import BabyCore
import SwiftUI

struct DeepLinkNoticeBar: View {
    let notice: DeepLinkRoute.Notice

    private var text: LocalizedStringKey {
        switch notice {
        case .babyNotOnThisPhone: "That baby is no longer on this phone"
        }
    }

    var body: some View {
        Text(text)
            .font(.footnote)
            .foregroundStyle(.secondary)
            .padding(.horizontal)
            .padding(.vertical, 8)
            .glassEffect()
            .padding()
    }
}
