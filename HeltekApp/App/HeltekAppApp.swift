//
//  HeltekAppApp.swift
//  HeltekApp
//
//  Created by Fakhri Djamaris on 10/03/26.
//


import SwiftUI

@main
struct HeltekAppApp: App {
    
    // AppStorage = localStorage versi iOS
    // Nilainya otomatis tersimpan walau app ditutup
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    
//    init() {
//            // ⚠️ HAPUS 2 BARIS INI SEBELUM SUBMIT KE APPLE DEVELOPER ACADEMY!
//            UserDefaults.standard.removeObject(forKey: "hasSeenOnboarding")
//            UserDefaults.standard.removeObject(forKey: "isLoggedIn")
//    }

    var body: some Scene {
        WindowGroup {
            // Ini seperti "conditional rendering" di React
            if !hasSeenOnboarding {
                // Belum pernah onboarding → tampilkan layar onboarding
                OnboardingView()
            } else if !isLoggedIn {
                // Sudah onboarding tapi belum login
                LoginView()
            } else {
                // Sudah login → masuk ke app utama
                MainTabView()
            }
        }
    }
}
