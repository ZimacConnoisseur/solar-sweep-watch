import SwiftUI

struct SolarSweepView: View {
    let value: EquationOfTime

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let inset = max(5, width * 0.08)
            let travel = max(0, width / 2 - inset)

            ZStack {
                Path { path in
                    path.move(to: CGPoint(x: inset, y: proxy.size.height * 0.72))
                    path.addQuadCurve(
                        to: CGPoint(x: width - inset, y: proxy.size.height * 0.72),
                        control: CGPoint(x: width / 2, y: 0)
                    )
                }
                .stroke(.secondary.opacity(0.65), style: StrokeStyle(lineWidth: 1.5, lineCap: .round))

                Capsule()
                    .fill(.secondary)
                    .frame(width: 1.5, height: 5)
                    .position(x: width / 2, y: proxy.size.height * 0.23)

                Image(systemName: "sun.max.fill")
                    .font(.system(size: max(8, proxy.size.height * 0.32), weight: .semibold))
                    .symbolRenderingMode(.monochrome)
                    .offset(x: travel * value.sweepFraction)
            }
        }
        .accessibilityHidden(true)
    }
}
