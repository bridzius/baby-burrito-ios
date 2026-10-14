public enum DeepLinkRoute: Equatable, Sendable {
    public enum Notice: Equatable, Sendable {
        case babyNotOnThisPhone
    }

    case firstRun
    case today(notice: Notice?)
    case openLogSheet
    case logRepeat
    case log(FeedingDetails)

    // Deep links, App Intents and the Live Activity tap all decide here what opening the app does.
    public init(link: DeepLink, babyLogZoneName: String?, canLog: Bool, hasLastFeeding: Bool) {
        guard let babyLogZoneName else { self = .firstRun; return }

        switch link {
        case .today:
            self = .today(notice: nil)
        case .logDetails(let details):
            self = canLog ? .log(details) : .today(notice: nil)
        case .logFeeding(let zoneName):
            guard zoneName == nil || zoneName == babyLogZoneName else {
                self = .today(notice: .babyNotOnThisPhone)
                return
            }
            guard canLog else { self = .today(notice: nil); return }
            self = hasLastFeeding ? .logRepeat : .openLogSheet
        }
    }
}
