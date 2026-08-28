import XCTest

final class EquationOfTimeTests: XCTestCase {
    func testFormatsMinutesAndSeconds() {
        XCTAssertEqual(EquationOfTime(seconds: 192).clockText, "+3:12")
        XCTAssertEqual(EquationOfTime(seconds: -762).clockText, "−12:42")
    }

    func testSweepIsCenteredAndClamped() {
        XCTAssertEqual(EquationOfTime(seconds: 0).sweepFraction, 0)
        XCTAssertEqual(EquationOfTime(seconds: 8.5 * 60).sweepFraction, 0.5, accuracy: 0.0001)
        XCTAssertEqual(EquationOfTime(seconds: -30 * 60).sweepFraction, -1)
    }

    func testAnnualValuesStayInsideExpectedPhysicalRange() throws {
        let calendar = Calendar.utcGregorian
        let start = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 1, day: 1)))

        for day in 0..<365 {
            let date = try XCTUnwrap(calendar.date(byAdding: .day, value: day, to: start))
            XCTAssertLessThan(abs(EquationOfTime.calculate(at: date).seconds), 17 * 60)
        }
    }

    func testKnownSeasonalSigns() throws {
        let calendar = Calendar.utcGregorian
        let february = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 2, day: 11)))
        let november = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 11, day: 3)))

        XCTAssertLessThan(EquationOfTime.calculate(at: february).seconds, 0)
        XCTAssertGreaterThan(EquationOfTime.calculate(at: november).seconds, 0)
    }
}
