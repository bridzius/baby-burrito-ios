import AppIntents
import BabyCore

struct LogNursingIntent: AppIntent {
    static let title: LocalizedStringResource = "Log nursing"
    static let description: IntentDescription = "Logs a nursing that just ended, with Undo."

    @Parameter(title: "Side")
    var side: SideAppEnum

    @Parameter(title: "Duration in minutes", inclusiveRange: (1, 120))
    var durationMinutes: Int

    static var parameterSummary: some ParameterSummary {
        Summary("Log \(\.$durationMinutes) minutes of nursing on \(\.$side)")
    }

    func perform() async throws -> some IntentResult & OpensIntent {
        let details: FeedingDetails = FeedingDetails(
            kind:            .nursing,
            durationMinutes: durationMinutes,
            side:            side.side
        )
        return .result(opensIntent: OpenURLIntent(DeepLink.logDetails(details).url))
    }
}
