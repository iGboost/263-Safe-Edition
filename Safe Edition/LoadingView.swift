//
//  LoadingView.swift
//  Fortune Tiger
//
//  Loading screen with remote config check (disabled)
//

import SwiftUI

struct LoadingView: View {
    @EnvironmentObject var appState: AppState
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 1.0

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    AppTheme.Colors.primary.opacity(0.3),
                    AppTheme.Colors.secondary.opacity(0.2),
                    AppTheme.Colors.backgroundLight
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: AppTheme.Spacing.xl) {
                Spacer()

                // Animated Tiger Icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    AppTheme.Colors.primary.opacity(0.3),
                                    AppTheme.Colors.secondary.opacity(0.2)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 150, height: 150)
                        .scaleEffect(scale)

                    Image(systemName: "pawprint.fill")
                        .font(.system(size: 64))
                        .foregroundColor(AppTheme.Colors.primary)
                        .rotationEffect(.degrees(rotation))
                }

                // App Name
                VStack(spacing: AppTheme.Spacing.xs) {
                    Text("Fortune Tiger")
                        .font(AppTheme.Typography.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.Colors.primary)

                    Text("Daily Strength Tracker")
                        .font(AppTheme.Typography.callout)
                        .foregroundColor(.secondary)
                }

                Spacer()

                // Loading Indicator
                LoadingSpinner()
                    .padding(.bottom, AppTheme.Spacing.xxl)
            }
        }
        .onAppear {
            startAnimations()
            checkRemoteConfig()
        }
    }

    private func startAnimations() {
        // Rotation animation
        withAnimation(Animation.linear(duration: 3).repeatForever(autoreverses: false)) {
            rotation = 360
        }

        // Scale animation
        withAnimation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            scale = 1.1
        }
    }

    private func checkRemoteConfig() {
        // Remote config check - Always returns disabled
        // This method simulates checking a remote configuration
        // In a real app, this would check Firebase Remote Config or similar service

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            let remoteConfigEnabled = false // Always disabled for Safe Edition

            if remoteConfigEnabled {
                // WebView would open here if enabled
                // This path is never reached in Safe Edition
                print("Remote config enabled - not implemented")
            }

            // Always proceed to main app after delay
            withAnimation {
                appState.isLoading = false
            }
        }
    }
}

// MARK: - Remote Config Manager (Disabled)
class RemoteConfigManager {
    static let shared = RemoteConfigManager()

    private init() {}

    func fetchConfig(completion: @escaping (Bool, String?) -> Void) {
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            // Always return disabled for Safe Edition
            completion(false, nil)
        }
    }

    var isWebViewEnabled: Bool {
        // Always disabled in Safe Edition
        return false
    }

    var webViewURL: String? {
        // No URL in Safe Edition
        return nil
    }
}
