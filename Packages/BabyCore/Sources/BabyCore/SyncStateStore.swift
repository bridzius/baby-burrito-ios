import CloudKit
import Foundation

// The engine's change tokens and pending changes, kept in Application Support per database.
public struct SyncStateStore: Sendable {
    public static let privateStateFileName: String = "PrivateSyncState.json"

    let fileURL: URL

    public static func privateDatabase() -> SyncStateStore {
        SyncStateStore(fileURL: .applicationSupportDirectory.appending(path: privateStateFileName))
    }

    func load() throws -> CKSyncEngine.State.Serialization? {
        guard FileManager.default.fileExists(atPath: fileURL.path()) else { return nil }
        let encoded: Data = try Data(contentsOf: fileURL)
        return try JSONDecoder().decode(CKSyncEngine.State.Serialization.self, from: encoded)
    }

    func save(_ state: CKSyncEngine.State.Serialization) throws {
        try FileManager.default.createDirectory(
            at:                          fileURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try JSONEncoder().encode(state).write(to: fileURL, options: .atomic)
    }

    func delete() throws {
        guard FileManager.default.fileExists(atPath: fileURL.path()) else { return }
        try FileManager.default.removeItem(at: fileURL)
    }
}
