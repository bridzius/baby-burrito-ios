# Validate only local writes

`Domain` validation runs before the app writes a feeding locally. Records that arrive through sync
are stored as they are, and anything invalid is logged, never dropped. Rejecting them would make two
phones disagree about the same baby log, for example when a newer app version on the other phone
allows wider limits; one odd row is the smaller harm.
