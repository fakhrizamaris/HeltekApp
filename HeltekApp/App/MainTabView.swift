//
//  MainTabView.swift
//  HeltekApp
//
//  Created by Valentino Hartanto on 11/03/26.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("HOME", systemImage: "house")
                }
            
            ExercisePlanView()
                .tabItem {
                    Label("PLANS", systemImage: "calendar")
                }
            
            StatsView()
                .tabItem {
                    Label("STATS", systemImage: "chart.bar.fill")
                }
            
            LeaderboardView()
                .tabItem {
                    Label("Leaderboard", systemImage: "trophy")
                }
            
            DebugView()
                .tabItem {
                    Label("Debug", systemImage: "wrench.fill")
                }
        }
        .tint(Color.themePrimary)
    }
}

#Preview {
    MainTabView()
}
