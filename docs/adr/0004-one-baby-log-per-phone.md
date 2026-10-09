# One baby log per phone in v1

The storage is multi-baby (one CloudKit zone per baby, `zone=` in deep links), but in v1 a phone
holds exactly one baby log, owned or shared, which removes the switcher, selection state and their
edge cases. Accepting an invite while owning a log asks to replace it, and the owned log is
deleted; feedings are never merged, because merging creates duplicates for little gain (the usual
case is a few test feedings). A title-menu switcher can be added later without a schema change.
