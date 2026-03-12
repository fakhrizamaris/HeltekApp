//
//  HeltekAppApp.swift
//  HeltekApp
////  Created by Fakhri Djamaris on 10/03/26.
//

import SwiftUI
import FirebaseCore

@main
struct HeltekAppApp: App {
    
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    @AppStorage("hasCompletedProfile") private var hasCompletedProfile = false
    
    init() {
        FirebaseApp.configure()
    }    
    var body: some Scene {
        WindowGroup {
            if !hasSeenOnboarding {
                // Step 1: Onboarding (pengenalan app)
                OnboardingView()
            } else if !isLoggedIn {
                // Step 2: Login / Register
                LoginView()
            } else if !hasCompletedProfile {
                // Step 3: Isi data diri (baru muncul setelah login/register)
                UserProfileSetupView()
            } else {
                // Step 4: Main App — semua sudah lengkap!
                MainTabView()
            }
        }
    }
}
