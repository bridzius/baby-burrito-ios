import Foundation

extension Duration {
    static func minutes(_ minutes: Int) -> Duration {
        .seconds(minutes * 60)
    }
}

extension FormatStyle where Self == Duration.UnitsFormatStyle {
    static var hoursAndMinutes: Duration.UnitsFormatStyle {
        .units(allowed: [.hours, .minutes], width: .abbreviated)
    }
}
