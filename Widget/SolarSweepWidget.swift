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

    private let arcStart: CGFloat = 0.15
    private let arcMiddle: CGFloat = 0.50
    private let arcEnd: CGFloat = 0.85

    var body: some View {
        GeometryReader { proxy in
            let lineWidth = max(3, min(proxy.size.width, proxy.size.height) * 0.10)
            let current = arcMiddle + (arcEnd - arcMiddle) * CGFloat(value.sweepFraction)

            ZStack {
                Circle()
                    .trim(from: arcStart, to: arcEnd)
                    .stroke(
                        .secondary.opacity(0.55),
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                    )

                Circle()
                    .trim(
                        from: min(arcMiddle, current),
                        to: max(arcMiddle, current)
                    )
                    .stroke(
                        Color.accentColor,
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                    )
                    .widgetAccentable()

                Circle()
                    .trim(from: arcMiddle - 0.006, to: arcMiddle + 0.006)
                    .stroke(
                        .primary,
                        style: StrokeStyle(lineWidth: lineWidth + 3, lineCap: .butt)
                    )

                Image(systemName: "sun.max.fill")
                    .font(.system(size: max(8, proxy.size.width * 0.23), weight: .semibold))
                    .symbolRenderingMode(.monochrome)
                    .foregroundStyle(.primary)
                    .rotationEffect(.turns(Double(current)))
                    .offset(y: -(min(proxy.size.width, proxy.size.height) - lineWidth) / 2)
                    .rotationEffect(.turns(-Double(current)))
                    .widgetAccentable()
            }
            .rotationEffect(.degrees(90))
            .padding(lineWidth / 2)
        }
        .aspectRatio(1, contentMode: .fit)
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
