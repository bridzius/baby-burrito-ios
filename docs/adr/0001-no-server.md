# No server, including no push relay

All data lives on the phones and in the parents' own iCloud (CloudKit, end-to-end encrypted
fields), so the developer never holds user data and there are no accounts. The cost is that the
other parent's Live Activity updates only when CloudKit's silent push wakes the app, which iOS
throttles and doesn't guarantee. An APNs relay would fix that, but it brings back a server and
exposes feeding times to it, so we accept the lag. Revisit only if the lag bothers the parents in
daily use.
