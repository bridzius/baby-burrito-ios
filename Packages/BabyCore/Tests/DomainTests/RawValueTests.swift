import Testing
@testable import Domain

struct RawValueTests {
    @Test func feeding_kinds_use_the_backend_raw_values() {
        #expect(FeedingKind.allCases.map(\.rawValue) == ["nursing", "breast_milk", "formula"])
    }

    @Test func sides_use_the_backend_raw_values() {
        #expect(Side.allCases.map(\.rawValue) == ["left", "right", "both"])
    }
}
