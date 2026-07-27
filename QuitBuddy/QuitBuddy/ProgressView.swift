// File: ProgressView.swift
import SwiftUI
import Combine

// MARK: - Model
struct AddictionItem: Identifiable, Codable {
    let id: UUID
    var name: String
    var emoji: String
    var startDate: Date
    var isDefault: Bool

    init(id: UUID = UUID(), name: String, emoji: String, startDate: Date = Date(), isDefault: Bool = false) {
        self.id = id
        self.name = name
        self.emoji = emoji
        self.startDate = startDate
        self.isDefault = isDefault
    }
}

// MARK: - Storage
final class AddictionStore: ObservableObject {
    @Published var items: [AddictionItem] = []
    private let key = "addiction_items"

    init() { load() }

    func load() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([AddictionItem].self, from: data)
        else { return }
        items = decoded
    }

    func save() {
        guard let data = try? JSONEncoder().encode(items) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }

    func add(_ item: AddictionItem) {
        let nameLower = item.name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !items.contains(where: { $0.name.lowercased() == nameLower }) else { return }
        items.append(item)
        save()
    }

    func delete(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
        save()
    }

    func reset(_ item: AddictionItem) { reset(item, to: Date()) }

    func reset(_ item: AddictionItem, to date: Date) {
        if let idx = items.firstIndex(where: { $0.id == item.id }) {
            items[idx].startDate = date
            save()
        }
    }

    @discardableResult
    func ensureDefaultItem() -> UUID {
        if let existing = items.first(where: { $0.isDefault }) { return existing.id }
        let d = AddictionItem(name: "Clean Streak", emoji: "✨", startDate: Date(), isDefault: true)
        items.insert(d, at: 0)
        save()
        return d.id
    }

    var defaultItem: AddictionItem? { items.first(where: { $0.isDefault }) }

    func nameExists(_ name: String) -> Bool {
        let lower = name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return items.contains(where: { $0.name.lowercased() == lower })
    }
}

// MARK: - Main View
struct HabitProgressView: View {
    @EnvironmentObject private var store: AddictionStore
    @EnvironmentObject private var theme: ThemeManager
    @AppStorage("pinned_addiction_id") private var pinnedID: String = ""
    @State private var showAddSheet = false

    var userItems: [AddictionItem] {
        store.items.filter { !$0.isDefault }
            .sorted { a, _ in a.id.uuidString == pinnedID }
    }

    var hasCustomPinned: Bool {
        guard !pinnedID.isEmpty else { return false }
        return store.items.first(where: { $0.id.uuidString == pinnedID && !$0.isDefault }) != nil
    }

    var body: some View {
        NavigationView {
            ZStack {
                theme.backgroundGradient.ignoresSafeArea()

                VStack(spacing: 0) {
                    HStack {
                        Text("Progress")
                            .font(.system(size: 28, weight: .black, design: .rounded))
                            .foregroundStyle(theme.primaryText)
                        Spacer()
                        Button { showAddSheet = true } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 17, weight: .bold))
                                .foregroundStyle(theme.isDark ? .white : theme.accent)
                                .frame(width: 36, height: 36)
                                .background(theme.accent.opacity(0.2))
                                .clipShape(Circle())
                                .overlay(Circle().strokeBorder(theme.accent.opacity(0.5), lineWidth: 1))
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 56)
                    .padding(.bottom, 12)

                    TimelineView(.periodic(from: .now, by: 1)) { tl in
                        List {
                            // DEFAULT
                            if !hasCustomPinned, let def = store.defaultItem {
                                let isPinned = pinnedID == def.id.uuidString
                                Section {
                                    AddictionCard(item: def, now: tl.date, isPinned: isPinned)
                                        .listRowBackground(Color.clear)
                                        .listRowSeparator(.hidden)
                                        .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                                        .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                            Button {
                                                pinnedID = isPinned ? "" : def.id.uuidString
                                            } label: {
                                                Label(isPinned ? "Unpin" : "Pin",
                                                      systemImage: isPinned ? "pin.slash" : "pin.fill")
                                            }
                                            .tint(theme.accent)
                                        }
                                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                            Button { store.reset(def) } label: {
                                                Label("Reset", systemImage: "arrow.counterclockwise")
                                            }
                                            .tint(.orange)
                                        }
                                } header: {
                                    Text("DEFAULT")
                                        .font(.system(size: 11, weight: .bold, design: .rounded))
                                        .foregroundStyle(theme.sectionLabel)
                                }
                                .listSectionSeparator(.hidden)
                            }

                            // YOUR HABITS 
                            if !userItems.isEmpty {
                                Section {
                                    ForEach(userItems) { item in
                                        let isPinned = pinnedID == item.id.uuidString
                                        AddictionCard(item: item, now: tl.date, isPinned: isPinned)
                                            .listRowBackground(Color.clear)
                                            .listRowSeparator(.hidden)
                                            .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                                            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                                Button {
                                                    pinnedID = isPinned
                                                        ? (store.defaultItem?.id.uuidString ?? "")
                                                        : item.id.uuidString
                                                } label: {
                                                    Label(isPinned ? "Unpin" : "Pin",
                                                          systemImage: isPinned ? "pin.slash" : "pin.fill")
                                                }
                                                .tint(theme.accent)
                                            }
                                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                                Button(role: .destructive) {
                                                    if isPinned {
                                                        pinnedID = store.defaultItem?.id.uuidString ?? ""
                                                    }
                                                    if let idx = store.items.firstIndex(where: { $0.id == item.id }) {
                                                        store.delete(at: IndexSet(integer: idx))
                                                    }
                                                } label: {
                                                    Label("Delete", systemImage: "trash")
                                                }
                                                Button { store.reset(item) } label: {
                                                    Label("Reset", systemImage: "arrow.counterclockwise")
                                                }
                                                .tint(.orange)
                                            }
                                    }
                                } header: {
                                    Text("YOUR HABITS")
                                        .font(.system(size: 11, weight: .bold, design: .rounded))
                                        .foregroundStyle(theme.sectionLabel)
                                }
                                .listSectionSeparator(.hidden)
                            }

                            // Hint
                            Section {
                                Text("← Swipe right to pin · Swipe left to delete/reset")
                                    .font(.system(size: 12, design: .rounded))
                                    .foregroundStyle(theme.secondaryText)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .listRowBackground(Color.clear)
                                    .listRowSeparator(.hidden)
                            }
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showAddSheet) {
            AddAddictionSheet(store: store) { name, emoji in
                store.add(AddictionItem(name: name, emoji: emoji))
            }
            .environmentObject(theme)
        }
        .onAppear {
            let defaultID = store.ensureDefaultItem()
            if pinnedID.isEmpty { pinnedID = defaultID.uuidString }
        }
    }
}

// MARK: - Addiction Card
struct AddictionCard: View {
    @EnvironmentObject private var theme: ThemeManager
    let item: AddictionItem
    let now: Date
    let isPinned: Bool

    var elapsed: TimeInterval { now.timeIntervalSince(item.startDate) }
    var days: Int    { max(0, Int(elapsed)) / 86400 }
    var hours: Int   { (max(0, Int(elapsed)) % 86400) / 3600 }
    var minutes: Int { (max(0, Int(elapsed)) % 3600) / 60 }
    var seconds: Int { max(0, Int(elapsed)) % 60 }
    var progress: Double { min(max(0, elapsed) / (90 * 86400), 1.0) }

    var milestoneText: String {
        switch days {
        case 0:       return "Day one — you got this! 💪"
        case 1:       return "First day done! 🌟"
        case 2...6:   return "\(days) days strong 🔥"
        case 7...13:  return "One week clean! 🎉"
        case 14...29: return "\(days) days — keep going! 💎"
        case 30...59: return "One month free! 🏅"
        case 60...89: return "Two months! Incredible 🚀"
        case 90...179: return "Three months! Legend 🏆"
        case 180...364: return "Half a year! Unstoppable 🌠"
        case 365...729: return "One full year! You're free 🦋"
        default:      return "\(days / 365)+ years! Absolute legend 👑"
        }
    }

    var ringColor: LinearGradient {
        switch days {
        case 0...6:   return LinearGradient(colors: [Color(hex: "a78bfa"), Color(hex: "7c3aed")], startPoint: .topLeading, endPoint: .bottomTrailing)
        case 7...29:  return LinearGradient(colors: [Color(hex: "f472b6"), Color(hex: "a78bfa")], startPoint: .topLeading, endPoint: .bottomTrailing)
        case 30...89: return LinearGradient(colors: [Color(hex: "34d399"), Color(hex: "059669")], startPoint: .topLeading, endPoint: .bottomTrailing)
        default:      return LinearGradient(colors: [Color(hex: "FFD700"), Color(hex: "FFA500")], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }

    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                ZStack {
                    Circle().stroke(theme.cardBorder, lineWidth: 6)
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(ringColor, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 1), value: progress)
                    Text(item.emoji).font(.system(size: 26))
                }
                .frame(width: 64, height: 64)

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(item.name)
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .foregroundStyle(theme.primaryText)
                        if isPinned {
                            Image(systemName: "pin.fill")
                                .font(.system(size: 11))
                                .foregroundStyle(theme.accent)
                        }
                    }
                    Text(milestoneText)
                        .font(.system(size: 13, design: .rounded))
                        .foregroundStyle(theme.secondaryText)
                }
                Spacer()
            }

            HStack(spacing: 0) {
                TimeBlock(value: days,    label: "DAYS")
                Divider().frame(height: 28).background(theme.dividerColor).padding(.horizontal, 8)
                TimeBlock(value: hours,   label: "HRS")
                Divider().frame(height: 28).background(theme.dividerColor).padding(.horizontal, 8)
                TimeBlock(value: minutes, label: "MIN")
                Divider().frame(height: 28).background(theme.dividerColor).padding(.horizontal, 8)
                TimeBlock(value: seconds, label: "SEC")
            }
            .frame(maxWidth: .infinity)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(theme.cardFill)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(
                            isPinned ? theme.accent.opacity(0.6) : theme.cardBorder,
                            lineWidth: isPinned ? 1.5 : 1
                        )
                )
        )
    }
}

// MARK: - Time Block
struct TimeBlock: View {
    @EnvironmentObject private var theme: ThemeManager
    let value: Int
    let label: String

    var body: some View {
        VStack(spacing: 2) {
            Text(String(format: "%02d", value))
                .font(.system(size: 22, weight: .black, design: .monospaced))
                .foregroundStyle(theme.primaryText)
            Text(label)
                .font(.system(size: 9, weight: .bold, design: .rounded))
                .foregroundStyle(theme.secondaryText)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Add Sheet
struct AddAddictionSheet: View {
    @EnvironmentObject private var theme: ThemeManager
    let store: AddictionStore
    let onSave: (String, String) -> Void

    @State private var name = ""
    @State private var selectedEmoji = "🚬"
    @State private var showDuplicateWarning = false
    @Environment(\.dismiss) private var dismiss

    let presets: [(emoji: String, name: String)] = [
        ("🚬", "Smoking"),   ("🍺", "Alcohol"),      ("💊", "Drugs"),
        ("🎰", "Gambling"),  ("📱", "Social Media"),  ("🍬", "Sugar"),
        ("☕️", "Caffeine"),  ("🎮", "Gaming"),        ("🍕", "Junk Food"),
        ("🛒", "Overspending"), ("🍫", "Chocolate"), ("🍟", "Fast Food"),
        ("😤", "Anger"),     ("🌙", "Late Nights"),   ("📺", "TV Binging"),
        ("🍷", "Wine"),      ("🧁", "Sweets"),        ("💨", "Vaping"),
        ("🎲", "Betting"),   ("🧃", "Energy Drinks"), ("📰", "Doom Scrolling"),
        ("🛏", "Oversleeping"),
    ]

    var availablePresets: [(emoji: String, name: String)] {
        presets.filter { !store.nameExists($0.name) }
    }

    var isDuplicate: Bool {
        store.nameExists(name.trimmingCharacters(in: .whitespacesAndNewlines))
    }

    var body: some View {
        NavigationView {
            ZStack {
                theme.sheetBackground.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        if availablePresets.isEmpty {
                            Text("You're tracking all available habits!")
                                .font(.system(size: 14, design: .rounded))
                                .foregroundStyle(theme.secondaryText)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.top, 8)
                        } else {
                            Text("Choose a habit")
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundStyle(theme.secondaryText)
                                .padding(.horizontal)

                            LazyVGrid(
                                columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 5),
                                spacing: 10
                            ) {
                                ForEach(availablePresets, id: \.emoji) { preset in
                                    Button {
                                        selectedEmoji = preset.emoji
                                        name = preset.name
                                        showDuplicateWarning = false
                                    } label: {
                                        VStack(spacing: 6) {
                                            Text(preset.emoji).font(.system(size: 28))
                                            Text(preset.name)
                                                .font(.system(size: 9, weight: .semibold, design: .rounded))
                                                .foregroundStyle(theme.secondaryText)
                                                .multilineTextAlignment(.center)
                                                .lineLimit(2)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 10)
                                        .background(
                                            RoundedRectangle(cornerRadius: 14)
                                                .fill(selectedEmoji == preset.emoji
                                                      ? theme.accent.opacity(0.35) : theme.cardFill)
                                                .overlay(RoundedRectangle(cornerRadius: 14)
                                                    .strokeBorder(
                                                        selectedEmoji == preset.emoji
                                                            ? theme.accent.opacity(0.8) : theme.cardBorder,
                                                        lineWidth: 1))
                                        )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal)
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Or enter custom name")
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundStyle(theme.secondaryText)

                            HStack(spacing: 12) {
                                Text(selectedEmoji).font(.system(size: 24))
                                TextField("e.g. Netflix, Coffee…", text: $name)
                                    .font(.system(size: 16, design: .rounded))
                                    .foregroundStyle(theme.primaryText)
                                    .onChange(of: name) { _, _ in showDuplicateWarning = false }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(theme.cardFill)
                                    .overlay(RoundedRectangle(cornerRadius: 14)
                                        .strokeBorder(
                                            showDuplicateWarning ? Color.red.opacity(0.6) : theme.cardBorder,
                                            lineWidth: 1))
                            )

                            if showDuplicateWarning {
                                Text("⚠️ You're already tracking \"\(name.trimmingCharacters(in: .whitespacesAndNewlines))\"")
                                    .font(.system(size: 12, design: .rounded))
                                    .foregroundStyle(.red.opacity(0.8))
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Add Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(theme.toolbarScheme, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(theme.secondaryText)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Start") {
                        let n = name.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !n.isEmpty else { return }
                        if isDuplicate { showDuplicateWarning = true; return }
                        onSave(n, selectedEmoji)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(theme.accent)
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}
