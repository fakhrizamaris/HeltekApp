//
//  LiveActivityManager.swift
//  HeltekApp
//
//  Created by Codex on 13/03/26.
//

import Foundation

#if canImport(ActivityKit)
import ActivityKit
#endif

@MainActor
final class LiveActivityManager {
    static let shared = LiveActivityManager()

    private init() {}

    private var activity: Any?
    private var lastUpdateTime: Date?

    func start(remainingSeconds: Int, endDate: Date, title: String, isPaused: Bool = false) {
        guard #available(iOS 16.1, *), ActivityAuthorizationInfo().areActivitiesEnabled else { return }

        let attributes = StretchActivityAttributes(sessionID: UUID().uuidString)
        let state = StretchActivityAttributes.ContentState(remainingSeconds: remainingSeconds, endDate: endDate, title: title, isPaused: isPaused)
        let content = ActivityContent(state: state, staleDate: nil)

        do {
            let newActivity = try Activity.request(attributes: attributes, content: content, pushType: nil)
            activity = newActivity
            lastUpdateTime = Date()
        } catch {
            print("❌ Live Activity start failed: \(error.localizedDescription)")
        }
    }

    func update(remainingSeconds: Int, endDate: Date, title: String, isPaused: Bool = false) {
        guard #available(iOS 16.1, *), let activity = activity as? Activity<StretchActivityAttributes> else { return }

        // Throttle updates to avoid excessive frequency
        if let lastUpdateTime, Date().timeIntervalSince(lastUpdateTime) < 10 {
            return
        }

        let state = StretchActivityAttributes.ContentState(remainingSeconds: remainingSeconds, endDate: endDate, title: title, isPaused: isPaused)
        let content = ActivityContent(state: state, staleDate: nil)
        Task {
            await activity.update(content)
        }
        lastUpdateTime = Date()
    }

    func end() {
        guard #available(iOS 16.1, *), let activity = activity as? Activity<StretchActivityAttributes> else { return }

        Task {
            await activity.end(nil, dismissalPolicy: .immediate)
        }
        self.activity = nil
        lastUpdateTime = nil
    }
}
