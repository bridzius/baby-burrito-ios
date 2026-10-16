import BabyCore
import SwiftData
import SwiftUI

struct WeightSection: View {
    static let rowIdentifier: String = "weightRow"

    let birthDate: Date
    let feedingStore: FeedingStore

    @Query(Self.latestWeighingDescriptor) private var latestWeighings: [LocalWeighing]

    static var latestWeighingDescriptor: FetchDescriptor<LocalWeighing> {
        var descriptor: FetchDescriptor<LocalWeighing> = FetchDescriptor(
            sortBy: [SortDescriptor(\.weighedOn, order: .reverse)]
        )
        descriptor.fetchLimit = 1
        return descriptor
    }

    var body: some View {
        Section {
            NavigationLink {
                WeighingsView(birthDate: birthDate, feedingStore: feedingStore)
            } label: {
                LabeledContent("Weight", value: latestWeightText)
            }
            .accessibilityIdentifier(Self.rowIdentifier)
        }
    }

    private var latestWeightText: String {
        guard let latest = latestWeighings.first else { return String(localized: "None yet") }
        let day: String = latest.weighedOn.formatted(.dateTime.day().month(.abbreviated))
        return String(localized: "\(WeightText.grams(latest.grams)) · \(day)")
    }
}
