//
//  HeltekAppApp.swift
//  HeltekApp
//

import SwiftUI
import FirebaseCore      // ← tambah import ini

@main
struct HeltekAppApp: App {
    
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    
    // init() dipanggil saat app pertama kali buka
    // Tempat yang tepat untuk inisialisasi Firebase
    init() {
        // Seperti koneksi ke database — harus dilakukan sekali di awal
        FirebaseApp.configure()
        print("🔥 Firebase berhasil diinisialisasi!")
    }
    
    var body: some Scene {
        WindowGroup {
            if !hasSeenOnboarding {
                OnboardingView()
            } else if !isLoggedIn {
                LoginView()
            } else {
                MainTabView()
            }
        }
    }
}
