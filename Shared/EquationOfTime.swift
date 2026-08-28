import Foundation

struct EquationOfTime: Equatable, Sendable {
    /// Apparent solar time minus mean solar time, in seconds.
    let seconds: Double

    var sweepFraction: Double {
        min(max(seconds / (17 * 60), -1), 1)
    }

    var clockText: String {
        let roundedSeconds = Int(seconds.rounded())
        let sign = roundedSeconds < 0 ? "−" : "+"
        let magnitude = abs(roundedSeconds)
        return String(format: "%@%d:%02d", sign, magnitude / 60, magnitude % 60)
    }

    var accessibilityText: String {
        let roundedSeconds = abs(Int(seconds.rounded()))
        let minutes = roundedSeconds / 60
        let remainder = roundedSeconds % 60
        let relationship = seconds < 0 ? "behind" : "ahead of"
        return "Apparent solar time is \(minutes) minutes and \(remainder) seconds \(relationship) mean solar time"
    }

    static func calculate(at date: Date, calendar: Calendar = .utcGregorian) -> Self {
        let day = calendar.ordinality(of: .day, in: .year, for: date) ?? 1
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        let fractionalHour = Double(hour) + Double(minute) / 60
        let daysInYear = calendar.range(of: .day, in: .year, for: date)?.count ?? 365
        let gamma = 2 * Double.pi / Double(daysInYear)
            * (Double(day - 1) + (fractionalHour - 12) / 24)

        let minutes = 229.18 * (
            0.000075
                + 0.001868 * cos(gamma)
                - 0.032077 * sin(gamma)
                - 0.014615 * cos(2 * gamma)
                - 0.040849 * sin(2 * gamma)
        )
        return Self(seconds: minutes * 60)
    }
}

extension Calendar {
    static var utcGregorian: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }
}
