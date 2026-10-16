import Foundation
import SwiftData

public enum LocalStore {
    public static let appGroupIdentifier: String = "group.com.bridzius.babyburrito"
    public static let storeFileName: String      = "BabyBurrito.store"

    static var schema: Schema { Schema([LocalBaby.self, LocalFeeding.self, LocalWeighing.self]) }

    public static func appGroupStoreURL() -> URL {
        let fileManager: FileManager = .default
        guard let groupURL = fileManager.containerURL(
            forSecurityApplicationGroupIdentifier: appGroupIdentifier
        ) else {
            preconditionFailure("The entitlements lack the App Group \(appGroupIdentifier)")
        }
        return groupURL.appending(path: storeFileName)
    }

    public static func container(at url: URL, readOnly: Bool) throws -> ModelContainer {
        let configuration: ModelConfiguration = ModelConfiguration(
            schema:           schema,
            url:              url,
            allowsSave:       !readOnly,
            cloudKitDatabase: .none
        )
        return try ModelContainer(for: schema, configurations: configuration)
    }

    public static func inMemoryContainer() throws -> ModelContainer {
        let configuration: ModelConfiguration = ModelConfiguration(
            schema:              schema,
            isStoredInMemoryOnly: true,
            cloudKitDatabase:    .none
        )
        return try ModelContainer(for: schema, configurations: configuration)
    }
}
