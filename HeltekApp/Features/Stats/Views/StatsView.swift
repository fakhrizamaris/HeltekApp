//
//  StatsView.swift
//  HeltekApp
//
//  Created by Valentino Hartanto on 11/03/26.
//

import SwiftUI

@MainActor
struct StatsView: View {
    @StateObject private var viewModel = StatsViewModel()
    @State private var chartAnimationID = UUID()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    periodPicker

                    activityCard

                    summarySection

                    streakSection
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
            .background(Color.themeBackground)
            .navigationTitle("Your Progress")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $viewModel.isCalendarPresented) {
                CalendarSheetView(viewModel: viewModel)
                    .presentationDetents([.height(520)])
                    .presentationDragIndicator(.visible)
            }
            .onChange(of: viewModel.selectedPeriod) { _, _ in
                chartAnimationID = UUID()
            }
        }
    }

    private var periodPicker: some View {
        Picker("Period", selection: $viewModel.selectedPeriod) {
            ForEach(StatsPeriod.allCases) { period in
                Text(period.title).tag(period)
            }
        }
        .pickerStyle(.segmented)
    }

    private var activityCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.activityTitle)
                        .font(ThemeFont.caption)
                        .foregroundColor(.textSecondary)

                    HStack(alignment: .lastTextBaseline, spacing: 6) {
                        Text(viewModel.activityMinutesText)
                            .font(ThemeFont.title)
                            .foregroundColor(.textPrimary)

                        Text(viewModel.activityMinutesUnit)
                            .font(ThemeFont.caption)
                            .foregroundColor(.textSecondary)
                    }
                }
            }

            StatsBarChart(entries: viewModel.chartEntries, animateTrigger: chartAnimationID)

            HStack(spacing: 16) {
                Spacer(minLength: 0)
                LegendItem(color: Color.themePrimary, title: "Active")
                LegendItem(color: Color.themePrimary.opacity(0.2), title: "Sedentary")
                Spacer(minLength: 0)
            }
        }
        .padding(16)
        .background(Color.themeSurface)
        .clipShape(RoundedRectangle(cornerRadius: ThemeStyle.cornerRadius, style: .continuous))
        .modifier(CardShadow())
    }

    private var summarySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Summary")
                .font(ThemeFont.bodyBold)
                .foregroundColor(.textPrimary)

            if let first = viewModel.summaryCards.first {
                SummaryCardView(card: first, isCompact: false)
            }

            let remaining = Array(viewModel.summaryCards.dropFirst())
            if !remaining.isEmpty {
                HStack(spacing: 12) {
                    ForEach(remaining) { card in
                        SummaryCardView(card: card, isCompact: true)
                    }
                }
            }
        }
    }

    private var streakSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Streak History")
                    .font(ThemeFont.bodyBold)
                    .foregroundColor(.textPrimary)

                Spacer(minLength: 0)

                Button("View Calendar") {
                    viewModel.isCalendarPresented = true
                }
                .font(ThemeFont.caption)
                .foregroundColor(Color.themePrimary)
            }

            VStack(spacing: 12) {
                ForEach(viewModel.streakHistory) { item in
                    StreakRow(item: item)
                }
            }
        }
    }
}

private struct StatsBarChart: View {
    let entries: [StatsBarEntry]
    let animateTrigger: UUID

    private var maxValue: Int {
        entries.map { max($0.activeMinutes, $0.sedentaryMinutes) }.max() ?? 1
    }

    var body: some View {
        HStack(alignment: .bottom, spacing: 12) {
            ForEach(entries) { entry in
                VStack(spacing: 6) {
                    HStack(alignment: .bottom, spacing: 4) {
                        BarView(value: entry.activeMinutes, maxValue: maxValue, color: Color.themePrimary)
                        BarView(value: entry.sedentaryMinutes, maxValue: maxValue, color: Color.themePrimary.opacity(0.2))
                    }
                    Text(entry.label)
                        .font(ThemeFont.caption)
                        .foregroundColor(.textSecondary)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .frame(height: 140)
        .animation(.easeInOut(duration: 0.3), value: animateTrigger)
    }
}

private struct BarView: View {
    let value: Int
    let maxValue: Int
    let color: Color

    private var barHeight: CGFloat {
        guard maxValue > 0 else { return 0 }
        return CGFloat(value) / CGFloat(maxValue) * 110
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 0)
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(color)
                .frame(width: 10, height: barHeight)

        }
        .frame(height: 110, alignment: .bottom)
    }
}

private struct LegendItem: View {
    let color: Color
    let title: String

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(title)
                .font(ThemeFont.caption)
                .foregroundColor(.textSecondary)
        }
    }
}

private struct SummaryCardView: View {
    let card: StatsSummaryCard
    let isCompact: Bool

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.themePrimaryFaded)
                    .frame(width: 36, height: 36)
                Image(systemName: card.systemImageName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color.themePrimary)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(card.title.uppercased())
                    .font(ThemeFont.caption)
                    .foregroundColor(.textSecondary)

                Text(card.value)
                    .font(ThemeFont.bodyBold)
                    .foregroundColor(.textPrimary)

                Text(card.subtitle)
                    .font(ThemeFont.caption)
                    .foregroundColor(.textSecondary)
            }

            Spacer(minLength: 0)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.themeSurface)
        .clipShape(RoundedRectangle(cornerRadius: ThemeStyle.cornerRadius, style: .continuous))
        .modifier(CardShadow())
        .frame(maxWidth: isCompact ? .infinity : .none)
    }
}

private struct StreakRow: View {
    let item: StreakHistoryItem

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(item.isGoalMet ? Color.green.opacity(0.15) : Color.themeBackground)
                .frame(width: 36, height: 36)
                .overlay(
                    Circle()
                        .stroke(item.isToday ? Color.themePrimary : Color.themeBackground, lineWidth: 1)
                )
                .overlay(
                    Image(systemName: item.isGoalMet ? "checkmark" : "minus")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(item.isGoalMet ? Color.green : Color.textSecondary)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(ThemeFont.bodyBold)
                    .foregroundColor(.textPrimary)

                Text(item.subtitle)
                    .font(ThemeFont.caption)
                    .foregroundColor(.textSecondary)
            }

            Spacer(minLength: 0)

            Text(item.countText)
                .font(ThemeFont.bodyBold)
                .foregroundColor(.textSecondary)
        }
        .padding(12)
        .background(Color.themeSurface)
        .clipShape(RoundedRectangle(cornerRadius: ThemeStyle.cornerRadius, style: .continuous))
        .modifier(CardShadow())
    }
}

private struct CalendarSheetView: View {
    @ObservedObject var viewModel: StatsViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                SimpleCalendarView(
                    selectedDate: $viewModel.selectedDate,
                    displayedMonth: $viewModel.displayedMonth,
                    days: viewModel.calendarDays(for: viewModel.displayedMonth)
                )

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 20)
            .padding(.top, 28)
            .padding(.bottom, 24)
            .background(Color.themeBackground)
            .navigationTitle("Calendar")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

private struct SimpleCalendarView: View {
    @Binding var selectedDate: Date
    @Binding var displayedMonth: Date
    let days: [CalendarDay]

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 7)

    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                Button {
                    shiftMonth(by: -1)
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.textSecondary)
                        .frame(width: 44, height: 44)
                        .background(Color.themeSurface)
                        .clipShape(Circle())
                        .modifier(CardShadow())
                }

                Spacer(minLength: 0)

                Text(monthTitle(for: displayedMonth))
                    .font(ThemeFont.bodyBold)
                    .foregroundColor(.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .center)

                Button {
                    shiftMonth(by: 1)
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.textSecondary)
                        .frame(width: 44, height: 44)
                        .background(Color.themeSurface)
                        .clipShape(Circle())
                        .modifier(CardShadow())
                }

                Spacer(minLength: 0)
            }

            HStack(spacing: 8) {
                ForEach(weekdaySymbols(), id: \.self) { symbol in
                    Text(symbol)
                        .font(ThemeFont.caption)
                        .foregroundColor(.textSecondary)
                        .frame(maxWidth: .infinity)
                }
            }

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(days) { day in
                    CalendarDayCell(
                        day: day,
                        isSelected: Calendar.current.isDate(day.date, inSameDayAs: selectedDate)
                    )
                    .onTapGesture {
                        selectedDate = day.date
                        if !Calendar.current.isDate(day.date, equalTo: displayedMonth, toGranularity: .month) {
                            displayedMonth = day.date
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(Color.themeSurface)
        .clipShape(RoundedRectangle(cornerRadius: ThemeStyle.cornerRadius, style: .continuous))
        .modifier(CardShadow())
    }

    private func monthTitle(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }

    private func weekdaySymbols() -> [String] {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        return formatter.shortWeekdaySymbols.map { $0.uppercased() }
    }

    private func shiftMonth(by value: Int) {
        displayedMonth = Calendar.current.date(byAdding: .month, value: value, to: displayedMonth) ?? displayedMonth
    }
}

private struct CalendarDayCell: View {
    let day: CalendarDay
    let isSelected: Bool

    var body: some View {
        let primaryColor: Color = isSelected ? .white : (day.isCurrentMonth ? .textPrimary : .textSecondary.opacity(0.4))
        let countColor: Color = isSelected ? .white : Color.themePrimary

        VStack(spacing: 4) {
            Text("\(day.dayNumber)")
                .font(ThemeFont.caption)
                .foregroundColor(primaryColor)

            if day.count > 0 {
                Text("\(day.count)x")
                    .font(ThemeFont.caption)
                    .foregroundColor(countColor)
            } else {
                Circle()
                    .fill(Color.themePrimary)
                    .frame(width: 3, height: 3)
                    .opacity(day.isCurrentMonth ? 0.15 : 0.0)
            }
        }
        .frame(height: 36)
        .frame(maxWidth: .infinity)
        .padding(4)
        .background(isSelected ? Color.themePrimary : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.themePrimary.opacity(isSelected ? 0.0 : 0.1), lineWidth: 1)
        )
        .foregroundColor(isSelected ? .white : .textPrimary)
    }
}


private struct CardShadow: ViewModifier {
    func body(content: Content) -> some View {
        ThemeStyle.cardShadow(for: content)
    }
struct StatsView: View {
    var body: some View {
        VStack {
            Text("Ini Stats")
                .font(.largeTitle)
                .fontWeight(.bold)
        }
    }
}

#Preview {
    StatsView()
}
