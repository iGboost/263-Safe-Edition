//
//  CommonUI.swift
//  Fortune Tiger
//
//  Reusable UI components
//

import SwiftUI

// MARK: - Primary Button
struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var style: ButtonStyle = .primary

    enum ButtonStyle {
        case primary
        case secondary
        case outline
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppTheme.Typography.headline)
                .foregroundColor(textColor)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(backgroundColor)
                .cornerRadius(AppTheme.CornerRadius.md)
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                        .stroke(borderColor, lineWidth: style == .outline ? 2 : 0)
                )
        }
    }

    private var backgroundColor: Color {
        switch style {
        case .primary:
            return AppTheme.Colors.primary
        case .secondary:
            return AppTheme.Colors.secondary
        case .outline:
            return Color.clear
        }
    }

    private var textColor: Color {
        switch style {
        case .primary, .secondary:
            return .white
        case .outline:
            return AppTheme.Colors.primary
        }
    }

    private var borderColor: Color {
        switch style {
        case .outline:
            return AppTheme.Colors.primary
        default:
            return Color.clear
        }
    }
}

// MARK: - Card View
struct CardView<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(AppTheme.Spacing.md)
            .background(Color(.systemBackground))
            .cornerRadius(AppTheme.CornerRadius.lg)
            .shadow(color: AppTheme.Shadow.light, radius: 8, x: 0, y: 4)
    }
}

// MARK: - Progress Circle
struct ProgressCircle: View {
    let progress: Double
    let size: CGFloat
    let lineWidth: CGFloat
    let color: Color

    init(progress: Double, size: CGFloat = 120, lineWidth: CGFloat = 12, color: Color = AppTheme.Colors.primary) {
        self.progress = progress
        self.size = size
        self.lineWidth = lineWidth
        self.color = color
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.2), lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: min(progress, 1.0))
                .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut, value: progress)

            VStack(spacing: 4) {
                Text("\(Int(progress * 100))%")
                    .font(AppTheme.Typography.title2)
                    .fontWeight(.bold)
            }
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Custom Navigation Bar
struct CustomNavigationBar: View {
    let title: String
    var showBackButton: Bool = false
    var onBack: (() -> Void)?

    var body: some View {
        HStack {
            if showBackButton {
                Button(action: { onBack?() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(AppTheme.Colors.primary)
                }
            }

            HStack(spacing: 8) {
                Image(systemName: "pawprint.fill")
                    .font(.system(size: 24))
                    .foregroundColor(AppTheme.Colors.primary)

                Text(title)
                    .font(AppTheme.Typography.title2)
                    .fontWeight(.bold)
            }

            Spacer()
        }
        .padding(.horizontal, AppTheme.Spacing.md)
        .padding(.vertical, AppTheme.Spacing.sm)
        .background(Color(.systemBackground).opacity(0.95))
    }
}

// MARK: - Empty State View
struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Image(systemName: icon)
                .font(.system(size: 64))
                .foregroundColor(AppTheme.Colors.primary.opacity(0.5))

            VStack(spacing: AppTheme.Spacing.xs) {
                Text(title)
                    .font(AppTheme.Typography.title2)
                    .fontWeight(.bold)

                Text(message)
                    .font(AppTheme.Typography.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            if let actionTitle = actionTitle, let action = action {
                PrimaryButton(title: actionTitle, action: action)
                    .frame(maxWidth: 200)
            }
        }
        .padding(AppTheme.Spacing.xl)
    }
}

// MARK: - Habit Card
struct HabitCard: View {
    @Binding var habit: Habit
    let onToggle: () -> Void

    var body: some View {
        CardView {
            HStack(spacing: AppTheme.Spacing.md) {
                Image(systemName: habit.icon)
                    .font(.system(size: 28))
                    .foregroundColor(AppTheme.Colors.primary)
                    .frame(width: 44, height: 44)
                    .background(AppTheme.Colors.primary.opacity(0.1))
                    .cornerRadius(AppTheme.CornerRadius.sm)

                VStack(alignment: .leading, spacing: 4) {
                    Text(habit.name)
                        .font(AppTheme.Typography.headline)

                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 12))
                            .foregroundColor(AppTheme.Colors.secondary)
                        Text("\(habit.currentStreak) day streak")
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                Button(action: onToggle) {
                    Image(systemName: habit.isCompletedToday() ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 32))
                        .foregroundColor(habit.isCompletedToday() ? AppTheme.Colors.success : Color.gray.opacity(0.3))
                }
            }
        }
    }
}

// MARK: - Goal Card
struct GoalCard: View {
    let goal: Goal

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

                    if goal.isCompleted {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 28))
                            .foregroundColor(AppTheme.Colors.success)
                    }
                }

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
            }
        }
    }
}

// MARK: - Loading Spinner
struct LoadingSpinner: View {
    @State private var isAnimating = false

    var body: some View {
        Circle()
            .trim(from: 0, to: 0.7)
            .stroke(AppTheme.Colors.primary, lineWidth: 4)
            .frame(width: 40, height: 40)
            .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
            .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false), value: isAnimating)
            .onAppear {
                isAnimating = true
            }
    }
}
