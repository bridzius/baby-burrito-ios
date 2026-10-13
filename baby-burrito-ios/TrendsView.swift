import SwiftUI

// Placeholder destination until Trends (#23).
struct TrendsView: View {
    var body: some View {
        ContentUnavailableView("No trends yet", systemImage: "chart.bar.xaxis")
            .navigationTitle("Trends")
    }
}
