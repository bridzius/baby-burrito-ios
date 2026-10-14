import BabyCore
import SwiftUI

struct FirstRunView: View {
    static let defaultFeedingIntervalMinutes: Int = 180
    static let earliestBirthDate: Date            = Calendar.autoupdatingCurrent.date(
        from: Baby.earliestBirthDay
    ) ?? .distantPast

    let createBaby: (Baby) throws -> Void

    @State private var name: String                = ""
    @State private var birthDate: Date?
    @State private var feedingIntervalMinutes: Int = Self.defaultFeedingIntervalMinutes
    @State private var pendingBaby: Baby?

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name", text: $name)
                        .textContentType(.givenName)
                }

                Section("Birth date") {
                    birthDateRow
                }

                Section {
                    FeedingIntervalPicker(feedingIntervalMinutes: $feedingIntervalMinutes)
                } header: {
                    Text("Feeding interval")
                } footer: {
                    Text("Joining your partner's log? Open their invite link.")
                }
            }
            .navigationTitle("Your baby")
            .safeAreaInset(edge: .bottom) {
                continueBar
            }
            .navigationDestination(item: $pendingBaby) { baby in
                LockScreenStep(baby: baby, createBaby: createBaby)
            }
        }
    }

    @ViewBuilder
    private var birthDateRow: some View {
        if let birthDate {
            DatePicker(
                "Birth date",
                selection:           Binding { birthDate } set: { self.birthDate = $0 },
                in:                  Self.earliestBirthDate...Date.now,
                displayedComponents: .date
            )
        } else {
            Button("Choose the birth date") {
                birthDate = .now
            }
        }
    }

    private var continueBar: some View {
        VStack(spacing: 8) {
            if let invalidReason {
                Text(invalidReason)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Button("Continue", action: continueToLockScreen)
                .buttonStyle(.glassProminent)
                .controlSize(.large)
                .disabled(invalidReason != nil)
        }
        .padding()
    }

    private func baby(birthDate: Date) -> Baby {
        Baby(
            name:                   name.trimmingCharacters(in: .whitespacesAndNewlines),
            birthDate:              Calendar.autoupdatingCurrent.startOfDay(for: birthDate),
            feedingIntervalMinutes: feedingIntervalMinutes
        )
    }

    private var invalidReason: String? {
        do {
            _ = try baby(birthDate: birthDate ?? .now)
                .validated(calendar: .autoupdatingCurrent, earliestFedAt: nil)
        } catch {
            return error.reason
        }
        return birthDate == nil ? String(localized: "Choose the birth date to continue.") : nil
    }

    private func continueToLockScreen() {
        guard let birthDate else {
            preconditionFailure("Continue is disabled without a birth date")
        }
        pendingBaby = baby(birthDate: birthDate)
    }
}

#Preview {
    FirstRunView { _ in }
}
