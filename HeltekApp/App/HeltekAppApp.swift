//
//  HeltekAppApp.swift
//  HeltekApp
//

import SwiftUI

@main
struct HeltekAppApp: App {
    
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    
    // init() dipanggil saat app pertama kali buka
    // Tempat yang tepat untuk inisialisasi Firebase
    
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
