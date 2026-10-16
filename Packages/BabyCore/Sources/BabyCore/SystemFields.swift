import CloudKit
import Foundation

// A record's system fields carry its change tag; sending a record without them makes
// CloudKit treat it as new and report a conflict with the stored one.
enum SystemFields {
    static func encoded(_ record: CKRecord) -> Data {
        let archiver: NSKeyedArchiver = NSKeyedArchiver(requiringSecureCoding: true)
        record.encodeSystemFields(with: archiver)
        archiver.finishEncoding()
        return archiver.encodedData
    }

    static func record(from data: Data?) throws -> CKRecord? {
        guard let data else { return nil }
        let unarchiver: NSKeyedUnarchiver = try NSKeyedUnarchiver(forReadingFrom: data)
        unarchiver.requiresSecureCoding   = true
        defer { unarchiver.finishDecoding() }
        guard let record = CKRecord(coder: unarchiver) else {
            throw SyncError.unreadableSystemFields
        }
        return record
    }
}
