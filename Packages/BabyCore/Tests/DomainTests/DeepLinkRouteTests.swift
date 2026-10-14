import Testing
import Domain

struct DeepLinkRouteTests {
    let zoneName: String = "BabyLog-1"

    func route(
        _ link:          DeepLink,
        babyLogZoneName: String? = "BabyLog-1",
        canLog:          Bool    = true,
        hasLastFeeding:  Bool    = true
    ) -> DeepLinkRoute {
        DeepLinkRoute(
            link:            link,
            babyLogZoneName: babyLogZoneName,
            canLog:          canLog,
            hasLastFeeding:  hasLastFeeding
        )
    }

    @Test func logs_a_repeat_for_this_phones_zone() {
        #expect(route(.logFeeding(zoneName: zoneName)) == .logRepeat)
    }

    @Test func logs_a_repeat_when_the_link_names_no_zone() {
        #expect(route(.logFeeding(zoneName: nil)) == .logRepeat)
    }

    @Test func opens_today_with_a_notice_for_an_unknown_zone() {
        #expect(route(.logFeeding(zoneName: "BabyLog-2")) == .today(notice: .babyNotOnThisPhone))
    }

    @Test func opens_the_log_sheet_when_there_is_nothing_to_repeat() {
        #expect(route(.logFeeding(zoneName: zoneName), hasLastFeeding: false) == .openLogSheet)
    }

    @Test(arguments: [DeepLink.logFeeding(zoneName: nil), .today])
    func opens_first_run_without_a_baby_log(link: DeepLink) {
        #expect(route(link, babyLogZoneName: nil) == .firstRun)
    }

    @Test func opens_today_without_logging_for_a_viewer() {
        #expect(route(.logFeeding(zoneName: zoneName), canLog: false) == .today(notice: nil))
    }

    @Test func opens_today_for_the_today_link() {
        #expect(route(.today) == .today(notice: nil))
    }

    @Test func logs_the_given_details_even_without_a_last_feeding() {
        let details: FeedingDetails = FeedingDetails(kind: .formula, amountMl: 90)

        #expect(route(.logDetails(details), hasLastFeeding: false) == .log(details))
    }

    @Test func opens_today_without_logging_the_given_details_for_a_viewer() {
        let details: FeedingDetails = FeedingDetails(kind: .formula, amountMl: 90)

        #expect(route(.logDetails(details), canLog: false) == .today(notice: nil))
    }
}
