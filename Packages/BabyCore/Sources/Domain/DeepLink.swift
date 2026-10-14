import Foundation

// Links reach the app from the Live Activity, widgets and App Intents. They are untrusted input:
// details are validated when they are logged.
public enum DeepLink: Equatable, Sendable {
    case logFeeding(zoneName: String?)
    case logDetails(FeedingDetails)
    case today

    static let scheme: String         = "babyburrito"
    static let logFeedingHost: String = "log-feeding"
    static let todayHost: String      = "today"

    enum QueryItem {
        static let zone: String     = "zone"
        static let kind: String     = "kind"
        static let amount: String   = "amount"
        static let side: String     = "side"
        static let duration: String = "duration"
    }

    public init?(url: URL) {
        guard url.scheme == Self.scheme else { return nil }
        let queryItems: [URLQueryItem] = URLComponents(url: url, resolvingAgainstBaseURL: false)?
            .queryItems ?? []
        let value: (String) -> String? = { name in queryItems.first { $0.name == name }?.value }

        switch url.host() {
        case Self.todayHost:
            self = .today
        case Self.logFeedingHost:
            guard let kindValue = value(QueryItem.kind) else {
                self = .logFeeding(zoneName: value(QueryItem.zone))
                return
            }
            guard let kind = FeedingKind(rawValue: kindValue) else { return nil }
            self = .logDetails(FeedingDetails(
                kind:            kind,
                amountMl:        value(QueryItem.amount).flatMap { Int($0) },
                durationMinutes: value(QueryItem.duration).flatMap { Int($0) },
                side:            value(QueryItem.side).flatMap { Side(rawValue: $0) }
            ))
        default:
            return nil
        }
    }

    public var url: URL {
        var components: URLComponents = URLComponents()
        components.scheme             = Self.scheme

        switch self {
        case .logFeeding(let zoneName):
            components.host       = Self.logFeedingHost
            components.queryItems = zoneName.map { [URLQueryItem(name: QueryItem.zone, value: $0)] }
        case .logDetails(let details):
            components.host       = Self.logFeedingHost
            components.queryItems = Self.queryItems(for: details)
        case .today:
            components.host = Self.todayHost
        }

        guard let url = components.url else {
            preconditionFailure("A deep link's components always form a URL")
        }
        return url
    }

    private static func queryItems(for details: FeedingDetails) -> [URLQueryItem] {
        let optionalItems: [(String, String?)] = [
            (QueryItem.kind, details.kind.rawValue),
            (QueryItem.amount, details.amountMl.map(String.init)),
            (QueryItem.side, details.side?.rawValue),
            (QueryItem.duration, details.durationMinutes.map(String.init)),
        ]
        return optionalItems.compactMap { name, value in
            value.map { URLQueryItem(name: name, value: $0) }
        }
    }
}
