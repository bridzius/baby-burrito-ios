import BabyCore
import SwiftUI

private struct KindSwatches: View {
    let sampleAmount: String = "90 ml"

    var body: some View {
        List(FeedingKind.allCases, id: \.self) { kind in
            HStack {
                Label {
                    Text(kind.name)
                } icon: {
                    Image(systemName: kind.symbolName)
                }
                Spacer()
                Text(verbatim: sampleAmount)
                    .numerals(.title3)
            }
            .foregroundStyle(kind.color)
        }
    }
}

#Preview("Kinds, light") {
    KindSwatches()
        .preferredColorScheme(.light)
}

#Preview("Kinds, dark") {
    KindSwatches()
        .preferredColorScheme(.dark)
}
