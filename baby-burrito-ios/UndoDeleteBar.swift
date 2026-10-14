import SwiftUI

struct UndoDeleteBar: View {
    let undo: () -> Void

    var body: some View {
        HStack {
            Text("Feeding deleted")
            Spacer()
            Button("Undo", action: undo)
                .buttonStyle(.glassProminent)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .glassEffect()
        .padding()
    }
}
