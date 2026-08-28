import SwiftUI
import WidgetKit

struct SolarSweepEntry: TimelineEntry {
    let date: Date
    let value: EquationOfTime
}

struct SolarSweepProvider: TimelineProvider {
    func placeholder(in context: Context) -> SolarSweepEntry {
        SolarSweepEntry(date: Date(), value: EquationOfTime(seconds: 3 * 60 + 12))
    }

    func getSnapshot(in context: Context, completion: @escaping (SolarSweepEntry) -> Void) {
        let date = Date()
        completion(SolarSweepEntry(date: date, value: .calculate(at: date)))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SolarSweepEntry>) -> Void) {
        let calendar = Calendar.utcGregorian
        let start = calendar.startOfDay(for: Date())
        let entries = (0..<8).compactMap { day -> SolarSweepEntry? in
            guard let date = calendar.date(byAdding: .day, value: day, to: start) else { return nil }
            return SolarSweepEntry(date: date, value: .calculate(at: date))
        }
        completion(Timeline(entries: entries, policy: .atEnd))
    }
}

struct SolarSweepWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: SolarSweepEntry

    var body: some View {
        switch family {
        case .accessoryCorner:
            CornerSweepView(value: entry.value)
                .widgetLabel {
                    Text(entry.value.clockText)
                        .monospacedDigit()
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(entry.value.accessibilityText)
        case .accessoryCircular:
            EquationDisplayView(value: entry.value, compact: true)
                .padding(4)
        default:
            EquationDisplayView(value: entry.value, compact: true)
                .padding(.horizontal, 5)
        }
    }
}

private struct CornerSweepView: View {
    let value: EquationOfTime

    var body: some View {
        GeometryReader { proxy in
            let trackHeight = max(4, proxy.size.height * 0.25)
            let centerX = proxy.size.width / 2
            let travel = max(0, centerX - trackHeight / 2)
            let currentX = centerX + travel * value.sweepFraction

            ZStack {
                Capsule()
                    .fill(.secondary.opacity(0.35))
                    .frame(height: trackHeight)

                Path { path in
                    path.move(to: CGPoint(x: centerX, y: proxy.size.height / 2))
                    path.addLine(to: CGPoint(x: currentX, y: proxy.size.height / 2))
                }
                .stroke(
                    Color.accentColor,
                    style: StrokeStyle(lineWidth: trackHeight, lineCap: .round)
                )
                .widgetAccentable()

                Capsule()
                    .fill(.primary)
                    .frame(width: 2, height: trackHeight + 4)
                    .position(x: centerX, y: proxy.size.height / 2)

                Image(systemName: "sun.max.fill")
                    .font(.system(size: max(8, proxy.size.height * 0.55), weight: .semibold))
                    .symbolRenderingMode(.monochrome)
                    .foregroundStyle(.primary)
                    .position(x: currentX, y: proxy.size.height / 2)
                    .widgetAccentable()
            }
        }
        .frame(width: 42, height: 16)
        .widgetCurvesContent()
    }
}

@main
struct SolarSweepWidget: Widget {
    let kind = "SolarSweepWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SolarSweepProvider()) { entry in
            SolarSweepWidgetView(entry: entry)
                .containerBackground(.clear, for: .widget)
        }
        .configurationDisplayName("Solar Sweep")
        .description("See how far sun time is ahead of or behind mean time.")
        .supportedFamilies([.accessoryCorner, .accessoryCircular, .accessoryRectangular])
    }
}

#Preview(as: .accessoryRectangular) {
    SolarSweepWidget()
} timeline: {
    SolarSweepEntry(date: .now, value: EquationOfTime(seconds: -14 * 60 - 8))
    SolarSweepEntry(date: .now, value: EquationOfTime(seconds: 3 * 60 + 12))
}

#Preview("Corner", as: .accessoryCorner) {
    SolarSweepWidget()
} timeline: {
    SolarSweepEntry(date: .now, value: EquationOfTime(seconds: 3 * 60 + 12))
}
