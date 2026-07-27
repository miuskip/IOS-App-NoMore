// File: SettingsView.swift
import SwiftUI
import SwiftData
 
struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var theme: ThemeManager
    @EnvironmentObject private var store: AddictionStore
 
    @Query private var records: [HabitRecord]
    @Query private var entries: [JournalEntry]
    @Query private var quotes: [QuoteItem]
 
    @AppStorage("notifications_enabled") private var notificationsEnabled = false
    @AppStorage("notification_hour")     private var notifHour = 9
    @AppStorage("notification_minute")   private var notifMinute = 0
    @AppStorage("money_cost_per_day")    private var moneyCostPerDay: Double = 0
    @AppStorage("money_currency")        private var moneyCurrency: String = "$"
    @AppStorage("pinned_addiction_id")   private var pinnedID: String = ""
 
    @State private var notifTime = Calendar.current.date(
        bySettingHour: 9, minute: 0, second: 0, of: Date()
    ) ?? Date()
 
    @State private var showResetAlert = false
    @State private var isAuthorized = false
 
    var body: some View {
        NavigationView {
            ZStack {
                theme.backgroundGradient.ignoresSafeArea()
 
                ScrollView {
                    VStack(spacing: 24) {
 
                        // Header
                        HStack {
                            Text("Settings")
                                .font(.system(size: 28, weight: .black, design: .rounded))
                                .foregroundStyle(theme.primaryText)
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 56)
 
                        // MARK: - Appearance
                        VStack(alignment: .leading, spacing: 0) {
                            Text("APPEARANCE")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundStyle(theme.sectionLabel)
                                .padding(.horizontal, 20)
                                .padding(.bottom, 10)
 
                            HStack {
                                Label(theme.isDark ? "Dark Theme" : "Light Theme",
                                      systemImage: theme.isDark ? "moon.fill" : "sun.max.fill")
                                    .font(.system(size: 16, design: .rounded))
                                    .foregroundStyle(theme.primaryText)
                                Spacer()
                                Toggle("", isOn: $theme.isDark)
                                    .tint(theme.accent)
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(theme.cardFill)
                                    .overlay(RoundedRectangle(cornerRadius: 16)
                                        .strokeBorder(theme.cardBorder, lineWidth: 1))
                            )
                            .padding(.horizontal)
                        }
 
                        // MARK: - Notifications
                        VStack(alignment: .leading, spacing: 0) {
                            Text("NOTIFICATIONS")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundStyle(theme.sectionLabel)
                                .padding(.horizontal, 20)
                                .padding(.bottom, 10)
 
                            VStack(spacing: 0) {
                                HStack {
                                    Text("Daily Reminder")
                                        .font(.system(size: 16, design: .rounded))
                                        .foregroundStyle(theme.primaryText)
                                    Spacer()
                                    Toggle("", isOn: $notificationsEnabled)
                                        .tint(theme.accent)
                                        .onChange(of: notificationsEnabled) { _, newValue in
                                            handleNotificationToggle(newValue)
                                        }
                                }
                                .padding(16)
 
                                if notificationsEnabled {
                                    Divider().background(theme.dividerColor)
 
                                    DatePicker(
                                        "Reminder Time",
                                        selection: $notifTime,
                                        displayedComponents: .hourAndMinute
                                    )
                                    .datePickerStyle(.compact)
                                    .colorScheme(theme.toolbarScheme)
                                    .font(.system(size: 16, design: .rounded))
                                    .foregroundStyle(theme.primaryText)
                                    .padding(16)
                                    .onChange(of: notifTime) { _, newValue in
                                        let comps = Calendar.current.dateComponents([.hour, .minute], from: newValue)
                                        notifHour = comps.hour ?? 9
                                        notifMinute = comps.minute ?? 0
                                        if notificationsEnabled {
                                            NotificationManager.shared.scheduleDaily(hour: notifHour, minute: notifMinute)
                                        }
                                    }
 
                                    if !isAuthorized {
                                        Divider().background(theme.dividerColor)
                                        Text("⚠️ Please allow notifications in iOS Settings → QuitBuddy")
                                            .font(.system(size: 13, design: .rounded))
                                            .foregroundStyle(.orange)
                                            .padding(16)
                                    }
                                }
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(theme.cardFill)
                                    .overlay(RoundedRectangle(cornerRadius: 16)
                                        .strokeBorder(theme.cardBorder, lineWidth: 1))
                            )
                            .padding(.horizontal)
 
                            Text("Receive a daily motivational reminder to keep you on track.")
                                .font(.system(size: 12, design: .rounded))
                                .foregroundStyle(theme.secondaryText)
                                .padding(.horizontal, 20)
                                .padding(.top, 8)
                        }
 
                        // MARK: - Money Saved
                        VStack(alignment: .leading, spacing: 0) {
                            Text("MONEY SAVED")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundStyle(theme.sectionLabel)
                                .padding(.horizontal, 20)
                                .padding(.bottom, 10)
 
                            NavigationLink {
                                MoneySettingsView()
                                    .environmentObject(theme)
                            } label: {
                                HStack {
                                    Label("Daily Spending Setup", systemImage: "banknote")
                                        .font(.system(size: 16, design: .rounded))
                                        .foregroundStyle(theme.primaryText)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundStyle(theme.secondaryText)
                                }
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(theme.cardFill)
                                        .overlay(RoundedRectangle(cornerRadius: 16)
                                            .strokeBorder(theme.cardBorder, lineWidth: 1))
                                )
                            }
                            .padding(.horizontal)
 
                            Text("Track how much money you're saving by quitting.")
                                .font(.system(size: 12, design: .rounded))
                                .foregroundStyle(theme.secondaryText)
                                .padding(.horizontal, 20)
                                .padding(.top, 8)
                        }
 
                        // MARK: - About
                        VStack(alignment: .leading, spacing: 0) {
                            Text("ABOUT")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundStyle(theme.sectionLabel)
                                .padding(.horizontal, 20)
                                .padding(.bottom, 10)
 
                            VStack(spacing: 0) {
                                SettingsRow(label: "Version", value: "1.0.0")
                                Divider().background(theme.dividerColor)
                                SettingsRow(label: "Journal Entries", value: "\(entries.count)")
                                Divider().background(theme.dividerColor)
                                SettingsRow(label: "Quotes", value: "\(quotes.count)")
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(theme.cardFill)
                                    .overlay(RoundedRectangle(cornerRadius: 16)
                                        .strokeBorder(theme.cardBorder, lineWidth: 1))
                            )
                            .padding(.horizontal)
                        }
 
                        // MARK: - Danger Zone
                        VStack(alignment: .leading, spacing: 0) {
                            Text("DANGER ZONE")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundStyle(theme.sectionLabel)
                                .padding(.horizontal, 20)
                                .padding(.bottom, 10)
 
                            Button(role: .destructive) {
                                showResetAlert = true
                            } label: {
                                HStack {
                                    Image(systemName: "trash")
                                    Text("Reset All Data")
                                        .font(.system(size: 16, design: .rounded))
                                    Spacer()
                                }
                                .foregroundStyle(.red)
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(theme.cardFill)
                                        .overlay(RoundedRectangle(cornerRadius: 16)
                                            .strokeBorder(.red.opacity(0.3), lineWidth: 1))
                                )
                            }
                            .padding(.horizontal)
 
                            Text("This will delete your tracker, journal, and all custom quotes.")
                                .font(.system(size: 12, design: .rounded))
                                .foregroundStyle(theme.secondaryText)
                                .padding(.horizontal, 20)
                                .padding(.top, 8)
                        }
 
                        Spacer(minLength: 40)
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .alert("Reset All Data?", isPresented: $showResetAlert) {
            Button("Reset", role: .destructive) { resetAll() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This action cannot be undone.")
        }
        .onAppear {
            NotificationManager.shared.checkAuthorizationStatus { authorized in
                isAuthorized = authorized
            }
            notifTime = Calendar.current.date(
                bySettingHour: notifHour,
                minute: notifMinute,
                second: 0,
                of: Date()
            ) ?? Date()
        }
    }
 
    private func handleNotificationToggle(_ enabled: Bool) {
        if enabled {
            NotificationManager.shared.requestPermission()
            NotificationManager.shared.checkAuthorizationStatus { authorized in
                isAuthorized = authorized
                if authorized {
                    NotificationManager.shared.scheduleDaily(hour: notifHour, minute: notifMinute)
                }
            }
        } else {
            NotificationManager.shared.cancelAll()
        }
    }
 
    private func resetAll() {
        // 1. SwiftData deletions
        let recordsCopy = records
        let entriesCopy = entries
        let quotesCopy = quotes
        for r in recordsCopy { modelContext.delete(r) }
        for e in entriesCopy { modelContext.delete(e) }
        for q in quotesCopy  { modelContext.delete(q) }
        try? modelContext.save()
 
        // 2. AppStorage
        pinnedID = ""
        moneyCostPerDay = 0
        moneyCurrency = "$"
        notificationsEnabled = false
        NotificationManager.shared.cancelAll()
 
        // 3. AddictionStore
        Task { @MainActor in
            store.items.removeAll()
            UserDefaults.standard.removeObject(forKey: "addiction_items")
            store.ensureDefaultItem()
        }
    }
}
 
// MARK: - Settings Row
struct SettingsRow: View {
    let label: String
    let value: String
    @EnvironmentObject private var theme: ThemeManager
 
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 16, design: .rounded))
                .foregroundStyle(theme.primaryText)
            Spacer()
            Text(value)
                .font(.system(size: 16, design: .rounded))
                .foregroundStyle(theme.secondaryText)
        }
        .padding(16)
    }
}
