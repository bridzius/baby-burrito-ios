import SwiftUI

extension View {
    func numerals(_ textStyle: Font.TextStyle) -> some View {
        font(.system(textStyle, design: .rounded, weight: .semibold))
            .monospacedDigit()
    }
}
