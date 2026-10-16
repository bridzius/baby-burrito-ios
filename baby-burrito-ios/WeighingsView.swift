import BabyCore
import SwiftData
import SwiftUI

struct WeighingsView: View {
    let birthDate: Date
    let feedingStore: FeedingStore

    @Query(sort: \LocalWeighing.weighedOn, order: .reverse) private var weighings: [LocalWeighing]
    @State private var sheetMode: WeighingSheetMode?
    @State private var isShowingDeleteFailure: Bool = false

    private var logMode: WeighingSheetMode { .log(latestGrams: weighings.first?.grams) }

    var body: some View {
        List {
            ForEach(weighings) { localWeighing in
                Button {
                    sheetMode = .edit(localWeighing.weighing)
                } label: {
                    LabeledContent(
                        localWeighing.weighedOn.formatted(date: .long, time: .omitted),
                        value: WeightText.grams(localWeighing.grams)
                    )
                }
                .foregroundStyle(.primary)
                .swipeActions(edge: .trailing) {
                    Button("Delete", systemImage: "trash", role: .destructive) {
                        delete(localWeighing)
                    }
                }
            }
        }
        .overlay {
            if weighings.isEmpty {
                ContentUnavailableView {
                    Label("No weighings", systemImage: "scalemass")
                } actions: {
                    Button("Log a weighing") { sheetMode = logMode }
                }
            }
        }
        .navigationTitle("Weight")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Log weighing", systemImage: "plus") { sheetMode = logMode }
            }
        }
        .sheet(item: $sheetMode) { mode in
            WeighingSheet(mode: mode, birthDate: birthDate, feedingStore: feedingStore)
        }
        .alert("Couldn't delete. Try again.", isPresented: $isShowingDeleteFailure) {}
    }

    private func delete(_ localWeighing: LocalWeighing) {
        do {
            try feedingStore.deleteWeighing(localWeighing)
        } catch {
            isShowingDeleteFailure = true
        }
    }
}
