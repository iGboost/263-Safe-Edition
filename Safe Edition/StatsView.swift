//
//  StatsView.swift
//  Fortune Tiger
//
//  Statistics and insights dashboard
//

import SwiftUI
import Charts

struct StatsView: View {
    @StateObject private var habitStorage = HabitStorage.shared
    @StateObject private var goalStorage = GoalStorage.shared
    @StateObject private var sessionStorage = FocusSessionStorage.shared

    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.Spacing.lg) {
                // Header
                CustomNavigationBar(title: "Statistics")

                VStack(spacing: AppTheme.Spacing.xl) {
                    // Overview Stats
                    OverviewStatsSection(
                        habitStorage: habitStorage,
                        goalStorage: goalStorage,
                        sessionStorage: sessionStorage
                    )

                    // Habits Completion Chart
                    HabitsChartSection(habitStorage: habitStorage)

                    // Goals Progress
                    GoalsProgressSection(goalStorage: goalStorage)

                    // Focus Time Chart
                    FocusTimeChartSection(sessionStorage: sessionStorage)

                    // Achievements
                    AchievementsSection(
                        habitStorage: habitStorage,
                        sessionStorage: sessionStorage
                    )
                }
                .padding(.horizontal, AppTheme.Spacing.md)
                .padding(.bottom, 80)
            }
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }
}

// MARK: - Overview Stats Section
struct OverviewStatsSection: View {
    @ObservedObject var habitStorage: HabitStorage
    @ObservedObject var goalStorage: GoalStorage
    @ObservedObject var sessionStorage: FocusSessionStorage

    var totalHabitsCompleted: Int {
        habitStorage.habits.reduce(0) { $0 + $1.completedDates.count }
    }

    var totalFocusMinutes: Int {
        sessionStorage.sessions.reduce(0) { $0 + $1.duration }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("Overall Progress")
                .font(AppTheme.Typography.title3)
                .fontWeight(.bold)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: AppTheme.Spacing.md) {
                OverviewCard(
                    icon: "checkmark.circle.fill",
                    value: "\(totalHabitsCompleted)",
                    label: "Total Completions",
                    color: AppTheme.Colors.success
                )

                OverviewCard(
                    icon: "target",
                    value: "\(goalStorage.goals.count)",
                    label: "Goals Set",
                    color: AppTheme.Colors.primary
                )

                OverviewCard(
                    icon: "clock.fill",
                    value: "\(totalFocusMinutes)",
                    label: "Focus Minutes",
                    color: AppTheme.Colors.info
                )

                OverviewCard(
                    icon: "flame.fill",
                    value: "\(habitStorage.habits.map { $0.currentStreak }.max() ?? 0)",
                    label: "Best Streak",
                    color: AppTheme.Colors.secondary
                )
            }
        }
    }
}

// MARK: - Overview Card
struct OverviewCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        CardView {
            VStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 32))
                    .foregroundColor(color)

                Text(value)
                    .font(AppTheme.Typography.title)
                    .fontWeight(.bold)

                Text(label)
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppTheme.Spacing.sm)
        }
    }
}

// MARK: - Habits Chart Section
struct HabitsChartSection: View {
    @ObservedObject var habitStorage: HabitStorage

    var last7DaysData: [(date: String, count: Int)] {
        let calendar = Calendar.current
        let today = Date()

        return (0..<7).reversed().map { daysAgo in
            guard let date = calendar.date(byAdding: .day, value: -daysAgo, to: today) else {
                return (date: "", count: 0)
            }

            let dateString = date.toDateString()
            let count = habitStorage.habits.filter { habit in
                habit.completedDates.contains(dateString)
            }.count

            let formatter = DateFormatter()
            formatter.dateFormat = "E"
            return (date: formatter.string(from: date), count: count)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("Last 7 Days Activity")
                .font(AppTheme.Typography.title3)
                .fontWeight(.bold)

            CardView {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                    if #available(iOS 16.0, *) {
                        Chart {
                            ForEach(last7DaysData, id: \.date) { item in
                                BarMark(
                                    x: .value("Day", item.date),
                                    y: .value("Completed", item.count)
                                )
                                .foregroundStyle(AppTheme.Colors.primary.gradient)
                                .cornerRadius(4)
                            }
                        }
                        .frame(height: 200)
                        .chartYAxis {
                            AxisMarks(position: .leading)
                        }
                    } else {
                        // Fallback for iOS 15
                        VStack(spacing: 8) {
                            ForEach(last7DaysData, id: \.date) { item in
                                HStack {
                                    Text(item.date)
                                        .font(AppTheme.Typography.caption)
                                        .frame(width: 40, alignment: .leading)

                                    GeometryReader { geometry in
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(AppTheme.Colors.primary)
                                            .frame(
                                                width: max(20, CGFloat(item.count) * (geometry.size.width / 10)),
                                                height: 24
                                            )
                                    }

                                    Text("\(item.count)")
                                        .font(AppTheme.Typography.caption)
                                        .frame(width: 30)
                                }
                            }
                        }
                        .frame(height: 200)
                    }
                }
            }
        }
    }
}

// MARK: - Goals Progress Section
struct GoalsProgressSection: View {
    @ObservedObject var goalStorage: GoalStorage

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("Goals Overview")
                .font(AppTheme.Typography.title3)
                .fontWeight(.bold)

            if goalStorage.goals.isEmpty {
                EmptyStateView(
                    icon: "target",
                    title: "No Goals Yet",
                    message: "Start tracking goals to see progress here"
                )
            } else {
                ForEach(goalStorage.goals.prefix(5)) { goal in
                    GoalProgressRow(goal: goal)
                }
            }
        }
    }
}

// MARK: - Goal Progress Row
struct GoalProgressRow: View {
    let goal: Goal

    var body: some View {
        CardView {
            VStack(spacing: AppTheme.Spacing.sm) {
                HStack {
                    Text(goal.title)
                        .font(AppTheme.Typography.body)
                        .fontWeight(.medium)

                    Spacer()

                    Text("\(Int(goal.progress * 100))%")
                        .font(AppTheme.Typography.caption)
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.Colors.primary)
                }

                ProgressView(value: goal.progress)
                    .tint(goal.isCompleted ? AppTheme.Colors.success : AppTheme.Colors.primary)
            }
        }
    }
}

// MARK: - Focus Time Chart Section
struct FocusTimeChartSection: View {
    @ObservedObject var sessionStorage: FocusSessionStorage

    var last7DaysFocus: [(date: String, minutes: Int)] {
        let calendar = Calendar.current
        let today = Date()

        return (0..<7).reversed().map { daysAgo in
            guard let date = calendar.date(byAdding: .day, value: -daysAgo, to: today) else {
                return (date: "", minutes: 0)
            }

            let minutes = sessionStorage.sessions
                .filter { calendar.isDate($0.completedAt, inSameDayAs: date) }
                .reduce(0) { $0 + $1.duration }

            let formatter = DateFormatter()
            formatter.dateFormat = "E"
            return (date: formatter.string(from: date), minutes: minutes)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("Focus Time Trend")
                .font(AppTheme.Typography.title3)
                .fontWeight(.bold)

            CardView {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                    if #available(iOS 16.0, *) {
                        Chart {
                            ForEach(last7DaysFocus, id: \.date) { item in
                                LineMark(
                                    x: .value("Day", item.date),
                                    y: .value("Minutes", item.minutes)
                                )
                                .foregroundStyle(AppTheme.Colors.info.gradient)
                                .lineStyle(StrokeStyle(lineWidth: 3))

                                AreaMark(
                                    x: .value("Day", item.date),
                                    y: .value("Minutes", item.minutes)
                                )
                                .foregroundStyle(AppTheme.Colors.info.opacity(0.2).gradient)
                            }
                        }
                        .frame(height: 180)
                        .chartYAxis {
                            AxisMarks(position: .leading)
                        }
                    } else {
                        // Fallback for iOS 15
                        VStack(spacing: 8) {
                            ForEach(last7DaysFocus, id: \.date) { item in
                                HStack {
                                    Text(item.date)
                                        .font(AppTheme.Typography.caption)
                                        .frame(width: 40, alignment: .leading)

                                    GeometryReader { geometry in
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(AppTheme.Colors.info)
                                            .frame(
                                                width: max(20, CGFloat(item.minutes) * (geometry.size.width / 100)),
                                                height: 24
                                            )
                                    }

                                    Text("\(item.minutes)m")
                                        .font(AppTheme.Typography.caption)
                                        .frame(width: 40)
                                }
                            }
                        }
                        .frame(height: 180)
                    }
                }
            }
        }
    }
}

// MARK: - Achievements Section
struct AchievementsSection: View {
    @ObservedObject var habitStorage: HabitStorage
    @ObservedObject var sessionStorage: FocusSessionStorage

    var achievements: [Achievement] {
        var result: [Achievement] = []

        // Habit achievements
        let totalCompletions = habitStorage.habits.reduce(0) { $0 + $1.completedDates.count }
        if totalCompletions >= 10 {
            result.append(Achievement(icon: "star.fill", title: "10 Day Champion", color: AppTheme.Colors.secondary))
        }
        if totalCompletions >= 50 {
            result.append(Achievement(icon: "crown.fill", title: "50 Day Master", color: AppTheme.Colors.secondary))
        }

        // Streak achievements
        let bestStreak = habitStorage.habits.map { $0.currentStreak }.max() ?? 0
        if bestStreak >= 7 {
            result.append(Achievement(icon: "flame.fill", title: "7 Day Streak", color: AppTheme.Colors.primary))
        }

        // Focus achievements
        let totalFocus = sessionStorage.sessions.reduce(0) { $0 + $1.duration }
        if totalFocus >= 120 {
            result.append(Achievement(icon: "clock.fill", title: "2 Hour Focus", color: AppTheme.Colors.info))
        }

        return result
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("Achievements")
                .font(AppTheme.Typography.title3)
                .fontWeight(.bold)

            if achievements.isEmpty {
                CardView {
                    VStack(spacing: AppTheme.Spacing.sm) {
                        Image(systemName: "trophy")
                            .font(.system(size: 32))
                            .foregroundColor(.secondary)

                        Text("Keep going to unlock achievements!")
                            .font(AppTheme.Typography.body)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppTheme.Spacing.lg)
                }
            } else {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: AppTheme.Spacing.md) {
                    ForEach(achievements) { achievement in
                        AchievementCard(achievement: achievement)
                    }
                }
            }
        }
    }
}

// MARK: - Achievement Model
struct Achievement: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let color: Color
}

// MARK: - Achievement Card
struct AchievementCard: View {
    let achievement: Achievement

    var body: some View {
        CardView {
            VStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: achievement.icon)
                    .font(.system(size: 36))
                    .foregroundColor(achievement.color)

                Text(achievement.title)
                    .font(AppTheme.Typography.caption)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppTheme.Spacing.sm)
        }
    }
}
