import Foundation
import Testing
@testable import BabyCore

struct ConflictResolverTests {
    let serverModifiedAt: Date = .vilnius(2026, 4, 2, hour: 9)

    @Test func a_newer_local_edit_is_sent_again() {
        let resolution: ConflictResolution = ConflictResolver.resolve(
            localModifiedAt:  serverModifiedAt.addingTimeInterval(1),
            serverModifiedAt: serverModifiedAt
        )

        #expect(resolution == .resendLocal)
    }

    @Test func a_newer_server_edit_is_kept() {
        let resolution: ConflictResolution = ConflictResolver.resolve(
            localModifiedAt:  serverModifiedAt.addingTimeInterval(-1),
            serverModifiedAt: serverModifiedAt
        )

        #expect(resolution == .keepServer)
    }

    @Test func equal_timestamps_keep_the_server_version() {
        let resolution: ConflictResolution = ConflictResolver.resolve(
            localModifiedAt:  serverModifiedAt,
            serverModifiedAt: serverModifiedAt
        )

        #expect(resolution == .keepServer)
    }

    @Test func a_row_deleted_here_stays_deleted() {
        let resolution: ConflictResolution = ConflictResolver.resolve(
            localModifiedAt:  nil,
            serverModifiedAt: serverModifiedAt
        )

        #expect(resolution == .keepLocalDeletion)
    }
}
