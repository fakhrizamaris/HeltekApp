//
//  StretchWidgetLiveActivity.swift
//  StretchWidget
//
//  Created by Valentino Hartanto on 13/03/26.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct StretchWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: StretchActivityAttributes.self) { context in
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    Image(systemName: "figure.walk")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.accentColor)
                        .frame(width: 22, height: 22)
                        .background(Color.accentColor.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                    Text("Focus Mode")
                        .font(.headline)
                }

                Text("Your next stretch is on")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text(context.state.title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                if context.state.isPaused {
                    Text(timeString(from: context.state.remainingSeconds))
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                } else {
                    Text(timerInterval: Date.now...context.state.endDate, countsDown: true)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    HStack(spacing: 6) {
                        Image(systemName: "figure.walk")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.accentColor)
                        Text("Focus Mode")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    if context.state.isPaused {
                        Text(shortTime(from: context.state.remainingSeconds))
                            .font(.headline)
                    } else {
                        Text(timerInterval: Date.now...context.state.endDate, countsDown: true)
                            .font(.headline)
                    }
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Your next movement is on")
                        .font(.caption)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            } compactLeading: {
                Image(systemName: "figure.walk")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.accentColor)
            } compactTrailing: {
                if context.state.isPaused {
                    Text(shortTime(from: context.state.remainingSeconds))
                } else {
                    Text(shortTime(from: max(0, Int(context.state.endDate.timeIntervalSinceNow))))
                }
            } minimal: {
                Image(systemName: "figure.walk")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.accentColor)
            }
        }
    }

    private func timeString(from totalSeconds: Int) -> String {
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private func shortTime(from totalSeconds: Int) -> String {
        let minutes = max(0, totalSeconds / 60)
        return "\(minutes)m"
    }
}

#Preview("Notification", as: .content, using: StretchActivityAttributes(sessionID: "preview")) {
    StretchWidgetLiveActivity()
} contentStates: {
    StretchActivityAttributes.ContentState(remainingSeconds: 60, endDate: Date().addingTimeInterval(60), title: "Next Movement", isPaused: false)
    StretchActivityAttributes.ContentState(remainingSeconds: 30, endDate: Date().addingTimeInterval(30), title: "Almost done", isPaused: false)
}
