//
//  HomeView.swift
//  Fortune Tiger
//
//  Home screen with overview and quick actions
//

import SwiftUI

struct HomeView: View {
    @StateObject private var habitStorage = HabitStorage.shared
    @StateObject private var goalStorage = GoalStorage.shared

    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.Spacing.lg) {
                // Header
                CustomNavigationBar(title: "Safe Edition")

                VStack(spacing: AppTheme.Spacing.xl) {
                    // Welcome Section
                    WelcomeCard()

                    // Quick Stats
                    QuickStatsSection(
                        habitStorage: habitStorage,
                        goalStorage: goalStorage
                    )

                    // Today's Habits Preview
                    TodayHabitsSection(habitStorage: habitStorage)

                    // Active Goals Preview
                    ActiveGoalsSection(goalStorage: goalStorage)

                    // Motivational Quote
                    MotivationalQuoteCard()
                }
                .padding(.horizontal, AppTheme.Spacing.md)
                .padding(.bottom, 80) // Space for tab bar
            }
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }
}

// MARK: - Welcome Card
struct WelcomeCard: View {
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12:
            return "Good Morning"
        case 12..<17:
            return "Good Afternoon"
        default:
            return "Good Evening"
        }
    }

    var body: some View {
        CardView {
            HStack(spacing: AppTheme.Spacing.md) {
                Image(systemName: "pawprint.fill")
                    .font(.system(size: 48))
                    .foregroundColor(AppTheme.Colors.primary)

                VStack(alignment: .leading, spacing: 4) {
                    Text(greeting)
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(.secondary)

                    Text("Ready to conquer today?")
                        .font(AppTheme.Typography.title3)
                        .fontWeight(.bold)
                }

                Spacer()
            }
        }
    }
}

// MARK: - Quick Stats Section
struct QuickStatsSection: View {
    @ObservedObject var habitStorage: HabitStorage
    @ObservedObject var goalStorage: GoalStorage

    var completedToday: Int {
        habitStorage.habits.filter { $0.isCompletedToday() }.count
    }

    var totalHabits: Int {
        habitStorage.habits.count
    }

    var activeGoals: Int {
        goalStorage.goals.filter { !$0.isCompleted }.count
    }

    var completedGoals: Int {
        goalStorage.goals.filter { $0.isCompleted }.count
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("Today's Overview")
                .font(AppTheme.Typography.title3)
                .fontWeight(.bold)

            HStack(spacing: AppTheme.Spacing.md) {
                StatCard(
                    icon: "checkmark.circle.fill",
                    value: "\(completedToday)/\(totalHabits)",
                    label: "Habits",
                    color: AppTheme.Colors.success
                )

                StatCard(
                    icon: "target",
                    value: "\(activeGoals)",
                    label: "Active Goals",
                    color: AppTheme.Colors.primary
                )

                StatCard(
                    icon: "star.fill",
                    value: "\(completedGoals)",
                    label: "Completed",
                    color: AppTheme.Colors.secondary
                )
            }
        }
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        CardView {
            VStack(spacing: AppTheme.Spacing.xs) {
                Image(systemName: icon)
                    .font(.system(size: 28))
                    .foregroundColor(color)

                Text(value)
                    .font(AppTheme.Typography.title2)
                    .fontWeight(.bold)

                Text(label)
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Today Habits Section
struct TodayHabitsSection: View {
    @ObservedObject var habitStorage: HabitStorage

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            HStack {
                Text("Today's Habits")
                    .font(AppTheme.Typography.title3)
                    .fontWeight(.bold)

                Spacer()

                Text("Tap to complete")
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(.secondary)
            }

            if habitStorage.habits.isEmpty {
                EmptyStateView(
                    icon: "checkmark.circle",
                    title: "No Habits Yet",
                    message: "Create your first habit in the Tracker tab"
                )
            } else {
                ForEach(habitStorage.habits.prefix(3)) { habit in
                    HabitCard(
                        habit: .constant(habit),
                        onToggle: {
                            if let index = habitStorage.habits.firstIndex(where: { $0.id == habit.id }) {
                                habitStorage.habits[index].toggleToday()
                                habitStorage.saveHabits()
                            }
                        }
                    )
                }
            }
        }
    }
}

// MARK: - Active Goals Section
struct ActiveGoalsSection: View {
    @ObservedObject var goalStorage: GoalStorage

    var activeGoals: [Goal] {
        goalStorage.goals.filter { !$0.isCompleted }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("Active Goals")
                .font(AppTheme.Typography.title3)
                .fontWeight(.bold)

            if activeGoals.isEmpty {
                EmptyStateView(
                    icon: "target",
                    title: "No Active Goals",
                    message: "Set your first goal in the Goals tab"
                )
            } else {
                ForEach(activeGoals.prefix(2)) { goal in
                    GoalCard(goal: goal)
                }
            }
        }
    }
}

// MARK: - Motivational Quote Card
struct MotivationalQuoteCard: View {
    let quotes = [
        "The tiger does not lose sleep over the opinion of sheep.",
        "Strength grows in the moments when you think you can't go on.",
        "Every accomplishment starts with the decision to try.",
        "Discipline is choosing between what you want now and what you want most.",
        "Small daily improvements lead to stunning results."
    ]

    private var randomQuote: String {
        quotes.randomElement() ?? quotes[0]
    }

    var body: some View {
        CardView {
            HStack(spacing: AppTheme.Spacing.md) {
                Image(systemName: "quote.opening")
                    .font(.system(size: 24))
                    .foregroundColor(AppTheme.Colors.primary.opacity(0.5))

                Text(randomQuote)
                    .font(AppTheme.Typography.callout)
                    .italic()
                    .foregroundColor(.secondary)

                Spacer()
            }
        }
    }
}
