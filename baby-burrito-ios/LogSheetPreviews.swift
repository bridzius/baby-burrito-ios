import BabyCore
import SwiftData
import SwiftUI

private enum PreviewLogSheet {
    static let birthDaysAgo: TimeInterval = 14 * 86_400
}

@MainActor
private func logSheetPreview() -> some View {
    do {
        let container: ModelContainer = try LocalStore.inMemoryContainer()
        return Color.clear
            .sheet(isPresented: .constant(true)) {
                LogSheet(
                    title:     "Log feeding",
                    birthDate: .now.addingTimeInterval(-PreviewLogSheet.birthDaysAgo),
                    save:      { _, _ in },
                    draft:     .logging(after: nil, now: .now)
                )
            }
            .modelContainer(container)
    } catch {
        preconditionFailure("Preview store failed: \(error)")
    }
}

#Preview("Log sheet") {
    logSheetPreview()
}

#Preview("Log sheet, AX5") {
    logSheetPreview()
        .dynamicTypeSize(.accessibility5)
}
