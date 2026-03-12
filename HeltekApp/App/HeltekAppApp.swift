//
//  HeltekAppApp.swift
//  HeltekApp
//

import SwiftUI
import FirebaseCore

@main
struct HeltekAppApp: App {
    
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    
    init() {
        FirebaseApp.configure()
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
