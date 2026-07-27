// File: JournalView.swift
import SwiftUI
import SwiftData
 
struct JournalView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var theme: ThemeManager
    @Query(sort: \JournalEntry.date, order: .reverse) private var entries: [JournalEntry]
 
    @State private var showAddSheet = false
    @State private var editingEntry: JournalEntry?
 
    var body: some View {
        NavigationView {
            ZStack {
                theme.backgroundGradient.ignoresSafeArea()
 
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Text("Journal")
                            .font(.system(size: 28, weight: .black, design: .rounded))
                            .foregroundStyle(theme.primaryText)
                        Spacer()
                        Button {
                            showAddSheet = true
                        } label: {
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
 
                    if entries.isEmpty {
                        Spacer()
                        VStack(spacing: 16) {
                            Image(systemName: "book.closed")
                                .font(.system(size: 56))
                                .foregroundStyle(theme.accent.opacity(0.5))
                            Text("Your Journal")
                                .font(.system(size: 22, weight: .semibold, design: .rounded))
                                .foregroundStyle(theme.primaryText)
                            Text("Tap + to write your first note.\nTracking your thoughts helps you stay on course.")
                                .font(.system(size: 15, design: .rounded))
                                .foregroundStyle(theme.secondaryText)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }
                        Spacer()
                    } else {
                        List {
                            ForEach(entries) { entry in
                                JournalRow(entry: entry)
                                    .listRowBackground(Color.clear)
                                    .listRowSeparator(.hidden)
                                    .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                                    .onTapGesture { editingEntry = entry }
                                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                        Button(role: .destructive) {
                                            modelContext.delete(entry)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                            }
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showAddSheet) {
            EntryEditorSheet(entry: nil) { text in
                let e = JournalEntry(text: text)
                modelContext.insert(e)
            }
            .environmentObject(theme)
        }
        .sheet(item: $editingEntry) { entry in
            EntryEditorSheet(entry: entry) { text in
                entry.text = text
            }
            .environmentObject(theme)
        }
    }
}
 
// MARK: - Journal Row
struct JournalRow: View {
    let entry: JournalEntry
    @EnvironmentObject private var theme: ThemeManager
 
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(entry.text)
                .font(.system(size: 15, design: .rounded))
                .lineLimit(3)
                .foregroundStyle(theme.primaryText)
            Text(entry.date, style: .relative)
                .font(.system(size: 12, design: .rounded))
                .foregroundStyle(theme.secondaryText)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(theme.cardFill)
                .overlay(RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(theme.cardBorder, lineWidth: 1))
        )
    }
}
 
// MARK: - Entry Editor
struct EntryEditorSheet: View {
    let entry: JournalEntry?
    let onSave: (String) -> Void
    @EnvironmentObject private var theme: ThemeManager
 
    @State private var text: String
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focused: Bool
 
    init(entry: JournalEntry?, onSave: @escaping (String) -> Void) {
        self.entry = entry
        self.onSave = onSave
        _text = State(initialValue: entry?.text ?? "")
    }
 
    var body: some View {
        NavigationView {
            ZStack {
                theme.sheetBackground.ignoresSafeArea()
                TextEditor(text: $text)
                    .font(.system(size: 16, design: .rounded))
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                    .foregroundStyle(theme.primaryText)
                    .padding()
                    .focused($focused)
            }
            .navigationTitle(entry == nil ? "New Entry" : "Edit Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(theme.toolbarScheme, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(theme.secondaryText)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
                        if !trimmed.isEmpty { onSave(trimmed) }
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(theme.accent)
                    .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .onAppear { focused = true }
    }
}
