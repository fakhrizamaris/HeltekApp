//
//  HeltekAppApp.swift
//  HeltekApp
////  Created by Fakhri Djamaris on 10/03/26.
//
//  Created by Fakhri Djamaris on 10/03/26.
//

import SwiftUI
import FirebaseCore
import TipKit

@main
struct HeltekAppApp: App {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    
    
    
    @AppStorage("hasCompletedProfile") private var hasCompletedProfile = false
    
    
    init() {
        FirebaseApp.configure()
        try? Tips.configure([
            .displayFrequency(.immediate),
            .datastoreLocation(.applicationDefault)
        ])
    }
    var body: some Scene {
        WindowGroup {
            Group {
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
                    // Step 4: Main App - semua sudah lengkap!
                    MainTabView()
                }
            }
            .onOpenURL { url in
                guard url.scheme == "heltekapp", url.host == "stop-timer" else { return }
                Task { @MainActor in
                    WidgetSyncManager.shared.handleStopFromWidget()
                }
            }
        }
    }
}
