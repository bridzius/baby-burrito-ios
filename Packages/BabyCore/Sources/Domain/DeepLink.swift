import Foundation

// Links reach the app from the Live Activity, widgets and App Intents. They are untrusted input.
public enum DeepLink: Equatable, Sendable {
    case logFeeding(zoneName: String?)
    case today

    static let scheme: String         = "babyburrito"
    static let logFeedingHost: String = "log-feeding"
    static let todayHost: String      = "today"
    static let zoneQueryItem: String  = "zone"

    public init?(url: URL) {
        guard url.scheme == Self.scheme else { return nil }
        let components: URLComponents? = URLComponents(url: url, resolvingAgainstBaseURL: false)

        switch url.host() {
        case Self.logFeedingHost:
            let zoneName: String? = components?.queryItems?
                .first { $0.name == Self.zoneQueryItem }?.value
            self = .logFeeding(zoneName: zoneName)
        case Self.todayHost:
            self = .today
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
            components.queryItems = zoneName.map {
                [URLQueryItem(name: Self.zoneQueryItem, value: $0)]
            }
        case .today:
            components.host = Self.todayHost
        }

        guard let url = components.url else {
            preconditionFailure("A deep link's components always form a URL")
        }
        return url
    }
}
