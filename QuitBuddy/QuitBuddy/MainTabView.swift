// File: MainTabView.swift
import SwiftUI
 
struct MainTabView: View {
    @StateObject private var store = AddictionStore()
    @StateObject private var theme = ThemeManager.shared
 
    var body: some View {
        TabView {
            TrackerView()
                .environmentObject(store)
                .environmentObject(theme)
                .tabItem { Label("Tracker", systemImage: "timer") }
 
            HabitProgressView()
                .environmentObject(store)
                .environmentObject(theme)
                .tabItem { Label("Progress", systemImage: "chart.line.uptrend.xyaxis") }
 
            JournalView()
                .environmentObject(theme)
                .tabItem { Label("Journal", systemImage: "book") }
 
            QuotesView()
                .environmentObject(theme)
                .tabItem { Label("Quotes", systemImage: "quote.bubble") }
 
            SettingsView()
                .environmentObject(store)
                .environmentObject(theme)
                .tabItem { Label("Settings", systemImage: "gearshape") }
        }
        .colorScheme(theme.isDark ? .dark : .light)
    }
}
 
struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    @EnvironmentObject private var theme: ThemeManager
 
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: icon)
                .font(.system(size: 56))
                .foregroundStyle(theme.accent.opacity(0.5))
            Text(title)
                .font(.system(size: 22, weight: .semibold, design: .rounded))
                .foregroundStyle(theme.primaryText)
            Text(message)
                .font(.system(size: 15, design: .rounded))
                .foregroundStyle(theme.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Spacer()
        }
    }
}
