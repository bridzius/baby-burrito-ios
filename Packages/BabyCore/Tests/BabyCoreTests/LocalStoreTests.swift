import BabyCore
import Foundation
import SwiftData
import Testing

@MainActor
struct LocalStoreTests {
    @Test func the_widget_extension_reads_the_apps_store_without_writing() throws {
        let directory: URL = FileManager.default.temporaryDirectory
            .appending(path: UUID().uuidString, directoryHint: .isDirectory)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let storeURL: URL = directory.appending(path: LocalStore.storeFileName)

        let appContainer: ModelContainer = try LocalStore.container(at: storeURL, readOnly: false)
        let store: FeedingStore = FeedingStore(
            modelContext: appContainer.mainContext,
            syncQueue:    NoSyncQueue(),
            calendar:     .vilnius,
            now:          { .vilnius(2026, 4, 2, hour: 9) }
        )
        _ = try store.createBaby(.ona)
        _ = try store.log(fedAt: .vilnius(2026, 4, 2, hour: 8), details: .formula90)

        let widgetContainer: ModelContainer = try LocalStore.container(at: storeURL, readOnly: true)
        let widgetContext: ModelContext     = widgetContainer.mainContext

        #expect(try widgetContext.fetch(FetchDescriptor<LocalBaby>()).map(\.baby) == [.ona])
        #expect(try widgetContext.fetchCount(FetchDescriptor<LocalFeeding>()) == 1)

        let widgetStore: FeedingStore = FeedingStore(
            modelContext: widgetContext,
            syncQueue:    NoSyncQueue(),
            calendar:     .vilnius,
            now:          { .vilnius(2026, 4, 2, hour: 9) }
        )
        #expect(throws: (any Error).self) {
            try widgetStore.log(fedAt: .vilnius(2026, 4, 2, hour: 9), details: .formula90)
        }
        #expect(try widgetContext.fetch(FetchDescriptor<LocalFeeding>()).count == 1)
    }
}
