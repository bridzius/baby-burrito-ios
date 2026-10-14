import Foundation
import Testing
import Domain

struct DeepLinkTests {
    @Test func builds_and_parses_a_log_feeding_link_for_a_zone() throws {
        let link: DeepLink = .logFeeding(zoneName: "BabyLog-1")

        #expect(link.url.absoluteString == "babyburrito://log-feeding?zone=BabyLog-1")
        #expect(DeepLink(url: link.url) == link)
    }

    @Test func parses_a_log_feeding_link_without_a_zone() throws {
        let url: URL = try #require(URL(string: "babyburrito://log-feeding"))

        #expect(DeepLink(url: url) == .logFeeding(zoneName: nil))
    }

    @Test func builds_and_parses_the_today_link() {
        #expect(DeepLink.today.url.absoluteString == "babyburrito://today")
        #expect(DeepLink(url: DeepLink.today.url) == .today)
    }

    @Test(arguments: ["https://log-feeding", "babyburrito://delete-everything", "babyburrito:"])
    func ignores_other_links(text: String) throws {
        let url: URL = try #require(URL(string: text))

        #expect(DeepLink(url: url) == nil)
    }

    @Test func builds_and_parses_a_link_that_logs_a_bottle() {
        let link: DeepLink = .logDetails(FeedingDetails(kind: .formula, amountMl: 90))

        #expect(link.url.absoluteString == "babyburrito://log-feeding?kind=formula&amount=90")
        #expect(DeepLink(url: link.url) == link)
    }

    @Test func builds_and_parses_a_link_that_logs_a_nursing() {
        let details: FeedingDetails = FeedingDetails(
            kind: .nursing, durationMinutes: 15, side: .left
        )
        let link: DeepLink = .logDetails(details)

        #expect(
            link.url.absoluteString == "babyburrito://log-feeding?kind=nursing&side=left&duration=15"
        )
        #expect(DeepLink(url: link.url) == link)
    }

    @Test func ignores_a_link_with_an_unknown_kind() throws {
        let url: URL = try #require(URL(string: "babyburrito://log-feeding?kind=juice&amount=90"))

        #expect(DeepLink(url: url) == nil)
    }
}
