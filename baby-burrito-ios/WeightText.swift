import Foundation

enum WeightText {
    static func grams(_ grams: Int) -> String {
        Measurement(value: Double(grams), unit: UnitMass.grams)
            .formatted(.measurement(width: .abbreviated, usage: .asProvided))
    }
}
