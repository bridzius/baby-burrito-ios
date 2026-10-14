import BabyCore
import SwiftUI

struct LogSheet: View {
    let title: LocalizedStringKey
    let birthDate: Date
    let save: (_ fedAt: Date, _ details: FeedingDetails) throws -> Void

    @State var draft: LogSheetDraft
    @State private var isShowingSaveFailure: Bool = false
    @Environment(\.dismiss) private var dismiss: DismissAction

    var body: some View {
        NavigationStack {
            Form {
                FeedingFields(draft: $draft, birthDate: birthDate)
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done", role: .confirm, action: saveDraft)
                        .disabled(draft.invalidReason(birthDate: birthDate, now: .now) != nil)
                }
            }
            .onChange(of: draft.details) {
                draft.refreshDefaultFedAt(now: .now)
            }
            .alert("Couldn't save. Try again.", isPresented: $isShowingSaveFailure) {}
        }
        .presentationDetents([.medium, .large])
    }

    private func saveDraft() {
        do {
            try save(draft.fedAt, draft.details)
            dismiss()
        } catch {
            isShowingSaveFailure = true
        }
    }
}
