import BabyCore
import SwiftUI

struct SidePicker: View {
    static let halfHeight: CGFloat       = 64
    static let minimumTapHeight: CGFloat = 44
    static let cornerRadius: CGFloat     = 16
    static let highlightOpacity: Double  = 0.18
    static let highlightID: String       = "selectedSide"

    @Binding var side: Side

    @Namespace private var highlight: Namespace.ID
    @Environment(\.accessibilityReduceMotion) private var reduceMotion: Bool

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                half(.left)
                half(.right)
            }
            button(.both)
                .frame(maxWidth: .infinity, minHeight: Self.minimumTapHeight)
        }
    }

    private func half(_ option: Side) -> some View {
        button(option)
            .frame(maxWidth: .infinity, minHeight: Self.halfHeight)
    }

    private func button(_ option: Side) -> some View {
        Button {
            withAnimation(.spring(reducingMotion: reduceMotion)) { side = option }
        } label: {
            Text(option.title)
                .font(.headline)
                .foregroundStyle(option == side ? FeedingKind.nursing.color : .secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background {
                    RoundedRectangle(cornerRadius: Self.cornerRadius)
                        .fill(.quaternary)
                    if option == side {
                        RoundedRectangle(cornerRadius: Self.cornerRadius)
                            .fill(FeedingKind.nursing.color.opacity(Self.highlightOpacity))
                            .matchedGeometryEffect(id: Self.highlightID, in: highlight)
                    }
                }
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(option == side ? .isSelected : [])
    }
}
