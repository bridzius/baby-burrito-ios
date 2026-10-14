import AppIntents

struct BabyBurritoShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent:          LogFeedingIntent(),
            phrases:         [
                "Log feeding in \(.applicationName)",
                "Log a feeding with \(.applicationName)",
                "Repeat the last feeding in \(.applicationName)",
            ],
            shortTitle:      "Log feeding",
            systemImageName: "arrow.clockwise"
        )
        AppShortcut(
            intent:          LogBottleIntent(),
            phrases:         [
                "Log a bottle in \(.applicationName)",
                "Log \(\.$kind) in \(.applicationName)",
            ],
            shortTitle:      "Log bottle",
            systemImageName: "drop.fill"
        )
        AppShortcut(
            intent:          LogNursingIntent(),
            phrases:         [
                "Log nursing in \(.applicationName)",
                "Log nursing on the \(\.$side) in \(.applicationName)",
            ],
            shortTitle:      "Log nursing",
            systemImageName: "heart.fill"
        )
        AppShortcut(
            intent:          NextFeedingIntent(),
            phrases:         [
                "When is the next feeding in \(.applicationName)",
                "Next feeding in \(.applicationName)",
            ],
            shortTitle:      "Next feeding",
            systemImageName: "clock"
        )
    }
}
