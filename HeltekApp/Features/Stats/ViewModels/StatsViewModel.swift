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

    let activityTitle = "Active Minutes"
    @Published var activityMinutesText = "0"
    let activityMinutesUnit = "min"

    @Published private(set) var summaryCards: [StatsSummaryCard] = []
    @Published private(set) var streakHistory: [StreakHistoryItem] = []
    @Published private(set) var calendarCounts: [Date: Int] = [:]
    
    @Published private(set) var chartEntries: [StatsChartEntry] = []

    private let calendar = Calendar.current
    private var cancellables = Set<AnyCancellable>()

    init(repository: StatsRepository = FirebaseStatsRepository()) {
        self.repository = repository
        
        $selectedPeriod
            .dropFirst()
            .sink { [weak self] period in
                guard let self = self else { return }
                Task {
                    await self.loadChartData(for: period)
                }
            }
            .store(in: &cancellables)
    }

    func load() async {
        let summary = await repository.fetchSummaryCards()
        let history = await repository.fetchStreakHistory()
        let counts = await repository.fetchCalendarCounts()
        
        summaryCards = summary
        streakHistory = history
        calendarCounts = counts
        
        await loadChartData(for: selectedPeriod)
    }

    func loadChartData(for period: StatsPeriod) async {
        let entries = await repository.fetchChartData(period: period)
        self.chartEntries = entries
        
        let totalActive = entries.reduce(0) { $0 + $1.activeMinutes }
        self.activityMinutesText = "\(totalActive)"
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
}

protocol StatsRepository {
    func fetchSummaryCards() async -> [StatsSummaryCard]
    func fetchStreakHistory() async -> [StreakHistoryItem]
    func fetchCalendarCounts() async -> [Date: Int]
    func fetchChartData(period: StatsPeriod) async -> [StatsChartEntry]
}

struct MockStatsRepository: StatsRepository {
    func fetchSummaryCards() async -> [StatsSummaryCard] { [] }
    func fetchStreakHistory() async -> [StreakHistoryItem] { [] }
    func fetchCalendarCounts() async -> [Date: Int] { [:] }
    func fetchChartData(period: StatsPeriod) async -> [StatsChartEntry] { [] }
}
