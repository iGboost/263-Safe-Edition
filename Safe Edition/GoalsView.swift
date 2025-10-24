//
//  GoalsView.swift
//  Fortune Tiger
//
//  Goal setting and progress tracking
//

import SwiftUI

struct GoalsView: View {
    @StateObject private var goalStorage = GoalStorage.shared
    @State private var showAddGoal = false

    var activeGoals: [Goal] {
        goalStorage.goals.filter { !$0.isCompleted }
    }

    var completedGoals: [Goal] {
        goalStorage.goals.filter { $0.isCompleted }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.Spacing.lg) {
                // Header
                CustomNavigationBar(title: "Goals")

                VStack(spacing: AppTheme.Spacing.xl) {
                    // Goals Stats
                    GoalsStatsCard(
                        activeCount: activeGoals.count,
                        completedCount: completedGoals.count
                    )

                    // Active Goals
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                        HStack {
                            Text("Active Goals")
                                .font(AppTheme.Typography.title3)
                                .fontWeight(.bold)

                            Spacer()

                            Button(action: { showAddGoal = true }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Add")
                                }
                                .font(AppTheme.Typography.callout)
                                .foregroundColor(AppTheme.Colors.primary)
                            }
                        }

                        if activeGoals.isEmpty {
                            EmptyStateView(
                                icon: "target",
                                title: "No Active Goals",
                                message: "Set ambitious goals and track your progress",
                                actionTitle: "Add Goal",
                                action: { showAddGoal = true }
                            )
                            .padding(.vertical, AppTheme.Spacing.xxl)
                        } else {
                            ForEach(activeGoals) { goal in
                                GoalDetailCard(goal: goal, goalStorage: goalStorage)
                            }
                        }
                    }

                    // Completed Goals
                    if !completedGoals.isEmpty {
                        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                            Text("Completed Goals")
                                .font(AppTheme.Typography.title3)
                                .fontWeight(.bold)

                            ForEach(completedGoals) { goal in
                                GoalCard(goal: goal)
                                    .opacity(0.7)
                                    .contextMenu {
                                        Button(role: .destructive) {
                                            goalStorage.deleteGoal(goal)
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
        .sheet(isPresented: $showAddGoal) {
            AddGoalSheet(goalStorage: goalStorage)
        }
    }
}

// MARK: - Goals Stats Card
struct GoalsStatsCard: View {
    let activeCount: Int
    let completedCount: Int

    var body: some View {
        CardView {
            HStack(spacing: AppTheme.Spacing.xl) {
                StatColumn(
                    icon: "target",
                    value: "\(activeCount)",
                    label: "Active",
                    color: AppTheme.Colors.primary
                )

                Divider()
                    .frame(height: 60)

                StatColumn(
                    icon: "checkmark.seal.fill",
                    value: "\(completedCount)",
                    label: "Completed",
                    color: AppTheme.Colors.success
                )

                Spacer()
            }
        }
    }
}

// MARK: - Stat Column
struct StatColumn: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundColor(color)

            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(AppTheme.Typography.title)
                    .fontWeight(.bold)

                Text(label)
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Goal Detail Card
struct GoalDetailCard: View {
    let goal: Goal
    @ObservedObject var goalStorage: GoalStorage

    @State private var showUpdateSheet = false

    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(goal.title)
                            .font(AppTheme.Typography.headline)

                        Text(goal.description)
                            .font(AppTheme.Typography.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }

                    Spacer()
                }

                // Progress Section
                VStack(alignment: .leading, spacing: 8) {
                    ProgressView(value: goal.progress)
                        .tint(AppTheme.Colors.primary)

                    HStack {
                        Text("\(goal.currentValue) / \(goal.targetValue) \(goal.unit)")
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(.secondary)

                        Spacer()

                        Text("\(Int(goal.progress * 100))%")
                            .font(AppTheme.Typography.caption)
                            .fontWeight(.bold)
                            .foregroundColor(AppTheme.Colors.primary)
                    }
                }

                // Action Buttons
                HStack(spacing: AppTheme.Spacing.sm) {
                    Button(action: { showUpdateSheet = true }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Update Progress")
                        }
                        .font(AppTheme.Typography.callout)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(AppTheme.Colors.primary)
                        .cornerRadius(AppTheme.CornerRadius.sm)
                    }

                    Button(action: {
                        goalStorage.deleteGoal(goal)
                    }) {
                        Image(systemName: "trash")
                            .font(AppTheme.Typography.callout)
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(AppTheme.Colors.error)
                            .cornerRadius(AppTheme.CornerRadius.sm)
                    }
                }
            }
        }
        .sheet(isPresented: $showUpdateSheet) {
            UpdateGoalSheet(goal: goal, goalStorage: goalStorage)
        }
    }
}

// MARK: - Add Goal Sheet
struct AddGoalSheet: View {
    @ObservedObject var goalStorage: GoalStorage
    @Environment(\.dismiss) var dismiss

    @State private var title = ""
    @State private var description = ""
    @State private var targetValue = ""
    @State private var unit = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Goal Details")) {
                    TextField("Goal title", text: $title)
                    TextField("Description", text: $description)
                }

                Section(header: Text("Target")) {
                    TextField("Target value (number)", text: $targetValue)
                        .keyboardType(.numberPad)
                    TextField("Unit (e.g., days, hours, pages)", text: $unit)
                }
            }
            .navigationTitle("New Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        addGoal()
                    }
                    .disabled(!isValid)
                }
            }
        }
    }

    private var isValid: Bool {
        !title.isEmpty && !description.isEmpty &&
        !targetValue.isEmpty && !unit.isEmpty &&
        Int(targetValue) != nil
    }

    private func addGoal() {
        guard let target = Int(targetValue) else { return }
        let goal = Goal(
            title: title,
            description: description,
            targetValue: target,
            unit: unit
        )
        goalStorage.addGoal(goal)
        dismiss()
    }
}

// MARK: - Update Goal Sheet
struct UpdateGoalSheet: View {
    let goal: Goal
    @ObservedObject var goalStorage: GoalStorage
    @Environment(\.dismiss) var dismiss

    @State private var incrementValue = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Current Progress")) {
                    HStack {
                        Text("Current:")
                        Spacer()
                        Text("\(goal.currentValue) / \(goal.targetValue) \(goal.unit)")
                            .foregroundColor(.secondary)
                    }
                }

                Section(header: Text("Add Progress")) {
                    TextField("Amount to add", text: $incrementValue)
                        .keyboardType(.numberPad)
                }
            }
            .navigationTitle("Update Progress")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Update") {
                        updateGoal()
                    }
                    .disabled(incrementValue.isEmpty || Int(incrementValue) == nil)
                }
            }
        }
    }

    private func updateGoal() {
        guard let increment = Int(incrementValue) else { return }
        var updatedGoal = goal
        updatedGoal.currentValue = min(goal.currentValue + increment, goal.targetValue)
        goalStorage.updateGoal(updatedGoal)
        dismiss()
    }
}
