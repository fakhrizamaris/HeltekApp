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

    init(repository: StatsRepository? = nil) {
        self.repository = repository ?? FirebaseStatsRepository()
        
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
            let rawEntries = await repository.fetchChartData(period: period)
            
            // 1. LAKUKAN PADDING DATA DI SINI
            self.chartEntries = padChartData(entries: rawEntries, for: period)
            
            // 2. Hitung total tetap dari rawEntries (biar lebih aman)
            let totalActive = rawEntries.reduce(0) { $0 + $1.activeMinutes }
            self.activityMinutesText = "\(totalActive)"
    }

    // TAMBAHKAN FUNGSI HELPER INI
    // Fungsi ini bertugas mengisi kekosongan data dengan nilai 0
    private func padChartData(entries: [StatsChartEntry], for period: StatsPeriod) -> [StatsChartEntry] {
        // Tentukan template label sumbu X yang harus selalu ada
        // Catatan: Sesuaikan string ini dengan format kembalian "label" dari FirebaseStatsRepository kamu.
        let defaultLabels: [String]
        
        switch period {
        case .daily:
            // Contoh jika daily itu menampilkan 7 hari terakhir
            defaultLabels = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        case .weekly:
            // Contoh jika weekly menampilkan minggu 1 sampai 4
            defaultLabels = ["W1", "W2", "W3", "W4"]
        case .monthly:
            // Contoh jika monthly menampilkan bulan
            defaultLabels = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        }
        
        // Ubah data asli menjadi Dictionary agar mudah dicari
        let entriesDict = Dictionary(entries.map { ($0.label, $0) }, uniquingKeysWith: { (first, _) in first })
        
        // Buat array baru yang terjamin berurutan sesuai defaultLabels
        return defaultLabels.map { label in
            if let existingEntry = entriesDict[label] {
                return existingEntry // Jika hari/bulan itu user aktif, pakai data asli
            } else {
                // Jika user tidak aktif, buat data dummy bernilai 0
                return StatsChartEntry(label: label, activeMinutes: 0)
            }
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
