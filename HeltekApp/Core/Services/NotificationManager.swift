//
//  NotificationManager.swift
//  HeltekApp
//
//  Created by Codex on 13/03/26.
//

import Foundation
import AudioToolbox
import AVFoundation
import UserNotifications

final class NotificationManager {
    static let shared = NotificationManager()
    private var soundEffectPlayer: AVAudioPlayer?

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
    
    func playImportedSound(named soundName: String) {
            if let url = Bundle.main.url(forResource: soundName, withExtension: "wav") {
                do {
                    soundEffectPlayer = try AVAudioPlayer(contentsOf: url)
                    soundEffectPlayer?.play()
                } catch {
                    print("Error playing sound \(error.localizedDescription)")
                }
            } else {
                print("Sound file not found \(soundName)")
            }
        }
}
