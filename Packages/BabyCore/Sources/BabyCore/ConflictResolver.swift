import Foundation

public enum ConflictResolution: Equatable, Sendable {
    case keepServer
    case resendLocal
    case keepLocalDeletion
}

// Last writer wins by clientModifiedAt; a tie goes to the server, so both phones agree.
public enum ConflictResolver {
    public static func resolve(
        localModifiedAt:  Date?,
        serverModifiedAt: Date
    ) -> ConflictResolution {
        guard let localModifiedAt else { return .keepLocalDeletion }
        return localModifiedAt > serverModifiedAt ? .resendLocal : .keepServer
    }
}
