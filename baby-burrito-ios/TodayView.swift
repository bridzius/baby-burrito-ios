import BabyCore
import SwiftUI

// Today's empty state only; the header, summary and feeding list come in #14–#16.
struct TodayView: View {
    let baby: LocalBaby

    var body: some View {
        NavigationStack {
            ContentUnavailableView {
                Label {
                    Text("No feedings yet")
                } icon: {
                    Image(systemName: "teddybear.fill")
                        .symbolEffect(.breathe)
                }
            }
            .navigationTitle(baby.name)
        }
    }
}
