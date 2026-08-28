# Equation of Time for Apple Watch

## Purpose

A tiny Apple Watch complication/widget that shows the equation of time: the difference between apparent solar time (what a sundial indicates) and mean solar time (clock time based on a uniform 24-hour day).

## Proposed v0

- Native watchOS app using SwiftUI and WidgetKit.
- Calculate locally from the current date; no account, server, network, or location permission required.
- Primary value shown as signed minutes and seconds, for example `+3:12` or `−12:42`.
- Use the convention **apparent solar time minus mean solar time**. A positive value means a sundial is ahead of mean solar time.
- Do not show an `EoT` text label on the complication.
- Place a small center-zero sweep graphic above the value. Its indicator moves left for a negative value (apparent solar time behind mean solar time), centers at zero, and moves right for a positive value (ahead). Its distance from center represents the magnitude.
- Support corner, circular, and rectangular complications, with the containing watch app providing a short explanation and today's expanded value.
- Refresh often enough to track the slow day-to-day change; minute-by-minute refresh is unnecessary.

## Calculation

The prototype uses the NOAA fractional-year approximation, evaluated in UTC and adjusted for leap years:

```text
γ = 2π / Y × (N − 1 + (h − 12) / 24)
E = 229.18 × (0.000075 + 0.001868 cos γ − 0.032077 sin γ
    − 0.014615 cos 2γ − 0.040849 sin 2γ)
```

where `N` is the day of the year, `Y` is the number of days in that year, `h` is the fractional UTC hour, and `E` is minutes under the chosen sign convention. Before release, compare the implementation against a higher-accuracy solar-position reference across leap years and the full calendar year.

## Complication display

- Top: a thin horizontal or shallow-arc track with a center mark and one moving indicator.
- Bottom: a signed `m:ss` value in monospaced digits.
- Corner family: use a system-curved dotted sweep with a moving sun, allowing watchOS to follow and orient it for whichever corner the wearer chooses; curve the signed `m:ss` value along the inner bezel.
- Scale the sweep symmetrically to approximately `−17:00 … 0 … +17:00`, covering the annual range with a little visual margin.
- Accessibility label should spell out the meaning, for example “apparent solar time is 3 minutes 12 seconds ahead of mean solar time.”

## Decisions still open

- Final visual form: horizontal track, shallow arc, or a more symbolic sun/analemma-inspired mark.
- Whether the numeric sign remains visible when the graphic already indicates direction. The current default is yes for clarity.
- Minimum watchOS version and distribution method.

## First milestone

Build an Xcode prototype with:

1. A tested pure-Swift equation-of-time calculator.
2. One complication showing the signed current value.
3. A simple watch app screen explaining the sign and showing a more precise value.
4. Preview/test dates near the yearly extrema and zero crossings.

## Generate and run

This repository uses XcodeGen so the Xcode project does not need to be committed:

```sh
xcodegen generate
open SolarSweep.xcodeproj
```

Select the `SolarSweepWatch` scheme and a paired watch or watchOS simulator. Add the Solar Sweep complication from the watch-face editor.
