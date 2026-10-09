# Baby Burrito for iOS

iPhone app (iOS 27 only, Swift 6 strict concurrency, SwiftUI) for logging a baby's feedings. No
server: data lives in SwiftData locally and syncs through the parents' own CloudKit.

## Before you start a ticket

- Read [CONTEXT.md](CONTEXT.md). Use its terms exactly in code, UI copy, tests, commits and PRs
  (`Feeding`, `fedAt`, `Side`, baby log, participant, Today, Trends). When a ticket and the glossary
  disagree, stop and ask in the issue.
- Read the sections of [docs/spec.md](docs/spec.md) and [docs/plan.md](docs/plan.md) the ticket
  links to, and every ADR in [docs/adr/](docs/adr/). ADRs record deliberate choices; keep to them.
- Tickets labelled `hitl` need the human (Apple Developer portal, signing, physical devices).
  Pick up only `afk` tickets.

## Workflow

- One ticket, one branch (`<issue-number>-<slug>`), one PR that says `Closes #<n>`.
- A PR is ready when:
  - `swift test` passes in `Packages/BabyCore`,
  - `xcodebuild build` of the app scheme succeeds, with the tail of its output in the PR body,
  - every acceptance criterion in the ticket is ticked or explicitly marked for a `hitl` check.
- The human reviews and merges. Signing settings (`DEVELOPMENT_TEAM`, bundle IDs, entitlements)
  change only when the ticket says so.
- Write tests first for anything in `Domain`; port Rust test cases by name when a ticket says so.

## Architecture

- **Functional core, imperative shell.** `Domain` holds pure functions over value types and imports
  Foundation only. I/O (SwiftData, CloudKit, ActivityKit) lives in `BabyCore` and the app.
- Views read with `@Query` and write only through `FeedingStore`. Views never touch CloudKit.
- Pieces connect by passing explicit values. A function takes exactly the few inputs it needs, never
  a shared context object.
- Build the concrete thing the ticket asks for. Generalize on the second real use.
- Apple frameworks only. System components draw all glass; content sits on the plain background.
- Every user-facing string goes in the String Catalog.

## Code style

- **Names** say exactly what a value holds or a function does (`nextFeedingAt`, not `date`).
- **Functions** do one thing, in as few lines as the logic needs, and exit early with `guard`.
- **Constants** are named (`maximumNursingMinutes = 120`), never bare numbers or strings.
- **Types** are explicit on every declaration that isn't a local with an obvious literal.
- **Errors** fail fast: typed errors that propagate, or `preconditionFailure` for programmer
  errors. Every `catch` handles or rethrows.
- **Comments** only for what code can't say: a workaround, an Apple bug, a "why not the obvious way".
- **Formatting**: lines up to 100 characters, a blank line between logical blocks, aligned related
  assignments.
- **Files** stay small, one type or one job each. Modules stay flat.
