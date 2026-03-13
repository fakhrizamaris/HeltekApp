//
//  StatsViewModel.swift
//  HeltekApp
//
//  Created by Valentino Hartanto on 11/03/26.
//

import Foundation
import Combine

@MainActor
final class StatsViewModel: ObservableObject {
    @Published var selectedPeriod: StatsPeriod = .weekly
    @Published var selectedDate: Date = Date()
    @Published var displayedMonth: Date = Date()
    @Published var isCalendarPresented: Bool = false

    private let repository: StatsRepository

    let activityTitle = "Activity vs. Sedentary"
    let activityMinutesText = "320"
    let activityMinutesUnit = "min"

    @Published private(set) var summaryCards: [StatsSummaryCard] = []
    @Published private(set) var streakHistory: [StreakHistoryItem] = []
    @Published private(set) var calendarCounts: [Date: Int] = [:]

    var chartEntries: [StatsBarEntry] {
        switch selectedPeriod {
        case .daily:
            return dummyDailyChart
        case .weekly:
            return dummyWeeklyChart
        case .monthly:
            return dummyMonthlyChart
        }
    }

    private let calendar = Calendar.current

    init(repository: StatsRepository = MockStatsRepository()) {
        self.repository = repository
        Task {
            await load()
        }
    }

    func load() async {
        // Ready for backend integration: replace repository with API implementation.
        let summary = await repository.fetchSummaryCards()
        let history = await repository.fetchStreakHistory()
        let counts = await repository.fetchCalendarCounts()

        if summary.isEmpty {
            summaryCards = dummySummaryCards
        } else {
            summaryCards = summary
        }

        if history.isEmpty {
            streakHistory = dummyStreakHistory
        } else {
            streakHistory = history
        }

        if counts.isEmpty {
            calendarCounts = dummyCalendarCounts
        } else {
            calendarCounts = counts
        }
    }

    func calendarDays(for monthDate: Date) -> [CalendarDay] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: monthDate),
              let monthStartWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start) else {
            return []
        }

        var days: [CalendarDay] = []
        var currentDate = monthStartWeek.start
        for _ in 0..<42 {
            let isCurrentMonth = calendar.isDate(currentDate, equalTo: monthDate, toGranularity: .month)
            let dayNumber = calendar.component(.day, from: currentDate)
            let count = calendarCounts[calendar.startOfDay(for: currentDate)] ?? 0
            days.append(CalendarDay(date: currentDate, dayNumber: dayNumber, isCurrentMonth: isCurrentMonth, count: count))
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        return days
    }

    // MARK: - Dummy Data (Remove when API ready)
    private var dummySummaryCards: [StatsSummaryCard] {
        [
            StatsSummaryCard(
                title: "Global Ranking",
                value: "Rank #1,250",
                subtitle: "Top 5%",
                systemImageName: "trophy.fill"
            ),
            StatsSummaryCard(
                title: "Total Exercises",
                value: "24",
                subtitle: "Last 7 days",
                systemImageName: "figure.walk"
            ),
            StatsSummaryCard(
                title: "Current Streak",
                value: "14 days",
                subtitle: "Keep it up",
                systemImageName: "bolt.fill"
            )
        ]
    }

    private var dummyStreakHistory: [StreakHistoryItem] {
        let today = calendar.startOfDay(for: Date())
        return [
            StreakHistoryItem(
                date: today,
                goalCount: 5,
                actualCount: 2
            ),
            StreakHistoryItem(
                date: calendar.date(byAdding: .day, value: -1, to: today) ?? today,
                goalCount: 5,
                actualCount: 9
            ),
            StreakHistoryItem(
                date: calendar.date(byAdding: .day, value: -2, to: today) ?? today,
                goalCount: 5,
                actualCount: 1
            )
        ]
    }

    private var dummyDailyChart: [StatsBarEntry] {
        [
            StatsBarEntry(label: "M", activeMinutes: 30, sedentaryMinutes: 20),
            StatsBarEntry(label: "T", activeMinutes: 45, sedentaryMinutes: 25),
            StatsBarEntry(label: "W", activeMinutes: 25, sedentaryMinutes: 30),
            StatsBarEntry(label: "T", activeMinutes: 40, sedentaryMinutes: 18),
            StatsBarEntry(label: "F", activeMinutes: 55, sedentaryMinutes: 22),
            StatsBarEntry(label: "S", activeMinutes: 20, sedentaryMinutes: 15),
            StatsBarEntry(label: "S", activeMinutes: 35, sedentaryMinutes: 25)
        ]
    }

    private var dummyWeeklyChart: [StatsBarEntry] {
        [
            StatsBarEntry(label: "W1", activeMinutes: 210, sedentaryMinutes: 140),
            StatsBarEntry(label: "W2", activeMinutes: 260, sedentaryMinutes: 160),
            StatsBarEntry(label: "W3", activeMinutes: 180, sedentaryMinutes: 120),
            StatsBarEntry(label: "W4", activeMinutes: 320, sedentaryMinutes: 190)
        ]
    }

    private var dummyMonthlyChart: [StatsBarEntry] {
        [
            StatsBarEntry(label: "Jan", activeMinutes: 820, sedentaryMinutes: 520),
            StatsBarEntry(label: "Feb", activeMinutes: 760, sedentaryMinutes: 480),
            StatsBarEntry(label: "Mar", activeMinutes: 900, sedentaryMinutes: 560),
            StatsBarEntry(label: "Apr", activeMinutes: 680, sedentaryMinutes: 450),
            StatsBarEntry(label: "May", activeMinutes: 990, sedentaryMinutes: 610),
            StatsBarEntry(label: "Jun", activeMinutes: 870, sedentaryMinutes: 540)
        ]
    }

    private var dummyCalendarCounts: [Date: Int] {
        let today = calendar.startOfDay(for: Date())
        return [
            today: 2,
            calendar.date(byAdding: .day, value: -1, to: today) ?? today: 7,
            calendar.date(byAdding: .day, value: -2, to: today) ?? today: 14
        ]
    }
}

protocol StatsRepository {
    func fetchSummaryCards() async -> [StatsSummaryCard]
    func fetchStreakHistory() async -> [StreakHistoryItem]
    func fetchCalendarCounts() async -> [Date: Int]
}

struct MockStatsRepository: StatsRepository {
    func fetchSummaryCards() async -> [StatsSummaryCard] {
        []
    }

    func fetchStreakHistory() async -> [StreakHistoryItem] {
        []
    }

    func fetchCalendarCounts() async -> [Date: Int] {
        [:]
    }
}
