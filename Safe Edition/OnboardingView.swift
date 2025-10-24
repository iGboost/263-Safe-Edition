//
//  OnboardingView.swift
//  Fortune Tiger
//
//  Onboarding flow with 5 screens
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var appState: AppState
    @State private var currentPage = 0

    let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "pawprint.fill",
            title: "Unleash Your Inner Strength",
            description: "Welcome to Fortune Tiger, your companion for building discipline and achieving daily goals with the power of the tiger spirit.",
            color: AppTheme.Colors.primary
        ),
        OnboardingPage(
            icon: "target",
            title: "Set Daily Goals",
            description: "Create meaningful habits and set ambitious goals that align with your vision of personal growth.",
            color: AppTheme.Colors.secondary
        ),
        OnboardingPage(
            icon: "chart.line.uptrend.xyaxis",
            title: "Track Your Progress",
            description: "Monitor your journey with detailed insights and celebrate every milestone along the way.",
            color: AppTheme.Colors.success
        ),
        OnboardingPage(
            icon: "calendar.badge.checkmark",
            title: "Stay Consistent Every Day",
            description: "Build unstoppable momentum through daily commitment and watch your streaks grow stronger.",
            color: AppTheme.Colors.info
        ),
        OnboardingPage(
            icon: "star.fill",
            title: "Celebrate Your Achievements",
            description: "Recognize your progress and use it as fuel to push yourself even further on your path to excellence.",
            color: AppTheme.Colors.warning
        )
    ]

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    AppTheme.Colors.backgroundLight,
                    pages[currentPage].color.opacity(0.2)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Page Content
                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                        OnboardingPageView(page: page)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                // Bottom Section
                VStack(spacing: AppTheme.Spacing.lg) {
                    // Page Indicator
                    HStack(spacing: 8) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            Circle()
                                .fill(index == currentPage ? AppTheme.Colors.primary : Color.gray.opacity(0.3))
                                .frame(width: 8, height: 8)
                                .scaleEffect(index == currentPage ? 1.2 : 1.0)
                                .animation(.spring(), value: currentPage)
                        }
                    }

                    // Action Buttons
                    VStack(spacing: AppTheme.Spacing.md) {
                        if currentPage == pages.count - 1 {
                            PrimaryButton(title: "Get Started", action: {
                                appState.completeOnboarding()
                            })
                        } else {
                            PrimaryButton(title: "Next", action: {
                                withAnimation {
                                    currentPage += 1
                                }
                            })
                        }

                        if currentPage < pages.count - 1 {
                            Button(action: {
                                appState.completeOnboarding()
                            }) {
                                Text("Skip")
                                    .font(AppTheme.Typography.body)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .padding(AppTheme.Spacing.lg)
                .background(Color(.systemBackground).opacity(0.95))
            }
        }
    }
}

// MARK: - Onboarding Page Model
struct OnboardingPage {
    let icon: String
    let title: String
    let description: String
    let color: Color
}

// MARK: - Onboarding Page View
struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: AppTheme.Spacing.xl) {
            Spacer()

            // Icon with animated background
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [page.color.opacity(0.3), page.color.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 200, height: 200)

                Image(systemName: page.icon)
                    .font(.system(size: 80))
                    .foregroundColor(page.color)
            }

            Spacer()

            // Text Content
            VStack(spacing: AppTheme.Spacing.md) {
                Text(page.title)
                    .font(AppTheme.Typography.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .foregroundColor(AppTheme.Colors.textPrimary)

                Text(page.description)
                    .font(AppTheme.Typography.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, AppTheme.Spacing.xl)
            }

            Spacer()
        }
        .padding(AppTheme.Spacing.lg)
    }
}
