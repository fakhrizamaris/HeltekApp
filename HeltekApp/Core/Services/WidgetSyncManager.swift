//
//  WidgetSyncManager.swift
//  HeltekApp
//
//  Created by GitHub Copilot on 14/03/26.
//

import Foundation

#if canImport(WidgetKit)
import WidgetKit
#endif

enum WidgetSyncKeys {
    static let appGroupID = "group.com.fakhri.HeltekApp"
    static let timerEndDate = "widget.timerEndDate"
    static let currentStreak = "widget.currentStreak"
    static let isTimerActive = "widget.isTimerActive"
    static let remainingSeconds = "widget.remainingSeconds"
    static let stopRequested = "widget.stopRequested"
}

extension Notification.Name {
    static let widgetStopTimerRequested = Notification.Name("widgetStopTimerRequested")
}

@MainActor
final class WidgetSyncManager {
    static let shared = WidgetSyncManager()

    private init() {}

    private var lastReloadAt: Date?

    func sync(
        remainingSeconds: Int,
        timerEndDate: Date?,
        isActive: Bool,
        isPaused: Bool,
        currentStreak: Int,
        forceReload: Bool = false
    ) {
        guard let defaults = UserDefaults(suiteName: WidgetSyncKeys.appGroupID) else { return }

        defaults.set(max(0, remainingSeconds), forKey: WidgetSyncKeys.remainingSeconds)
        defaults.set(max(0, currentStreak), forKey: WidgetSyncKeys.currentStreak)

        let isRunning = isActive && !isPaused
        defaults.set(isRunning, forKey: WidgetSyncKeys.isTimerActive)
        if isRunning {
            defaults.set(false, forKey: WidgetSyncKeys.stopRequested)
        }

        let effectiveEndDate = isRunning
            ? (timerEndDate ?? Date().addingTimeInterval(TimeInterval(max(0, remainingSeconds))))
            : Date().addingTimeInterval(TimeInterval(max(0, remainingSeconds)))
        defaults.set(effectiveEndDate.timeIntervalSince1970, forKey: WidgetSyncKeys.timerEndDate)

        reloadTimelineIfNeeded(force: forceReload)
    }

    func handleStopFromWidget() {
        guard let defaults = UserDefaults(suiteName: WidgetSyncKeys.appGroupID) else { return }
        defaults.set(false, forKey: WidgetSyncKeys.isTimerActive)
        defaults.set(0, forKey: WidgetSyncKeys.remainingSeconds)
        defaults.set(Date().timeIntervalSince1970, forKey: WidgetSyncKeys.timerEndDate)
        defaults.set(true, forKey: WidgetSyncKeys.stopRequested)
        reloadTimelineIfNeeded(force: true)
        NotificationCenter.default.post(name: .widgetStopTimerRequested, object: nil)
    }

    private func reloadTimelineIfNeeded(force: Bool) {
#if canImport(WidgetKit)
        if force {
            WidgetCenter.shared.reloadTimelines(ofKind: "StretchWidget")
            lastReloadAt = Date()
            return
        }

        let now = Date()
        if let lastReloadAt, now.timeIntervalSince(lastReloadAt) < 15 {
            return
        }

        WidgetCenter.shared.reloadTimelines(ofKind: "StretchWidget")
        self.lastReloadAt = now
#endif
    }
}
