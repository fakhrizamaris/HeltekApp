//
//  Database.swift
//  HeltekApp
//
//  Created by Fakhri Djamaris on 10/03/26.
//

import Foundation
import SwiftData

@Model
class DailyProgress{
    var date: Date
    var completedStretches: Int = 0
    var isGoalMet: Bool = false
    
    var lastUpdated: Date
    
    
    init(date: Date = Date(), lastUpdated: Date = Date()) {
        self.date = date
        self.lastUpdated = lastUpdated
    }
}
