//
//  StretchWidget.swift
//  StretchWidget
//
//  Created by Valentino Hartanto on 13/03/26.
//

import WidgetKit
import SwiftUI
import AppIntents

#if canImport(ActivityKit)
import ActivityKit
#endif

struct StopFocusIntent: AppIntent {
    static var title: LocalizedStringResource = "Stop Focus"
    static var openAppWhenRun: Bool = false

    func perform() async throws -> some IntentResult {
        let defaults = UserDefaults(suiteName: "group.com.yipz.HeltekApp") ?? .standard
        defaults.set(false, forKey: "widget.isTimerActive")
        defaults.set(0, forKey: "widget.remainingSeconds")
        defaults.set(Date().timeIntervalSince1970, forKey: "widget.timerEndDate")
        defaults.set(true, forKey: "widget.stopRequested")

#if canImport(ActivityKit)
        if #available(iOS 16.2, *) {
            let activeActivities = Activity<StretchActivityAttributes>.activities
            for activity in activeActivities {
                await activity.end(nil, dismissalPolicy: .immediate)
            }
        }
#endif

        WidgetCenter.shared.reloadTimelines(ofKind: "StretchWidget")
        return .result()
    }
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(
            date: Date(),
            endDate: Date().addingTimeInterval(45 * 60),
            currentStreak: 12,
            isRunning: true
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = makeEntry(for: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let now = Date()
        let entry = makeEntry(for: now)
        let nextRefresh = Calendar.current.date(byAdding: .minute, value: 1, to: now) ?? now.addingTimeInterval(60)
        let timeline = Timeline(entries: [entry], policy: .after(nextRefresh))
        completion(timeline)
    }

    private func makeEntry(for date: Date) -> SimpleEntry {
        let defaults = UserDefaults(suiteName: "group.com.yipz.HeltekApp") ?? .standard
        let savedEndDate = Date(timeIntervalSince1970: defaults.double(forKey: "widget.timerEndDate"))
        let savedStreak = defaults.integer(forKey: "widget.currentStreak")
        let isRunning = defaults.bool(forKey: "widget.isTimerActive")
        let savedRemainingSeconds = defaults.integer(forKey: "widget.remainingSeconds")

        let fallbackEndDate = date.addingTimeInterval(45 * 60)
        let fallbackStreak = 12

        return SimpleEntry(
            date: date,
            endDate: savedEndDate > date ? savedEndDate : date.addingTimeInterval(TimeInterval(max(0, savedRemainingSeconds))),
            currentStreak: savedStreak > 0 ? savedStreak : fallbackStreak,
            isRunning: isRunning
        )
    }

//    func relevances() async -> WidgetRelevances<Void> {
//        // Generate a list containing the contexts this widget is relevant in.
//    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let endDate: Date
    let currentStreak: Int
    let isRunning: Bool
}

struct StretchWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) private var family

    private let themeOrange = Color(red: 1.0, green: 0.37, blue: 0.14)
    private let deepNavy = Color(red: 0.13, green: 0.18, blue: 0.29)
    // Menggunakan background putih bersih agar lebih modern
    private let cardBackground = Color.white

    private var stopURL: URL {
        URL(string: "heltekapp://stop-timer")!
    }

    var body: some View {
        ZStack {
            // Corner radius standar iOS widget biasanya sekitar 20-24 untuk konten dalam padding
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(cardBackground)

            switch family {
            case .systemMedium:
                mediumLayout
            default:
                smallLayout
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var smallLayout: some View {
        GeometryReader { geo in
            let side = min(geo.size.width, geo.size.height)
            let ringDiameter = side * 0.6
            let ringLine = 5.0 
            let timerFont = side * 0.15
            let buttonWidth = side 

            VStack(spacing: 12) {
                Spacer()

                timerRing(diameter: ringDiameter, fontSize: timerFont, lineWidth: ringLine)

                stopButton(fullWidth: false)
                    .frame(width: buttonWidth)

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding()
    }

    private var mediumLayout: some View {
        GeometryReader { geo in
            let cardHeight = geo.size.height
            let ringDiameter = cardHeight * 0.8
            let ringLine = 8.0 
            let timerFont = cardHeight * 0.20

            HStack(spacing: 24) {
                timerRing(diameter: ringDiameter, fontSize: timerFont, lineWidth: ringLine)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("CURRENT STREAK")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(Color.gray.opacity(0.8))
                        .kerning(0.5)

                    Text("\(entry.currentStreak) Days")
                        .font(.system(size: 24, weight: .heavy, design: .rounded))
                        .foregroundColor(deepNavy)
                        .padding(.bottom, 4)

                    Text("TIME TO MOVE!")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(themeOrange)

                    Capsule()
                        .fill(themeOrange)
                        .frame(width: 24, height: 4)
                        .padding(.vertical, 6)
                        
                    Spacer()

                    stopButton(fullWidth: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(16)
        }
    }

    private func timerRing(diameter: CGFloat, fontSize: CGFloat, lineWidth: CGFloat = 12) -> some View {
        ZStack {
            Circle()
                .stroke(themeOrange, lineWidth: lineWidth)
                .frame(width: diameter, height: diameter)

            if entry.isRunning {
                // Use timer style so WidgetKit updates the countdown continuously.
                Text(entry.endDate, style: .timer)
                    .font(.system(size: fontSize, weight: .heavy, design: .rounded))
                    .foregroundColor(deepNavy)
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)
                    .monospacedDigit()
                    .frame(width: diameter, alignment: .center)
                    .multilineTextAlignment(.center)
            } else {
                Text("00:00")
                    .font(.system(size: fontSize, weight: .heavy, design: .rounded))
                    .foregroundColor(deepNavy)
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)
                    .monospacedDigit()
                    .frame(width: diameter, alignment: .center)
                    .multilineTextAlignment(.center)
            }
        }
    }

    @ViewBuilder
    private func stopButton(fullWidth: Bool) -> some View {
        if entry.isRunning {
            if #available(iOS 17.0, *) {
                Button(intent: StopFocusIntent()) {
                    stopButtonContent(fullWidth: fullWidth, isEnabled: true)
                }
                .buttonStyle(.plain)
            } else {
                Link(destination: stopURL) {
                    stopButtonContent(fullWidth: fullWidth, isEnabled: true)
                }
                .buttonStyle(.plain)
            }
        } else {
            stopButtonContent(fullWidth: fullWidth, isEnabled: false)
        }
    }

    private func stopButtonContent(fullWidth: Bool, isEnabled: Bool) -> some View {
        let foregroundColor: Color = fullWidth ? .white : themeOrange
        // Tombol small widget lebih terang, medium widget solid orange
        let backgroundColor: Color = fullWidth ? themeOrange : themeOrange.opacity(0.1)
        let strokeColor: Color = themeOrange.opacity(0.3)

        return HStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 3, style: .continuous)
                .fill(fullWidth ? .white : themeOrange)
                .frame(width: fullWidth ? 14 : 12, height: fullWidth ? 14 : 12)

            Text("STOP")
                .font(.system(size: fullWidth ? 15 : 14, weight: .bold, design: .rounded))
                .kerning(0.6)
        }
        .foregroundColor(foregroundColor)
        .frame(maxWidth: fullWidth ? .infinity : nil)
        .padding(.vertical, fullWidth ? 10 : 8)
        .padding(.horizontal, fullWidth ? 0 : 20)
        .background(backgroundColor)
        .overlay(
            Capsule(style: .continuous)
                .stroke(strokeColor, lineWidth: fullWidth ? 0 : 1)
        )
        .clipShape(Capsule(style: .continuous))
        .opacity(isEnabled ? 1.0 : 0.4)
    }

}

struct StretchWidget: Widget {
    let kind: String = "StretchWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                StretchWidgetEntryView(entry: entry)
                    .containerBackground(.clear, for: .widget)
            } else {
                StretchWidgetEntryView(entry: entry)
                    .background(Color.clear)
            }
        }
        .supportedFamilies([.systemSmall, .systemMedium])
        .contentMarginsDisabled()
        .configurationDisplayName("Heltek Timer")
        .description("Track countdown, streak, and quickly stop from your widget.")
    }
}

#Preview(as: .systemSmall) {
    StretchWidget()
} timeline: {
    SimpleEntry(date: .now, endDate: .now.addingTimeInterval(45 * 60), currentStreak: 12, isRunning: true)
}

#Preview(as: .systemMedium) {
    StretchWidget()
} timeline: {
    SimpleEntry(date: .now, endDate: .now.addingTimeInterval(45 * 60), currentStreak: 12, isRunning: true)
}
