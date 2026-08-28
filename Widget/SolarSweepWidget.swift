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

    private let stepCount = 7

    private var sunStep: Int {
        Int((((value.sweepFraction + 1) / 2) * Double(stepCount - 1)).rounded())
    }

    var body: some View {
        HStack(spacing: 1) {
            ForEach(0..<stepCount, id: \.self) { step in
                if step == sunStep {
                    Image(systemName: "sun.max.fill")
                        .font(.system(size: 8, weight: .semibold))
                        .widgetAccentable()
                } else {
                    Image(systemName: step == stepCount / 2 ? "diamond.fill" : "circle.fill")
                        .font(.system(size: step == stepCount / 2 ? 3.5 : 2.5))
                        .foregroundStyle(.secondary)
                }
            }
        }
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
