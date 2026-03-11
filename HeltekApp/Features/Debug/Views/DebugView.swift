//
//  DebugView.swift
//  HeltekApp
//
//  Created by Fakhri Djamaris on 11/03/26.
//
// ⚠️ FILE INI HANYA UNTUK TESTING — HAPUS SEBELUM SUBMIT!
//

import SwiftUI

struct DebugView: View {
    
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                
                // Info status saat ini
                VStack(alignment: .leading, spacing: 12) {
                    Text("Status Saat Ini:")
                        .font(ThemeFont.bodyBold)
                    
                    // Tampilkan nilai AppStorage secara real-time
                    HStack {
                        Circle()
                            .fill(hasSeenOnboarding ? Color.green : Color.red)
                            .frame(width: 10, height: 10)
                        Text("hasSeenOnboarding: \(hasSeenOnboarding ? "true" : "false")")
                            .font(ThemeFont.body)
                    }
                    
                    HStack {
                        Circle()
                            .fill(isLoggedIn ? Color.green : Color.red)
                            .frame(width: 10, height: 10)
                        Text("isLoggedIn: \(isLoggedIn ? "true" : "false")")
                            .font(ThemeFont.body)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.themeBackground)
                .cornerRadius(ThemeStyle.cornerRadius)
                
                Divider()
                
                // Tombol Logout saja (tetap ingat onboarding)
                Button(action: {
                    // Hanya reset login — onboarding tidak perlu diulang
                    isLoggedIn = false
                }) {
                    Text("Logout")
                        .font(ThemeFont.button)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.alertDestructive)
                        .cornerRadius(ThemeStyle.cornerRadius)
                }
                
                // Tombol Reset Total (balik ke splash screen)
                Button(action: {
                    // Reset semua — balik ke halaman splash onboarding
                    isLoggedIn = false
                    hasSeenOnboarding = false
                }) {
                    Text("Reset Total (Balik ke Onboarding)")
                        .font(ThemeFont.button)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.gray)
                        .cornerRadius(ThemeStyle.cornerRadius)
                }
            }
            .padding(24)
            .navigationTitle("Debug Panel")
        }
    }
}

#Preview {
    DebugView()
}
