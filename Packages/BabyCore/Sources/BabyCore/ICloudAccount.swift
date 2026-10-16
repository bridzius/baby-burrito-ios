import CloudKit

public enum ICloudAccount: Equatable, Sendable {
    case available
    case signedOut
    case restricted
    case unavailable

    public var needsAttention: Bool { self != .available }

    init(_ status: CKAccountStatus) {
        switch status {
        case .available:                                   self = .available
        case .noAccount:                                   self = .signedOut
        case .restricted:                                  self = .restricted
        case .couldNotDetermine, .temporarilyUnavailable:  self = .unavailable
        @unknown default:                                  self = .unavailable
        }
    }
}
