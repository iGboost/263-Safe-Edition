//
//  MainTabView.swift
//  Fortune Tiger
//
//  Main tab navigation with custom tab bar
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        ZStack(alignment: .bottom) {
            // Tab Content
            Group {
                switch selectedTab {
                case 0:
                    HomeView()
                case 1:
                    TrackerView()
                case 2:
                    FocusView()
                case 3:
                    StatsView()
                case 4:
                    SettingsView()
                default:
                    HomeView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Custom Tab Bar
            CustomTabBar(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(.keyboard)
    }
}

// MARK: - Custom Tab Bar
struct CustomTabBar: View {
    @Binding var selectedTab: Int

    let tabs: [TabItem] = [
        TabItem(icon: "house.fill", title: "Home", tag: 0),
        TabItem(icon: "checkmark.circle.fill", title: "Tracker", tag: 1),
        TabItem(icon: "timer", title: "Focus", tag: 2),
        TabItem(icon: "chart.bar.fill", title: "Stats", tag: 3),
        TabItem(icon: "gearshape.fill", title: "Settings", tag: 4)
    ]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabs) { tab in
                TabBarButton(
                    icon: tab.icon,
                    title: tab.title,
                    isSelected: selectedTab == tab.tag
                ) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = tab.tag
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.vertical, 8)
        .background(
            Color(.systemBackground)
                .shadow(color: AppTheme.Shadow.medium, radius: 8, x: 0, y: -4)
        )
    }
}

// MARK: - Tab Item Model
struct TabItem: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let tag: Int
}

// MARK: - Tab Bar Button
struct TabBarButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? AppTheme.Colors.primary : .gray)
                    .scaleEffect(isSelected ? 1.1 : 1.0)

                Text(title)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(isSelected ? AppTheme.Colors.primary : .gray)
            }
            .padding(.vertical, 8)
        }
    }
}
