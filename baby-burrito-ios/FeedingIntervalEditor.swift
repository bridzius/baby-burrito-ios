import SwiftUI

struct FeedingIntervalEditor: View {
    let saveFeedingInterval: (Int) throws -> Void

    @State var feedingIntervalMinutes: Int
    @State private var isShowingSaveFailure: Bool = false
    @Environment(\.dismiss) private var dismiss: DismissAction

    var body: some View {
        NavigationStack {
            Form {
                FeedingIntervalPicker(feedingIntervalMinutes: $feedingIntervalMinutes)
            }
            .navigationTitle("Feeding interval")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done", role: .confirm, action: save)
                }
            }
            .alert("Couldn't save. Try again.", isPresented: $isShowingSaveFailure) {}
        }
        .presentationDetents([.medium])
    }

    private func save() {
        do {
            try saveFeedingInterval(feedingIntervalMinutes)
            dismiss()
        } catch {
            isShowingSaveFailure = true
        }
    }
}
