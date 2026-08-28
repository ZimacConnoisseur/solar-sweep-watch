import SwiftUI

struct EquationDisplayView: View {
    let value: EquationOfTime
    var compact = false

    var body: some View {
        VStack(spacing: compact ? 1 : 5) {
            SolarSweepView(value: value)
                .frame(height: compact ? 19 : 36)

            Text(value.clockText)
                .font(.system(size: compact ? 17 : 30, weight: .semibold, design: .rounded))
                .monospacedDigit()
                .minimumScaleFactor(0.65)
                .lineLimit(1)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(value.accessibilityText)
    }
}
