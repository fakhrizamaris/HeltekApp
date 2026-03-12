//
//  HeltekAppApp.swift
//  HeltekApp
//
//  Created by Fakhri Djamaris on 10/03/26.
//

import SwiftUI

@main
struct HeltekAppApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()
    
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
