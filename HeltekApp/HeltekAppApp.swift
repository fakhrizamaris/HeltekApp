//
//  HeltekAppApp.swift
//  HeltekApp
//
//  Created by Fakhri Djamaris on 10/03/26.
//

import SwiftUI
import SwiftData

@main
struct HeltekAppApp: App {

    var body: some Scene {
        WindowGroup {
            DebugDataView()
        }
        .modelContainer(DailyProgress.self)
    }
}
