//
//  LeaderboardModel.swift
//  HeltekApp
//
//  Created by Muhammad Ammar Farisi on 11/03/26.
//

import Foundation

struct Player: Identifiable {
    let id: String
    let name: String
    let points: Int
    let avatarName: String
    let occupation: String
    var trend: RankTrend = .neutral
    var isCurrentUser: Bool = false
}

enum RankTrend {
    case up, down, neutral
}
