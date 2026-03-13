//
//  StretchActivityAttributes.swift
//  StretchWidget
//
//  Created by Codex on 13/03/26.
//

import Foundation
import ActivityKit

struct StretchActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var remainingSeconds: Int
        var endDate: Date
        var title: String
        var isPaused: Bool
    }

    var sessionID: String
}
