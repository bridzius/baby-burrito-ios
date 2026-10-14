import Charts
import SwiftUI

extension View {
    // Tapping a chart picks the local day under the finger. chartXSelection needs a press and
    // drag inside a List, so a plain tap is read through the chart proxy instead.
    func selectsDay(_ selectDay: @escaping (Date) -> Void) -> some View {
        chartOverlay { chartProxy in
            GeometryReader { geometry in
                Rectangle()
                    .fill(.clear)
                    .contentShape(Rectangle())
                    .gesture(SpatialTapGesture().onEnded { tap in
                        guard let plotFrame = chartProxy.plotFrame else { return }
                        let plotX: CGFloat = tap.location.x - geometry[plotFrame].origin.x
                        guard let tappedDate = chartProxy.value(atX: plotX, as: Date.self) else {
                            return
                        }
                        selectDay(Calendar.autoupdatingCurrent.startOfDay(for: tappedDate))
                    })
            }
        }
    }
}
