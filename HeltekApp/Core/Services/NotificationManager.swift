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
        
        // MARK: - UPDATE SOUND BACKGROUND
        content.sound = UNNotificationSound(named: UNNotificationSoundName("illuminate.mp3"))
        
        // MARK: - TRIK LOOPING BACKGROUND
        for i in 0..<6 {
            let triggerTime = TimeInterval(seconds + (i * 30))
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(1, triggerTime), repeats: false)
            
            let request = UNNotificationRequest(identifier: "focusTimer_\(i)", content: content, trigger: trigger)
            center.add(request)
        }
    }
    
    func cancelTimerNotification() {
        let center = UNUserNotificationCenter.current()
        // Karena identifiernya sekarang ada banyak (focusTimer_0, focusTimer_1, dst),
        // kita hapus berdasarkan awalan identifier, atau paling mudah hapus semua yang pending.
        center.removeAllPendingNotificationRequests()
        // Note: Jika kamu punya notifikasi lain yang antre (di luar fitur timer ini),
        // kamu harus ambil ID-nya satu per satu dan pakai removePendingNotificationRequests(withIdentifiers:)
    }
    
    func playAlarmSound() {
        // Simple system alarm sound for foreground usage.
        AudioServicesPlaySystemSound(SystemSoundID(1102))
    }
    
    func playImportedSound(named soundName: String) {
        guard let url = Bundle.main.url(forResource: soundName, withExtension: "mp3") else {
            print("File suara tidak ditemukan: \(soundName)")
            return
        }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.duckOthers])
            try AVAudioSession.sharedInstance().setActive(true)
            
            soundEffectPlayer?.stop()
            
            soundEffectPlayer = try AVAudioPlayer(contentsOf: url)
            soundEffectPlayer?.numberOfLoops = -1
            soundEffectPlayer?.prepareToPlay()
            soundEffectPlayer?.play()
            
            print("Berhasil memutar alarm looping di foreground")
        } catch {
            print("Error memutar suara: \(error.localizedDescription)")
        }
    }
    
    func stopImportedSound() {
        soundEffectPlayer?.stop()
        soundEffectPlayer = nil
        try? AVAudioSession.sharedInstance().setActive(false)
    }
}
