# Sync with CKSyncEngine and a zone-wide share, not SwiftData's CloudKit sync

SwiftData on iOS 27 still syncs only to the private database: `ModelConfiguration.CloudKitDatabase`
offers `.automatic`, `.none` and `.private(_:)`, with no shared scope and no `CKShare` API
(checked in the iOS 27.0 SDK's SwiftData interface, the WWDC26 SwiftData group lab and the iOS 27
SwiftData changes). The other parent must see the owner's baby log, so we keep SwiftData as a
local-only store (`cloudKitDatabase: .none`) and sync it with one `CKSyncEngine` per database,
sharing each baby log's zone as a whole through `CKShare(recordZoneID:)`. Core Data's
`NSPersistentCloudKitContainer` can share too, but per object graph and opaquely; with about ten
small records a day, owning the record mapping and conflict rule costs little. Revisit when
SwiftData gains a shared database scope, which could remove the sync layer.
