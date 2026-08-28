import SwiftUI

struct ContentView: View {
    private let value = EquationOfTime.calculate(at: Date())

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                EquationDisplayView(value: value)
                    .padding(.horizontal, 8)

                Text(value.seconds < 0 ? "Sun time is behind clock time" : "Sun time is ahead of clock time")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.vertical, 8)
        }
    }
}

#Preview {
    ContentView()
}
