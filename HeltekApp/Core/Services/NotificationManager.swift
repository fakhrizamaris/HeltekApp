//
//  NotificationManager.swift
//  HeltekApp
//
//  Created by Codex on 13/03/26.
//

import Foundation
import AudioToolbox
import UserNotifications

final class NotificationManager {
    static let shared = NotificationManager()

    private init() {}

    func requestAuthorization() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    func scheduleTimerNotification(seconds: Int) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["focusTimer"])

        let content = UNMutableNotificationContent()
        content.title = "Time to Move"
        content.body = "Your timer is up. Ready to stretch?"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(1, TimeInterval(seconds)), repeats: false)
        let request = UNNotificationRequest(identifier: "focusTimer", content: content, trigger: trigger)
        center.add(request)
    }

    func cancelTimerNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["focusTimer"])
    }

    func playAlarmSound() {
        // Simple system alarm sound for foreground usage.
        AudioServicesPlaySystemSound(SystemSoundID(1005))
    }
}
