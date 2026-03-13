//
//  LeaderboardModel.swift
//  HeltekApp
//
//  Created by Muhammad Ammar Farisi on 11/03/26.
//

import Foundation

struct Player: Identifiable {
    let id = UUID()
    let name: String
    let streakDays: Int
    let avatarName: String
    let globalRank: Int
}
