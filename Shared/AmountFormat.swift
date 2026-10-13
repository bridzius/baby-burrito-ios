import Foundation

extension Int {
    // .asProvided keeps millilitres; the default usage converts to the region's unit (cm³).
    var formattedMillilitres: String {
        Measurement(value: Double(self), unit: UnitVolume.milliliters)
            .formatted(.measurement(width: .abbreviated, usage: .asProvided))
    }
}
