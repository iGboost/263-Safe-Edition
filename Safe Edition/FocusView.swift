//
//  FocusView.swift
//  Fortune Tiger
//
//  Pomodoro-style focus timer
//

import SwiftUI
import Combine


struct FocusView: View {
    @StateObject private var timerManager = FocusTimerManager()
    @StateObject private var sessionStorage = FocusSessionStorage.shared

    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.Spacing.lg) {
                // Header
                CustomNavigationBar(title: "Focus Timer")

                VStack(spacing: AppTheme.Spacing.xl) {
                    // Timer Display
                    TimerDisplayView(timerManager: timerManager)

                    // Timer Controls
                    TimerControlsView(timerManager: timerManager, sessionStorage: sessionStorage)

                    // Duration Presets
                    DurationPresetsView(timerManager: timerManager)

                    // Today's Sessions
                    TodaySessionsView(sessionStorage: sessionStorage)
                }
                .padding(.horizontal, AppTheme.Spacing.md)
                .padding(.bottom, 80)
            }
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }
}

// MARK: - Focus Timer Manager
class FocusTimerManager: ObservableObject {
    @Published var timeRemaining: Int = 1500 // 25 minutes in seconds
    @Published var isRunning = false
    @Published var selectedDuration: Int = 1500

    private var timer: Timer?

    func start() {
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.complete()
            }
        }
    }

    func pause() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }

    func reset() {
        pause()
        timeRemaining = selectedDuration
    }

    func complete() {
        pause()
        timeRemaining = 0
    }

    func setDuration(_ seconds: Int) {
        selectedDuration = seconds
        timeRemaining = seconds
        pause()
    }

    var progress: Double {
        guard selectedDuration > 0 else { return 0 }
        return Double(selectedDuration - timeRemaining) / Double(selectedDuration)
    }

    var formattedTime: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// MARK: - Timer Display View
struct TimerDisplayView: View {
    @ObservedObject var timerManager: FocusTimerManager

    var body: some View {
        CardView {
            VStack(spacing: AppTheme.Spacing.lg) {
                // Timer Circle
                ZStack {
                    Circle()
                        .stroke(AppTheme.Colors.primary.opacity(0.2), lineWidth: 20)

                    Circle()
                        .trim(from: 0, to: timerManager.progress)
                        .stroke(
                            AppTheme.Colors.primary,
                            style: StrokeStyle(lineWidth: 20, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .animation(.linear, value: timerManager.progress)

                    VStack(spacing: 8) {
                        Text(timerManager.formattedTime)
                            .font(.system(size: 56, weight: .bold, design: .rounded))
                            .foregroundColor(AppTheme.Colors.primary)

                        Text(timerManager.isRunning ? "Focus Mode" : "Ready")
                            .font(AppTheme.Typography.callout)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(width: 280, height: 280)

                // Status Message
                if timerManager.timeRemaining == 0 {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(AppTheme.Colors.success)
                        Text("Session completed! Great work!")
                            .font(AppTheme.Typography.body)
                    }
                    .padding()
                    .background(AppTheme.Colors.success.opacity(0.1))
                    .cornerRadius(AppTheme.CornerRadius.sm)
                }
            }
            .padding(.vertical, AppTheme.Spacing.lg)
        }
    }
}

// MARK: - Timer Controls View
struct TimerControlsView: View {
    @ObservedObject var timerManager: FocusTimerManager
    @ObservedObject var sessionStorage: FocusSessionStorage

    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            if timerManager.isRunning {
                // Pause Button
                Button(action: {
                    timerManager.pause()
                }) {
                    HStack {
                        Image(systemName: "pause.fill")
                        Text("Pause")
                    }
                    .font(AppTheme.Typography.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(AppTheme.Colors.warning)
                    .cornerRadius(AppTheme.CornerRadius.md)
                }
            } else {
                // Start Button
                Button(action: {
                    if timerManager.timeRemaining == 0 {
                        timerManager.reset()
                    }
                    timerManager.start()
                }) {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("Start")
                    }
                    .font(AppTheme.Typography.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(AppTheme.Colors.success)
                    .cornerRadius(AppTheme.CornerRadius.md)
                }
            }

            // Reset Button
            Button(action: {
                timerManager.reset()
            }) {
                Image(systemName: "arrow.clockwise")
                    .font(AppTheme.Typography.headline)
                    .foregroundColor(.white)
                    .frame(width: 56, height: 56)
                    .background(AppTheme.Colors.accent)
                    .cornerRadius(AppTheme.CornerRadius.md)
            }
        }
    }
}

// MARK: - Duration Presets View
struct DurationPresetsView: View {
    @ObservedObject var timerManager: FocusTimerManager

    let presets: [(name: String, duration: Int)] = [
        ("5 min", 300),
        ("15 min", 900),
        ("25 min", 1500),
        ("50 min", 3000)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("Duration Presets")
                .font(AppTheme.Typography.title3)
                .fontWeight(.bold)

            HStack(spacing: AppTheme.Spacing.sm) {
                ForEach(presets, id: \.name) { preset in
                    Button(action: {
                        timerManager.setDuration(preset.duration)
                    }) {
                        Text(preset.name)
                            .font(AppTheme.Typography.callout)
                            .fontWeight(.medium)
                            .foregroundColor(
                                timerManager.selectedDuration == preset.duration ?
                                .white : AppTheme.Colors.primary
                            )
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                timerManager.selectedDuration == preset.duration ?
                                AppTheme.Colors.primary : AppTheme.Colors.primary.opacity(0.1)
                            )
                            .cornerRadius(AppTheme.CornerRadius.sm)
                    }
                }
            }
        }
    }
}

// MARK: - Today's Sessions View
struct TodaySessionsView: View {
    @ObservedObject var sessionStorage: FocusSessionStorage

    var todaySessions: [FocusSession] {
        let today = Calendar.current.startOfDay(for: Date())
        return sessionStorage.sessions.filter { session in
            Calendar.current.isDate(session.completedAt, inSameDayAs: today)
        }
    }

    var totalMinutesToday: Int {
        todaySessions.reduce(0) { $0 + $1.duration }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            HStack {
                Text("Today's Focus Time")
                    .font(AppTheme.Typography.title3)
                    .fontWeight(.bold)

                Spacer()

                HStack(spacing: 4) {
                    Image(systemName: "clock.fill")
                        .foregroundColor(AppTheme.Colors.primary)
                    Text("\(totalMinutesToday) min")
                        .font(AppTheme.Typography.headline)
                        .foregroundColor(AppTheme.Colors.primary)
                }
            }

            if todaySessions.isEmpty {
                CardView {
                    VStack(spacing: AppTheme.Spacing.sm) {
                        Image(systemName: "timer")
                            .font(.system(size: 32))
                            .foregroundColor(.secondary)

                        Text("No focus sessions today yet")
                            .font(AppTheme.Typography.body)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppTheme.Spacing.lg)
                }
            } else {
                CardView {
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                        ForEach(todaySessions) { session in
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(AppTheme.Colors.success)

                                Text("\(session.duration) minutes")
                                    .font(AppTheme.Typography.body)

                                Spacer()

                                Text(session.completedAt, style: .time)
                                    .font(AppTheme.Typography.caption)
                                    .foregroundColor(.secondary)
                            }

                            if session.id != todaySessions.last?.id {
                                Divider()
                            }
                        }
                    }
                }
            }
        }
    }
}
