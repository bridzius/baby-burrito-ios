#if DEBUG
import CloudKit
import SwiftUI
import UIKit

struct SharingSpikeView: View {
    @State private var spike: SharingSpike = .shared
    @State private var isShowingShareSheet: Bool = false

    var body: some View {
        List {
            Section("Owner (phone A)") {
                Button("1. Create zone and share") { Task { await spike.createSharedZone() } }
                Button("2. Invite") { isShowingShareSheet = true }
                    .disabled(spike.share == nil)
                Button("4. Save a test feeding") { Task { await spike.saveTestFeeding() } }
            }
            Section("Participant (phone B)") {
                Text("3. Open the invite link on this phone; the app accepts it and fetches.")
                Button("5. Fetch changes") { Task { await spike.fetchSharedChanges() } }
                Button("Start the shared engine") { spike.startSharedEngine() }
            }
            Section("Log") {
                ForEach(Array(spike.logLines.enumerated()), id: \.offset) { _, line in
                    Text(line).font(.caption.monospaced()).textSelection(.enabled)
                }
            }
        }
        .navigationTitle("Sharing spike")
        .sheet(isPresented: $isShowingShareSheet) {
            if let share = spike.share {
                CloudSharingView(share: share, container: spike.container)
            }
        }
    }
}

private struct CloudSharingView: UIViewControllerRepresentable {
    let share: CKShare
    let container: CKContainer

    func makeUIViewController(context: Context) -> UICloudSharingController {
        let controller: UICloudSharingController = UICloudSharingController(
            share: share, container: container
        )
        controller.availablePermissions = [.allowPrivate, .allowReadOnly, .allowReadWrite]
        return controller
    }

    func updateUIViewController(_ controller: UICloudSharingController, context: Context) {}
}
#endif
