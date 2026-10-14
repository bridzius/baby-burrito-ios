import AppIntents
import BabyCore

// "Log 90 ml formula". The app validates the amount when it logs, as for any deep link.
struct LogBottleIntent: AppIntent {
    static let title: LocalizedStringResource = "Log bottle"
    static let description: IntentDescription = "Logs a bottle and shows it with Undo."

    @Parameter(title: "Bottle")
    var kind: BottleKindAppEnum

    @Parameter(title: "Amount in ml", inclusiveRange: (1, 500))
    var amountMl: Int

    static var parameterSummary: some ParameterSummary {
        Summary("Log \(\.$amountMl) ml \(\.$kind)")
    }

    func perform() async throws -> some IntentResult & OpensIntent {
        let details: FeedingDetails = FeedingDetails(kind: kind.feedingKind, amountMl: amountMl)
        return .result(opensIntent: OpenURLIntent(DeepLink.logDetails(details).url))
    }
}
