//
//  FortuneTigerApp.swift
//  Fortune Tiger
//
//  Main app entry point
//

import SwiftUI
import Combine


@main
struct FortuneTigerApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
                .preferredColorScheme(appState.isDarkMode ? .dark : .light)
        }
    }
}

// MARK: - App State Manager
class AppState: ObservableObject {
    @Published var hasCompletedOnboarding: Bool
    @Published var isDarkMode: Bool
    @Published var isLoading: Bool = true

    init() {
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        self.isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
    }

    func completeOnboarding() {
        hasCompletedOnboarding = true
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
    }

    func toggleTheme() {
        isDarkMode.toggle()
        UserDefaults.standard.set(isDarkMode, forKey: "isDarkMode")
    }

    func resetApp() {
        hasCompletedOnboarding = false
        UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")

        // Clear all data
        HabitStorage.shared.clearAll()
        GoalStorage.shared.clearAll()
    }
}
