import BabyCore
import SwiftUI

struct KindPicker: View {
    static let minimumTapHeight: CGFloat = 44
    static let highlightOpacity: Double  = 0.15
    static let highlightID: String       = "selectedKind"

    @Binding var kind: FeedingKind

    @Namespace private var highlight: Namespace.ID
    @Environment(\.accessibilityReduceMotion) private var reduceMotion: Bool

    var body: some View {
        HStack(spacing: 4) {
            ForEach(FeedingKind.allCases, id: \.self) { option in
                Button {
                    withAnimation(.spring(reducingMotion: reduceMotion)) { kind = option }
                } label: {
                    Label {
                        Text(option.name)
                    } icon: {
                        Image(systemName: option.symbolName)
                    }
                    .labelStyle(.titleOnly)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(option == kind ? option.color : .secondary)
                    .frame(maxWidth: .infinity, minHeight: Self.minimumTapHeight)
                    .background {
                        if option == kind {
                            Capsule()
                                .fill(option.color.opacity(Self.highlightOpacity))
                                .matchedGeometryEffect(id: Self.highlightID, in: highlight)
                        }
                    }
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(option == kind ? .isSelected : [])
            }
        }
        .padding(4)
        .background(Capsule().fill(.quaternary))
    }
}
