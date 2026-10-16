import BabyCore
import SwiftData
import SwiftUI

// Every valid change saves at once, like the system Settings app; an invalid one shows why.
struct SettingsView: View {
    let localBaby: LocalBaby
    let lastFeeding: Feeding?
    let feedingStore: FeedingStore

    @Query(Self.earliestFeedingDescriptor) private var earliestFeedings: [LocalFeeding]
    @Query(Self.earliestWeighingDescriptor) private var earliestWeighings: [LocalWeighing]
    @State private var baby: Baby
    @State private var isConfirmingDeletion: Bool = false
    @State private var isShowingSaveFailure: Bool = false
    @Environment(\.iCloudAccount) private var iCloudAccount: ICloudAccount?

    init(localBaby: LocalBaby, lastFeeding: Feeding?, feedingStore: FeedingStore) {
        self.localBaby    = localBaby
        self.lastFeeding  = lastFeeding
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

    static var earliestWeighingDescriptor: FetchDescriptor<LocalWeighing> {
        var descriptor: FetchDescriptor<LocalWeighing> = FetchDescriptor(
            sortBy: [SortDescriptor(\.weighedOn)]
        )
        descriptor.fetchLimit = 1
        return descriptor
    }

    private var earliestFedAt: Date? { earliestFeedings.first?.fedAt }
    private var earliestWeighedOn: Date? { earliestWeighings.first?.weighedOn }

    // The birth date can't move past the first feeding or the first weighing.
    private var latestBirthDate: Date {
        [earliestFedAt, earliestWeighedOn, .now].compactMap { $0 }.min() ?? .now
    }

    private var trimmedBaby: Baby {
        var trimmed: Baby = baby
        trimmed.name      = baby.name.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed
    }

    private var invalidReason: String? {
        do {
            _ = try trimmedBaby.validated(
                calendar:          .autoupdatingCurrent,
                earliestFedAt:     earliestFedAt,
                earliestWeighedOn: earliestWeighedOn
            )
            return nil
        } catch {
            return error.reason
        }
    }

    var body: some View {
        Form {
            ICloudStatusSection(account: iCloudAccount)

            BabyDetailsSection(
                baby:            $baby,
                latestBirthDate: latestBirthDate,
                invalidReason:   invalidReason
            )

            WeightSection(birthDate: localBaby.birthDate, feedingStore: feedingStore)

            LockScreenSection(
                babyName: baby.name,
                content:  FeedingActivityContent(
                    lastFeeding:            lastFeeding,
                    feedingIntervalMinutes: baby.feedingIntervalMinutes,
                    lastLoggedBy:           nil
                )
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
            Text("Deletes \(baby.name)'s log, every feeding and every weighing from this phone.")
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
