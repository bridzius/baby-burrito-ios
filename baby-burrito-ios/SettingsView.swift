import BabyCore
import SwiftData
import SwiftUI

// Every valid change saves at once, like the system Settings app; an invalid one shows why.
struct SettingsView: View {
    let localBaby: LocalBaby
    let feedingStore: FeedingStore

    @Query(Self.earliestFeedingDescriptor) private var earliestFeedings: [LocalFeeding]
    @State private var baby: Baby
    @State private var isConfirmingDeletion: Bool = false
    @State private var isShowingSaveFailure: Bool = false

    init(localBaby: LocalBaby, feedingStore: FeedingStore) {
        self.localBaby    = localBaby
        self.feedingStore = feedingStore
        _baby             = State(initialValue: localBaby.baby)
    }

    static var earliestFeedingDescriptor: FetchDescriptor<LocalFeeding> {
        var descriptor: FetchDescriptor<LocalFeeding> = FetchDescriptor(
            sortBy: [SortDescriptor(\.fedAt)]
        )
        descriptor.fetchLimit = 1
        return descriptor
    }

    private var earliestFedAt: Date? { earliestFeedings.first?.fedAt }

    private var trimmedBaby: Baby {
        var trimmed: Baby = baby
        trimmed.name      = baby.name.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed
    }

    private var invalidReason: String? {
        do {
            _ = try trimmedBaby.validated(
                calendar:      .autoupdatingCurrent,
                earliestFedAt: earliestFedAt
            )
            return nil
        } catch {
            return error.reason
        }
    }

    var body: some View {
        Form {
            BabyDetailsSection(
                baby:          $baby,
                earliestFedAt: earliestFedAt,
                invalidReason: invalidReason
            )

            Section {
                Button("Delete all data", role: .destructive) {
                    isConfirmingDeletion = true
                }
            }
        }
        .navigationTitle("Settings")
        .onChange(of: baby, saveBaby)
        .confirmationDialog(
            "Delete all data?",
            isPresented:     $isConfirmingDeletion,
            titleVisibility: .visible
        ) {
            Button("Delete all data", role: .destructive, action: deleteEverything)
        } message: {
            Text("Deletes \(baby.name)'s log and every feeding from this phone.")
        }
        .alert("Couldn't save. Try again.", isPresented: $isShowingSaveFailure) {}
    }

    private func saveBaby() {
        guard invalidReason == nil else { return }
        do {
            try feedingStore.updateBaby(localBaby, to: trimmedBaby)
        } catch {
            isShowingSaveFailure = true
        }
    }

    private func deleteEverything() {
        do {
            try feedingStore.deleteEverything()
        } catch {
            isShowingSaveFailure = true
        }
    }
}
