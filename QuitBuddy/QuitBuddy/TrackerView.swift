// File: TrackerView.swift
import SwiftUI
import SwiftData
import Combine
 
struct TrackerView: View {
    @Environment(\.modelContext) private var modelContext
  
    @EnvironmentObject private var store: AddictionStore
    @EnvironmentObject private var theme: ThemeManager
 
    @AppStorage("pinned_addiction_id") private var pinnedID: String = ""
 
    @State private var showRelapsedSheet = false
    @State private var showCravingCard = false
 
    var activeItem: AddictionItem? {
        if !pinnedID.isEmpty, let pinned = store.items.first(where: { $0.id.uuidString == pinnedID }) {
            return pinned
        }
        return store.defaultItem
    }
 
    var elapsed: (days: Int, hours: Int, minutes: Int, seconds: Int) {
        guard let start = activeItem?.startDate else { return (0, 0, 0, 0) }
        let total = Int(Date().timeIntervalSince(start))
        return (total / 86400, (total % 86400) / 3600, (total % 3600) / 60, total % 60)
    }
 
    var isDefaultActive: Bool {
        activeItem?.isDefault == true
    }
 
    var pinnedCustomItem: AddictionItem? {
        guard !pinnedID.isEmpty,
              let item = store.items.first(where: { $0.id.uuidString == pinnedID }),
              !item.isDefault else { return nil }
        return item
    }
 
    var battleChips: [AddictionItem] {
        store.items.filter { !$0.isDefault && $0.id.uuidString != pinnedID }
    }
 
    var body: some View {
        NavigationView {
            ZStack {
                theme.backgroundGradient.ignoresSafeArea()
 
                TimelineView(.periodic(from: .now, by: 1)) { tl in
                ScrollView {
                    VStack(spacing: 28) {
                        let currentTime = tl.date
 
                  
                        VStack(spacing: 6) {
                            Text("NoMore")
                                .font(.system(size: 38, weight: .black, design: .rounded))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [theme.primaryText, Color(hex: "a78bfa")],
                                        startPoint: .leading, endPoint: .trailing
                                    )
                                )
 
                            // Підзаголовок: закріплена кастомна звичка або загальний стрік
                            if let pinned = pinnedCustomItem {
                                HStack(spacing: 6) {
                                    Text(pinned.emoji).font(.system(size: 16))
                                    Text(pinned.name)
                                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                                    Image(systemName: "pin.fill")
                                        .font(.system(size: 11))
                                }
                                .foregroundStyle(Color(hex: "a78bfa").opacity(0.9))
                            } else {
                                Text("Your general clean streak")
                                    .font(.system(size: 13, weight: .medium, design: .rounded))
                                    .foregroundStyle(theme.secondaryText)
                            }
                        }
                        .padding(.top, 16)
 
                     
                        HStack(spacing: 0) {
                            TimeUnit(value: elapsed.days,    label: "DAYS")
                            divider
                            TimeUnit(value: elapsed.hours,   label: "HRS")
                            divider
                            TimeUnit(value: elapsed.minutes, label: "MIN")
                            divider
                            TimeUnit(value: elapsed.seconds, label: "SEC")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 24)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .fill(theme.cardFill)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 24)
                                        .strokeBorder(
                                            isDefaultActive
                                                ? theme.cardBorder
                                                : Color(hex: "a78bfa").opacity(0.45),
                                            lineWidth: isDefaultActive ? 1 : 1.5
                                        )
                                )
                        )
                        .shadow(
                            color: isDefaultActive ? .clear : Color(hex: "a78bfa").opacity(0.15),
                            radius: 16, x: 0, y: 4
                        )
                        .padding(.horizontal)
 
                        // ── Clean since ──
                        if let start = activeItem?.startDate {
                            VStack(spacing: 4) {
                                Text("clean since")
                                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                                    .foregroundStyle(theme.secondaryText)
                                    .textCase(.uppercase)
                                Text(start, style: .date)
                                    .font(.system(size: 17, weight: .bold, design: .rounded))
                                    .foregroundStyle(theme.primaryText)
                            }
                        }
 
                        // ── Money Saved ──
                        if let start = activeItem?.startDate {
                            MoneySavedCard(startDate: start, currentTime: currentTime)
                                .environmentObject(theme)
                                .padding(.horizontal)
                        }
 
                        // ── Also Fighting chips ──
                        if !battleChips.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("ALSO FIGHTING")
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                    .foregroundStyle(theme.sectionLabel)
                                    .padding(.horizontal, 20)
 
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 10) {
                                        ForEach(battleChips) { item in
                                            let isPinned = item.id.uuidString == pinnedID
                                            HabitChip(item: item, isPinned: isPinned)
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                }
                            }
                        }
 
                        // ── I Relapsed ──
                        Button { showRelapsedSheet = true } label: {
                            Label("I Relapsed", systemImage: "arrow.counterclockwise")
                                .font(.system(size: 17, weight: .semibold, design: .rounded))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(theme.cardFill)
                                .foregroundStyle(theme.primaryText.opacity(0.7))
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .strokeBorder(theme.cardBorder, lineWidth: 1)
                                )
                        }
                        .padding(.horizontal)
 
                        // ── Craving Button / Card ──
                        CravingCard(isExpanded: $showCravingCard)
                            .environmentObject(theme)
                            .padding(.horizontal)
 
                        // ── Milestones ──
                        if let start = activeItem?.startDate {
                            MilestonesView(startDate: start, currentTime: currentTime)
                                .environmentObject(theme)
                                .padding(.horizontal)
                        }
 
                        Spacer(minLength: 40)
                    }
                }
                } // TimelineView
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showRelapsedSheet) {
            RelapsedSheet { newDate in
                if let active = activeItem {
                    store.reset(active, to: newDate)
                }
                showRelapsedSheet = false
            }
            .environmentObject(theme)
        }
        .onAppear {
            let defaultID = store.ensureDefaultItem()
            if pinnedID.isEmpty || store.items.first(where: { $0.id.uuidString == pinnedID }) == nil {
                pinnedID = defaultID.uuidString
            }
        }
    }
 
    var divider: some View {
        Rectangle()
            .fill(theme.dividerColor)
            .frame(width: 1, height: 50)
    }
}
 
// MARK: - Habit Chip
struct HabitChip: View {
    let item: AddictionItem
    let isPinned: Bool
    @EnvironmentObject private var theme: ThemeManager
 
    var body: some View {
        HStack(spacing: 6) {
            Text(item.emoji).font(.system(size: 14))
            Text(item.name)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
            if isPinned {
                Image(systemName: "pin.fill")
                    .font(.system(size: 9))
                    .foregroundStyle(Color(hex: "a78bfa"))
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(isPinned ? Color(hex: "a78bfa").opacity(0.22) : theme.cardFill)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(
                            isPinned ? Color(hex: "a78bfa").opacity(0.55) : theme.cardBorder,
                            lineWidth: 1
                        )
                )
        )
        .foregroundStyle(isPinned ? Color(hex: "c4b5fd") : theme.primaryText.opacity(0.8))
        .shadow(color: isPinned ? Color(hex: "a78bfa").opacity(0.35) : .clear, radius: 8)
        .allowsHitTesting(false)
    }
}
 
// MARK: - TimeUnit
struct TimeUnit: View {
    let value: Int
    let label: String
    @EnvironmentObject private var theme: ThemeManager
 
    var fontSize: CGFloat {
        let digits = String(value).count
        switch digits {
        case 1, 2: return 38
        case 3:    return 30
        case 4:    return 24
        default:   return 20
        }
    }
 
    var body: some View {
        VStack(spacing: 4) {
            Text("\(value)")
                .font(.system(size: fontSize, weight: .black, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(theme.primaryText)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
                .contentTransition(.numericText())
                .animation(.easeInOut(duration: 0.2), value: value)
            Text(label)
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundStyle(theme.secondaryText)
        }
        .frame(maxWidth: .infinity)
    }
}
 
// MARK: - Milestones
struct MilestonesView: View {
    @EnvironmentObject private var theme: ThemeManager
    let startDate: Date
    let currentTime: Date
 
    struct Milestone { let label: String; let seconds: Double; let icon: String }
 
    let milestones: [Milestone] = [
        .init(label: "1 Hour",   seconds: 3_600,       icon: "clock"),
        .init(label: "1 Day",    seconds: 86_400,      icon: "sun.max"),
        .init(label: "3 Days",   seconds: 259_200,     icon: "star"),
        .init(label: "1 Week",   seconds: 604_800,     icon: "flame"),
        .init(label: "1 Month",  seconds: 2_592_000,   icon: "trophy"),
        .init(label: "3 Months", seconds: 7_776_000,   icon: "crown"),
        .init(label: "6 Months", seconds: 15_552_000,  icon: "medal"),
        .init(label: "1 Year",   seconds: 31_536_000,  icon: "star.circle.fill"),
        .init(label: "2 Years",  seconds: 63_072_000,  icon: "sparkles"),
        .init(label: "3 Years",  seconds: 94_608_000,  icon: "hands.sparkles.fill"),
        .init(label: "5 Years",  seconds: 157_680_000, icon: "figure.strengthtraining.traditional"),
        .init(label: "10 Years", seconds: 315_360_000, icon: "infinity.circle.fill"),
    ]
 
    var elapsed: Double { currentTime.timeIntervalSince(startDate) }
 
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("MILESTONES")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundStyle(theme.sectionLabel)
 
            LazyVGrid(
                columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())],
                spacing: 10
            ) {
                ForEach(milestones, id: \.label) { m in
                    let achieved = elapsed >= m.seconds
                    VStack(spacing: 6) {
                        Image(systemName: m.icon)
                            .font(.title3)
                            .foregroundStyle(
                                achieved
                                    ? LinearGradient(colors: [Color(hex: "FFD700"), Color(hex: "FFA500")], startPoint: .top, endPoint: .bottom)
                                    : LinearGradient(colors: [theme.secondaryText.opacity(0.4), theme.secondaryText.opacity(0.4)], startPoint: .top, endPoint: .bottom)
                            )
                            .shadow(color: achieved ? Color(hex: "FFD700").opacity(0.7) : .clear, radius: 6)
                        Text(m.label)
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundStyle(achieved ? Color(hex: "FFE566") : theme.secondaryText)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(achieved ? Color(hex: "FFD700").opacity(0.1) : theme.cardFill)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .strokeBorder(
                                        achieved
                                            ? LinearGradient(colors: [Color(hex: "FFD700").opacity(0.7), Color(hex: "FFA500").opacity(0.4)], startPoint: .topLeading, endPoint: .bottomTrailing)
                                            : LinearGradient(colors: [.clear], startPoint: .top, endPoint: .bottom),
                                        lineWidth: 1
                                    )
                            )
                    )
                }
            }
        }
    }
}
 
// MARK: - Relapsed Sheet
struct RelapsedSheet: View {
    @EnvironmentObject private var theme: ThemeManager
    let onConfirm: (Date) -> Void
    @State private var newDate = Date()
    @Environment(\.dismiss) private var dismiss
 
    var body: some View {
        NavigationView {
            ZStack {
                theme.sheetBackground.ignoresSafeArea()
                VStack(spacing: 24) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(Color(hex: "a78bfa"))
                    Text("It's OK — Every setback\nis a setup for a comeback.")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(theme.primaryText)
                        .padding(.horizontal)
                    DatePicker("Start Date", selection: $newDate, displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(.compact)
                        .colorScheme(.dark)
                        .padding(.horizontal)
                    Button { onConfirm(newDate) } label: {
                        Text("Reset & Start Again")
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(colors: [Color(hex: "a78bfa"), Color(hex: "7c3aed")], startPoint: .leading, endPoint: .trailing)
                            )
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .padding(.horizontal)
                    Spacer()
                }
                .padding(.top, 32)
            }
            .navigationTitle("I Relapsed")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(theme.toolbarScheme, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(theme.secondaryText)
                }
            }
        }
    }
}
 
 
// MARK: - Craving Card
struct CravingCard: View {
    @Binding var isExpanded: Bool
    @EnvironmentObject private var theme: ThemeManager
 
    // Timer state
    @State private var secondsLeft: Int = 60
    @State private var finished = false
    @State private var pulseScale: CGFloat = 1.0
    @State private var countdownTimer: Timer? = nil
    @State private var breathTimer: Timer? = nil

    // Breathing phase: 0=inhale, 1=hold, 2=exhale
    @State private var breathPhase: Int = 0
    @State private var breathScale: CGFloat = 1.0
    @State private var breathOpacity: Double = 0.6

    let breathLabels = ["Inhale...", "Hold...", "Exhale..."]
    let breathDurations: [Double] = [4, 4, 4]

    let totalSeconds = 60
 
    var progress: Double { 1.0 - Double(secondsLeft) / Double(totalSeconds) }
 
    var body: some View {
        Group {
            if !isExpanded {
                // ── Collapsed: pulse button ──
                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        isExpanded = true
                    }
                    startSession()
                } label: {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color(hex: "f472b6").opacity(0.18))
                                .frame(width: 44, height: 44)
                                .scaleEffect(pulseScale)
                                .animation(
                                    .easeInOut(duration: 1.2).repeatForever(autoreverses: true),
                                    value: pulseScale
                                )
                            Text("💨").font(.system(size: 22))
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text("I'm Craving")
                                .font(.system(size: 17, weight: .semibold, design: .rounded))
                                .foregroundStyle(theme.primaryText)
                            Text("Tap for a 60-sec breathing exercise")
                                .font(.system(size: 12, design: .rounded))
                                .foregroundStyle(theme.secondaryText)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(theme.secondaryText)
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(theme.cardFill)
                            .overlay(
                                RoundedRectangle(cornerRadius: 18)
                                    .strokeBorder(Color(hex: "f472b6").opacity(0.35), lineWidth: 1)
                            )
                    )
                }
                .buttonStyle(.plain)
                .onAppear { pulseScale = 1.08 }
 
            } else {
                // ── Expanded: breathing session ──
                VStack(spacing: 20) {
 
                    // Top row
                    HStack {
                        Text(finished ? "🎉 Craving passed?" : "💨 Breathe with me")
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .foregroundStyle(theme.primaryText)
                        Spacer()
                        Button {
                            withAnimation { isExpanded = false }
                            resetSession()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(theme.secondaryText)
                                .frame(width: 28, height: 28)
                                .background(theme.cardFill)
                                .clipShape(Circle())
                        }
                    }
 
                    if finished {
                        // ── Done state ──
                        VStack(spacing: 12) {
                            Text("You resisted the craving! 💪")
                                .font(.system(size: 15, design: .rounded))
                                .foregroundStyle(theme.secondaryText)
                                .multilineTextAlignment(.center)
                            Button {
                                withAnimation { isExpanded = false }
                                resetSession()
                            } label: {
                                Text("Close")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(
                                        LinearGradient(
                                            colors: [Color(hex: "a78bfa"), Color(hex: "7c3aed")],
                                            startPoint: .leading, endPoint: .trailing)
                                    )
                                    .foregroundStyle(.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                            }
                        }
                    } else {
                        // ── Breathing circle ──
                        ZStack {
                            // Track ring
                            Circle()
                                .stroke(theme.cardBorder, lineWidth: 5)
                                .frame(width: 140, height: 140)
 
                            // Progress ring
                            Circle()
                                .trim(from: 0, to: progress)
                                .stroke(
                                    LinearGradient(
                                        colors: [Color(hex: "f472b6"), Color(hex: "a78bfa")],
                                        startPoint: .topLeading, endPoint: .bottomTrailing),
                                    style: StrokeStyle(lineWidth: 5, lineCap: .round)
                                )
                                .rotationEffect(.degrees(-90))
                                .frame(width: 140, height: 140)
                                .animation(.linear(duration: 1), value: progress)
 
                            // Breathing blob
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [Color(hex: "f472b6").opacity(0.35), Color(hex: "a78bfa").opacity(0.15)],
                                        center: .center, startRadius: 0, endRadius: 55)
                                )
                                .frame(width: 110, height: 110)
                                .scaleEffect(breathScale)
                                .opacity(breathOpacity)
 
                            VStack(spacing: 4) {
                                Text(breathLabels[breathPhase])
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                                    .foregroundStyle(theme.primaryText)
                                Text("\(secondsLeft)s")
                                    .font(.system(size: 28, weight: .black, design: .rounded))
                                    .foregroundStyle(Color(hex: "f472b6"))
                                    .contentTransition(.numericText())
                                    .animation(.easeInOut(duration: 0.2), value: secondsLeft)
                            }
                        }
 
                        // Hint
                        Text("Cravings usually pass in 60 seconds.You've got this.")
                            .font(.system(size: 13, design: .rounded))
                            .foregroundStyle(theme.secondaryText)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 22)
                        .fill(theme.cardFill)
                        .overlay(
                            RoundedRectangle(cornerRadius: 22)
                                .strokeBorder(Color(hex: "f472b6").opacity(0.3), lineWidth: 1)
                        )
                )
            }
        }
    }
 
    // MARK: - Timer logic
    private func startSession() {
        secondsLeft = totalSeconds
        finished = false
        stopTimers()

        // Countdown: fires every second, invalidates itself when done
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { t in
            if secondsLeft > 1 {
                secondsLeft -= 1
            } else {
                secondsLeft = 0
                t.invalidate()
                countdownTimer = nil
                withAnimation { finished = true }
            }
        }

        // Breath cycle: fires every 4 seconds, cycles through phases
        scheduleNextBreath()
    }

    private func resetSession() {
        stopTimers()
        finished = false
        secondsLeft = totalSeconds
        breathPhase = 0
        breathScale = 1.0
        breathOpacity = 0.6
    }

    private func stopTimers() {
        countdownTimer?.invalidate()
        countdownTimer = nil
        breathTimer?.invalidate()
        breathTimer = nil
    }

    private func scheduleNextBreath() {
        let phase = breathPhase
        let duration = breathDurations[phase]

        withAnimation(.easeInOut(duration: duration)) {
            if phase == 0 {
                breathScale = 1.25; breathOpacity = 0.9
            } else if phase == 1 {
                breathScale = 1.25; breathOpacity = 0.85
            } else {
                breathScale = 0.85; breathOpacity = 0.5
            }
        }

        breathTimer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { _ in
            guard countdownTimer != nil || secondsLeft == 0 else { return }
            breathPhase = (breathPhase + 1) % 3
            scheduleNextBreath()
        }
    }
}
// MARK: - Color hex
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8)  & 0xFF) / 255
        let b = Double(int         & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}
