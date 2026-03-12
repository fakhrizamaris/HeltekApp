//
//  HeltekAppApp.swift
//  HeltekApp
//
//  Created by Fakhri Djamaris on 10/03/26.
//

import SwiftUI

@main
struct HeltekAppApp: App {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @AppStorage("isLoggedIn") private var isLoggedIn = false

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
