//
//  TrackerView.swift
//  Fortune Tiger
//
//  Habit tracking and management
//

import SwiftUI

struct TrackerView: View {
    @StateObject private var habitStorage = HabitStorage.shared
    @State private var showAddHabit = false

    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.Spacing.lg) {
                // Header
                CustomNavigationBar(title: "Habit Tracker")

                VStack(spacing: AppTheme.Spacing.xl) {
                    // Stats Header
                    TrackerStatsHeader(habitStorage: habitStorage)

                    // Habits List
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                        HStack {
                            Text("My Habits")
                                .font(AppTheme.Typography.title3)
                                .fontWeight(.bold)

                            Spacer()

                            Button(action: { showAddHabit = true }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Add")
                                }
                                .font(AppTheme.Typography.callout)
                                .foregroundColor(AppTheme.Colors.primary)
                            }
                        }

                        if habitStorage.habits.isEmpty {
                            EmptyStateView(
                                icon: "checkmark.circle",
                                title: "No Habits Yet",
                                message: "Start building consistency by adding your first habit",
                                actionTitle: "Add Habit",
                                action: { showAddHabit = true }
                            )
                            .padding(.vertical, AppTheme.Spacing.xxl)
                        } else {
                            ForEach($habitStorage.habits) { $habit in
                                HabitCard(habit: $habit, onToggle: {
                                    habit.toggleToday()
                                    habitStorage.saveHabits()
                                })
                                .contextMenu {
                                    Button(role: .destructive) {
                                        habitStorage.deleteHabit(habit)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.md)
                .padding(.bottom, 80)
            }
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .sheet(isPresented: $showAddHabit) {
            AddHabitSheet(habitStorage: habitStorage)
        }
    }
}

// MARK: - Tracker Stats Header
struct TrackerStatsHeader: View {
    @ObservedObject var habitStorage: HabitStorage

    var completedToday: Int {
        habitStorage.habits.filter { $0.isCompletedToday() }.count
    }

    var totalHabits: Int {
        habitStorage.habits.count
    }

    var completionRate: Double {
        guard totalHabits > 0 else { return 0 }
        return Double(completedToday) / Double(totalHabits)
    }

    var longestStreak: Int {
        habitStorage.habits.map { $0.currentStreak }.max() ?? 0
    }

    var body: some View {
        CardView {
            VStack(spacing: AppTheme.Spacing.lg) {
                HStack(spacing: AppTheme.Spacing.xl) {
                    // Progress Circle
                    ProgressCircle(
                        progress: completionRate,
                        size: 100,
                        lineWidth: 10
                    )

                    VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Today's Progress")
                                .font(AppTheme.Typography.caption)
                                .foregroundColor(.secondary)

                            Text("\(completedToday) / \(totalHabits) completed")
                                .font(AppTheme.Typography.headline)
                        }

                        Divider()

                        HStack(spacing: 4) {
                            Image(systemName: "flame.fill")
                                .foregroundColor(AppTheme.Colors.secondary)
                            Text("\(longestStreak) day streak")
                                .font(AppTheme.Typography.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }

                    Spacer()
                }
            }
        }
    }
}

// MARK: - Add Habit Sheet
struct AddHabitSheet: View {
    @ObservedObject var habitStorage: HabitStorage
    @Environment(\.dismiss) var dismiss

    @State private var habitName = ""
    @State private var selectedIcon = "star.fill"

    let availableIcons = [
        "star.fill", "heart.fill", "figure.run", "book.fill",
        "drop.fill", "leaf.fill", "moon.fill", "sun.max.fill",
        "flame.fill", "bolt.fill", "sparkles", "cup.and.saucer.fill"
    ]

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Habit Details")) {
                    TextField("Habit name", text: $habitName)
                }

                Section(header: Text("Choose Icon")) {
                    LazyVGrid(columns: [
                        GridItem(.adaptive(minimum: 60))
                    ], spacing: AppTheme.Spacing.md) {
                        ForEach(availableIcons, id: \.self) { icon in
                            Button(action: {
                                selectedIcon = icon
                            }) {
                                VStack {
                                    Image(systemName: icon)
                                        .font(.system(size: 32))
                                        .foregroundColor(selectedIcon == icon ? AppTheme.Colors.primary : .gray)
                                        .frame(width: 60, height: 60)
                                        .background(
                                            selectedIcon == icon ?
                                            AppTheme.Colors.primary.opacity(0.1) :
                                            Color.gray.opacity(0.1)
                                        )
                                        .cornerRadius(AppTheme.CornerRadius.sm)
                                }
                            }
                        }
                    }
                    .padding(.vertical, AppTheme.Spacing.sm)
                }
            }
            .navigationTitle("New Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        addHabit()
                    }
                    .disabled(habitName.isEmpty)
                }
            }
        }
    }

    private func addHabit() {
        let habit = Habit(name: habitName, icon: selectedIcon)
        habitStorage.addHabit(habit)
        dismiss()
    }
}
