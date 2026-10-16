import BabyCore
import SwiftUI

struct BabyDetailsSection: View {
    @Binding var baby: Baby
    let latestBirthDate: Date
    let invalidReason: String?

    private var birthDateRange: ClosedRange<Date> {
        FirstRunView.earliestBirthDate...latestBirthDate
    }

    private var birthDateBinding: Binding<Date> {
        Binding {
            baby.birthDate
        } set: { chosenDate in
            baby.birthDate = Calendar.autoupdatingCurrent.startOfDay(for: chosenDate)
        }
    }

    var body: some View {
        Section {
            TextField("Name", text: $baby.name)
                .textContentType(.givenName)
            DatePicker(
                "Birth date",
                selection:           birthDateBinding,
                in:                  birthDateRange,
                displayedComponents: .date
            )
        } header: {
            Text("Baby")
        } footer: {
            if let invalidReason {
                Text(invalidReason)
            }
        }

        Section("Feeding interval") {
            FeedingIntervalPicker(feedingIntervalMinutes: $baby.feedingIntervalMinutes)
        }
    }
}
