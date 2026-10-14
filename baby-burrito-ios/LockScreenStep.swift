import BabyCore
import SwiftUI

// First run's second step. Skipping leaves the Live Activity off until Settings turns it on.
struct LockScreenStep: View {
    static let buttonHeight: CGFloat = 60

    let baby: Baby
    let createBaby: (Baby) throws -> Void

    @AppStorage(LockScreenPreference.key, store: LockScreenPreference.defaults)
    private var isPreferenceOn: Bool = false
    @State private var isShowingSaveFailure: Bool = false

    private var emptyContent: FeedingActivityContent {
        FeedingActivityContent(
            lastFeeding:            nil,
            feedingIntervalMinutes: baby.feedingIntervalMinutes,
            lastLoggedBy:           nil
        )
    }

    var body: some View {
        VStack(spacing: 24) {
            Text(
                "See the next feeding on your Lock Screen, in the Dynamic Island and on your watch."
            )
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            LockScreenPreview(babyName: baby.name, content: emptyContent)

            Spacer()

            VStack(spacing: 12) {
                Button {
                    finish(showingOnLockScreen: true)
                } label: {
                    Text("Show on Lock Screen")
                        .font(.headline)
                        .frame(maxWidth: .infinity, minHeight: Self.buttonHeight)
                }
                .buttonStyle(.glassProminent)

                Button("Not now") {
                    finish(showingOnLockScreen: false)
                }
            }
        }
        .padding()
        .navigationTitle("Lock Screen")
        .alert("Couldn't save. Try again.", isPresented: $isShowingSaveFailure) {}
    }

    private func finish(showingOnLockScreen: Bool) {
        isPreferenceOn = showingOnLockScreen
        do {
            try createBaby(baby)
        } catch {
            isShowingSaveFailure = true
        }
    }
}
