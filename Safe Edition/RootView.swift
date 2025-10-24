//
//  RootView.swift
//  Fortune Tiger
//
//  Root navigation coordinator
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        Group {
            if appState.isLoading {
                LoadingView()
            } else if !appState.hasCompletedOnboarding {
                OnboardingView()
            } else {
                MainTabView()
            }
        }
        .animation(.easeInOut, value: appState.isLoading)
        .animation(.easeInOut, value: appState.hasCompletedOnboarding)
    }
}
