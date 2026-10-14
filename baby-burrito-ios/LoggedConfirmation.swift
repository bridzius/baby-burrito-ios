import BabyCore
import SwiftUI

// The Log sheet right after a one-tap log. Every valid change edits that same feeding, Undo
// takes it back, and it closes itself after a quiet spell so a parent can put the phone down.
struct LoggedConfirmation: View {
    static let idleTimeout: Duration = .seconds(8)
    static let undoHeight: CGFloat   = 60

    let birthDate: Date
    let update: (_ fedAt: Date, _ details: FeedingDetails) throws -> Void
    let undo: () -> Void

    @State var draft: LogSheetDraft
    @State private var lastInteraction: Int       = 0
    @State private var hasAppeared: Bool          = false
    @State private var isShowingSaveFailure: Bool = false
    @Environment(\.dismiss) private var dismiss: DismissAction

    var body: some View {
        NavigationStack {
            Form {
                FeedingFields(draft: $draft, birthDate: birthDate)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    title
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done", role: .confirm) { dismiss() }
                }
            }
            .safeAreaInset(edge: .bottom) {
                Button(action: undo) {
                    Text("Undo")
                        .font(.title3.weight(.semibold))
                        .frame(maxWidth: .infinity, minHeight: Self.undoHeight)
                }
                .buttonStyle(.glass)
                .padding()
            }
            .onChange(of: draft.details) { saveChange() }
            .onChange(of: draft.fedAt) { saveChange() }
            .simultaneousGesture(DragGesture(minimumDistance: 0).onChanged { _ in
                lastInteraction += 1
            })
            .task(id: lastInteraction) {
                do {
                    try await Task.sleep(for: Self.idleTimeout)
                } catch {
                    return
                }
                dismiss()
            }
            .onAppear {
                hasAppeared = true
                announceLogged()
            }
            .alert("Couldn't save. Try again.", isPresented: $isShowingSaveFailure) {}
        }
        .presentationDetents([.medium, .large])
    }

    private var title: some View {
        HStack(spacing: 6) {
            Image(systemName: draft.kind.symbolName)
                .foregroundStyle(draft.kind.color)
                .symbolEffect(.bounce, value: hasAppeared)
            Text("Logged \(draft.fedAt, format: .dateTime.hour().minute())")
                .font(.headline)
        }
        .accessibilityElement(children: .combine)
    }

    private func announceLogged() {
        let time: String = draft.fedAt.formatted(date: .omitted, time: .shortened)
        AccessibilityNotification.Announcement(
            String(localized: "Logged \(String(localized: draft.kind.name)) at \(time)")
        ).post()
    }

    private func saveChange() {
        lastInteraction += 1
        guard draft.invalidReason(birthDate: birthDate, now: .now) == nil else { return }
        do {
            try update(draft.fedAt, draft.details)
        } catch {
            isShowingSaveFailure = true
        }
    }
}
