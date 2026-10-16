import Foundation
import Testing
@testable import BabyCore

struct SyncStateStoreTests {
    @Test func a_missing_state_file_means_a_first_start() throws {
        let store: SyncStateStore = SyncStateStore(
            fileURL: .temporaryDirectory.appending(path: "\(UUID()).json")
        )

        #expect(try store.load() == nil)
    }
}
