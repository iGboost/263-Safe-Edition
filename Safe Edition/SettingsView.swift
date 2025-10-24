//
//  SettingsView.swift
//  Fortune Tiger
//
//  App settings and preferences
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var habitStorage = HabitStorage.shared
    @StateObject private var goalStorage = GoalStorage.shared
    @StateObject private var sessionStorage = FocusSessionStorage.shared
    
    @State private var showResetAlert = false
    @State private var showClearDataAlert = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.Spacing.lg) {
                // Header
                CustomNavigationBar(title: "Settings")
                
                VStack(spacing: AppTheme.Spacing.xl) {
                    // App Info Section
                    AppInfoSection()
                    
                    // Appearance Section
                    AppearanceSection()
                    
                    // Data Management Section
                    DataManagementSection(
                        showClearDataAlert: $showClearDataAlert
                    )
                    
                    // About Section
                    AboutSection()
                    
                    // Reset App Section
                    ResetAppSection(showResetAlert: $showResetAlert)
                }
                .padding(.horizontal, AppTheme.Spacing.md)
                .padding(.bottom, 80)
            }
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .alert("Clear All Data", isPresented: $showClearDataAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Clear", role: .destructive) {
                clearAllData()
            }
        } message: {
            Text("This will delete all your habits, goals, and focus sessions. This action cannot be undone.")
        }
        .alert("Reset App", isPresented: $showResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                appState.resetApp()
            }
        } message: {
            Text("This will reset the app and show the onboarding again. All your data will be deleted.")
        }
    }
    
    private func clearAllData() {
        habitStorage.clearAll()
        goalStorage.clearAll()
        sessionStorage.clearAll()
    }
}

// MARK: - App Info Section
struct AppInfoSection: View {
    var body: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            // App Icon and Name
            VStack(spacing: AppTheme.Spacing.md) {
                Image(systemName: "pawprint.fill")
                    .font(.system(size: 64))
                    .foregroundColor(AppTheme.Colors.primary)
                    .frame(width: 100, height: 100)
                    .background(
                        Circle()
                            .fill(AppTheme.Colors.primary.opacity(0.1))
                    )
                
                VStack(spacing: 4) {
                    Text("Fortune Tiger")
                        .font(AppTheme.Typography.title2)
                        .fontWeight(.bold)
                    
                    Text("Daily Strength Tracker")
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

// MARK: - Appearance Section
struct AppearanceSection: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("Appearance")
                .font(AppTheme.Typography.title3)
                .fontWeight(.bold)
            
            CardView {
                HStack {
                    Image(systemName: appState.isDarkMode ? "moon.fill" : "sun.max.fill")
                        .font(.system(size: 24))
                        .foregroundColor(AppTheme.Colors.primary)
                        .frame(width: 32)
                    
                    Text("Dark Mode")
                        .font(AppTheme.Typography.body)
                    
                    Spacer()
                    
                    Toggle("", isOn: Binding(
                        get: { appState.isDarkMode },
                        set: { _ in appState.toggleTheme() }
                    ))
                    .labelsHidden()
                }
            }
        }
    }
}

// MARK: - Data Management Section
struct DataManagementSection: View {
    @Binding var showClearDataAlert: Bool
    @StateObject private var habitStorage = HabitStorage.shared
    @StateObject private var goalStorage = GoalStorage.shared
    @StateObject private var sessionStorage = FocusSessionStorage.shared
    
    var totalHabits: Int {
        habitStorage.habits.count
    }
    
    var totalGoals: Int {
        goalStorage.goals.count
    }
    
    var totalSessions: Int {
        sessionStorage.sessions.count
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("Data")
                .font(AppTheme.Typography.title3)
                .fontWeight(.bold)
            
            CardView {
                VStack(spacing: AppTheme.Spacing.md) {
                    DataRow(icon: "checkmark.circle.fill", label: "Habits", value: "\(totalHabits)")
                    Divider()
                    DataRow(icon: "target", label: "Goals", value: "\(totalGoals)")
                    Divider()
                    DataRow(icon: "clock.fill", label: "Focus Sessions", value: "\(totalSessions)")
                }
            }
            
            Button(action: {
                showClearDataAlert = true
            }) {
                HStack {
                    Image(systemName: "trash.fill")
                    Text("Clear All Data")
                }
                .font(AppTheme.Typography.callout)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(AppTheme.Colors.error)
                .cornerRadius(AppTheme.CornerRadius.sm)
            }
        }
    }
}

// MARK: - Data Row
struct DataRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(AppTheme.Colors.primary)
                .frame(width: 24)
            
            Text(label)
                .font(AppTheme.Typography.body)
            
            Spacer()
            
            Text(value)
                .font(AppTheme.Typography.body)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - About Section
struct AboutSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("About")
                .font(AppTheme.Typography.title3)
                .fontWeight(.bold)
            
            CardView {
                VStack(spacing: AppTheme.Spacing.md) {
                    AboutRow(icon: "info.circle.fill", label: "Version", value: "1.0.0")
                    Divider()
                    AboutRow(icon: "person.fill", label: "Developer", value: "Fortune Tiger Team")
                }
            }
        }
    }
}

// MARK: - About Row
struct AboutRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(AppTheme.Colors.primary)
                .frame(width: 24)
            
            Text(label)
                .font(AppTheme.Typography.body)
            
            Spacer()
            
            Text(value)
                .font(AppTheme.Typography.body)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Reset App Section
struct ResetAppSection: View {
    @Binding var showResetAlert: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("Advanced")
                .font(AppTheme.Typography.title3)
                .fontWeight(.bold)
            
            Button(action: {
                showResetAlert = true
            }) {
                HStack {
                    Image(systemName: "arrow.clockwise.circle.fill")
                    Text("Reset App & Show Onboarding")
                }
                .font(AppTheme.Typography.callout)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(AppTheme.Colors.warning)
                .cornerRadius(AppTheme.CornerRadius.sm)
            }
        }
        
        Text("Made with 💪 for building discipline")
            .font(AppTheme.Typography.caption)
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.top, AppTheme.Spacing.md)
    }
}

