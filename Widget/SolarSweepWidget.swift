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
            ZStack {
                CornerSweepView(value: entry.value)
                    .offset(x: -8, y: 9)

                Text(entry.value.clockText)
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .monospacedDigit()
                    .minimumScaleFactor(0.7)
                    .offset(x: 7, y: -7)
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

    private let arcStart: CGFloat = 0.25
    private let arcMiddle: CGFloat = 0.50
    private let arcEnd: CGFloat = 0.75

    var body: some View {
        GeometryReader { proxy in
            let size = min(proxy.size.width, proxy.size.height)
            let lineWidth = max(2.5, size * 0.10)
            let radius = max(0, (size - lineWidth) / 2)
            let current = arcMiddle + (arcEnd - arcMiddle) * CGFloat(value.sweepFraction)

            ZStack {
                Circle()
                    .trim(from: arcStart, to: arcEnd)
                    .stroke(
                        .secondary.opacity(0.55),
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                    )

                Circle()
                    .trim(from: min(arcMiddle, current), to: max(arcMiddle, current))
                    .stroke(
                        Color.accentColor,
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                    )
                    .widgetAccentable()

                Circle()
                    .trim(from: arcMiddle - 0.007, to: arcMiddle + 0.007)
                    .stroke(
                        .primary,
                        style: StrokeStyle(lineWidth: lineWidth + 2, lineCap: .butt)
                    )

                Image(systemName: "sun.max.fill")
                    .font(.system(size: max(7, size * 0.23), weight: .semibold))
                    .symbolRenderingMode(.monochrome)
                    .foregroundStyle(.primary)
                    .rotationEffect(.degrees(Double(current) * 360))
                    .offset(y: -radius)
                    .rotationEffect(.degrees(-Double(current) * 360))
                    .widgetAccentable()
            }
            .rotationEffect(.degrees(90))
            .padding(lineWidth / 2)
        }
        .frame(width: 34, height: 34)
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
