//
//  Models.swift
//  Fortune Tiger
//
//  Data models for habits, goals, and focus sessions
//

import Foundation
import Combine

// MARK: - Habit Model
struct Habit: Identifiable, Codable {
    let id: UUID
    var name: String
    var icon: String
    var completedDates: [String] // Date strings in "yyyy-MM-dd" format
    var createdAt: Date

    init(id: UUID = UUID(), name: String, icon: String, completedDates: [String] = [], createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.icon = icon
        self.completedDates = completedDates
        self.createdAt = createdAt
    }

    func isCompletedToday() -> Bool {
        let today = Date().toDateString()
        return completedDates.contains(today)
    }

    mutating func toggleToday() {
        let today = Date().toDateString()
        if let index = completedDates.firstIndex(of: today) {
            completedDates.remove(at: index)
        } else {
            completedDates.append(today)
        }
    }

    var currentStreak: Int {
        var streak = 0
        var date = Date()
        let calendar = Calendar.current

        while completedDates.contains(date.toDateString()) {
            streak += 1
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: date) else { break }
            date = previousDay
        }

        return streak
    }
}

// MARK: - Goal Model
struct Goal: Identifiable, Codable {
    let id: UUID
    var title: String
    var description: String
    var targetValue: Int
    var currentValue: Int
    var unit: String
    var createdAt: Date

    init(id: UUID = UUID(), title: String, description: String, targetValue: Int, currentValue: Int = 0, unit: String, createdAt: Date = Date()) {
        self.id = id
        self.title = title
        self.description = description
        self.targetValue = targetValue
        self.currentValue = currentValue
        self.unit = unit
        self.createdAt = createdAt
    }

    var progress: Double {
        guard targetValue > 0 else { return 0 }
        return Double(currentValue) / Double(targetValue)
    }

    var isCompleted: Bool {
        currentValue >= targetValue
    }
}

// MARK: - Focus Session Model
struct FocusSession: Identifiable, Codable {
    let id: UUID
    var duration: Int // in minutes
    var completedAt: Date

    init(id: UUID = UUID(), duration: Int, completedAt: Date = Date()) {
        self.id = id
        self.duration = duration
        self.completedAt = completedAt
    }
}

// MARK: - Date Extension
extension Date {
    func toDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: self)
    }
}

// MARK: - Habit Storage
class HabitStorage: ObservableObject {
    static let shared = HabitStorage()

    @Published var habits: [Habit] = []

    private let storageKey = "saved_habits"

    init() {
        loadHabits()
    }

    func loadHabits() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([Habit].self, from: data) {
            habits = decoded
        } else {
            // Create default habits
            habits = [
                Habit(name: "Morning Exercise", icon: "figure.run"),
                Habit(name: "Read 30 Minutes", icon: "book.fill"),
                Habit(name: "Meditation", icon: "leaf.fill"),
                Habit(name: "Drink Water", icon: "drop.fill")
            ]
            saveHabits()
        }
    }

    func saveHabits() {
        if let encoded = try? JSONEncoder().encode(habits) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }

    func addHabit(_ habit: Habit) {
        habits.append(habit)
        saveHabits()
    }

    func deleteHabit(_ habit: Habit) {
        habits.removeAll { $0.id == habit.id }
        saveHabits()
    }

    func updateHabit(_ habit: Habit) {
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            habits[index] = habit
            saveHabits()
        }
    }

    func clearAll() {
        habits.removeAll()
        saveHabits()
    }
}

// MARK: - Goal Storage
class GoalStorage: ObservableObject {
    static let shared = GoalStorage()

    @Published var goals: [Goal] = []

    private let storageKey = "saved_goals"

    init() {
        loadGoals()
    }

    func loadGoals() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([Goal].self, from: data) {
            goals = decoded
        } else {
            // Create default goals
            goals = [
                Goal(title: "Complete 30 Days Challenge", description: "Build consistency for 30 consecutive days", targetValue: 30, currentValue: 0, unit: "days")
            ]
            saveGoals()
        }
    }

    func saveGoals() {
        if let encoded = try? JSONEncoder().encode(goals) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }

    func addGoal(_ goal: Goal) {
        goals.append(goal)
        saveGoals()
    }

    func deleteGoal(_ goal: Goal) {
        goals.removeAll { $0.id == goal.id }
        saveGoals()
    }

    func updateGoal(_ goal: Goal) {
        if let index = goals.firstIndex(where: { $0.id == goal.id }) {
            goals[index] = goal
            saveGoals()
        }
    }

    func clearAll() {
        goals.removeAll()
        saveGoals()
    }
}

// MARK: - Focus Session Storage
class FocusSessionStorage: ObservableObject {
    static let shared = FocusSessionStorage()

    @Published var sessions: [FocusSession] = []

    private let storageKey = "saved_focus_sessions"

    init() {
        loadSessions()
    }

    func loadSessions() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([FocusSession].self, from: data) {
            sessions = decoded
        }
    }

    func saveSessions() {
        if let encoded = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }

    func addSession(_ session: FocusSession) {
        sessions.append(session)
        saveSessions()
    }

    func clearAll() {
        sessions.removeAll()
        saveSessions()
    }
}
