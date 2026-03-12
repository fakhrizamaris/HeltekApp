//
//  StatsModels.swift
//  HeltekApp
//
//  Created by Valentino Hartanto on 11/03/26.
//

import Foundation

struct StatsSummaryCard: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let value: String
    let subtitle: String
    let systemImageName: String
}

struct StatsBarEntry: Identifiable, Hashable {
    let id = UUID()
    let label: String
    let activeMinutes: Int
    let sedentaryMinutes: Int
}

struct StreakHistoryItem: Identifiable, Hashable {
    let id = UUID()
    let date: Date
    let goalCount: Int
    let actualCount: Int

    var title: String {
        if Calendar.current.isDateInToday(date) {
            return "Today, \(StreakHistoryItem.shortDateFormatter.string(from: date))"
        }
        if Calendar.current.isDateInYesterday(date) {
            return "Yesterday, \(StreakHistoryItem.shortDateFormatter.string(from: date))"
        }
        return StreakHistoryItem.fullDateFormatter.string(from: date)
    }

    var subtitle: String {
        "Goal: \(goalCount)x Exercises"
    }

    var countText: String {
        "\(actualCount)x"
    }

    var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }

    var isGoalMet: Bool {
        actualCount >= goalCount
    }

    private static let shortDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter
    }()

    private static let fullDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter
    }()
}

struct CalendarDay: Identifiable, Hashable {
    let id = UUID()
    let date: Date
    let dayNumber: Int
    let isCurrentMonth: Bool
    let count: Int
}

enum StatsPeriod: String, CaseIterable, Identifiable {
    case daily
    case weekly
    case monthly

    var id: String { rawValue }

    var title: String {
        switch self {
        case .daily: return "Daily"
        case .weekly: return "Weekly"
        case .monthly: return "Monthly"
        }
    }
}
