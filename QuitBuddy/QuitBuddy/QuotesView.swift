// File: QuotesView.swift
import SwiftUI
import SwiftData

struct QuotesView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var theme: ThemeManager
    @Query private var quotes: [QuoteItem]

    @State private var currentIndex: Int = 0
    @State private var showAddSheet = false
    @State private var cardOffset: CGFloat = 0
    @State private var cardOpacity: Double = 1

    var displayedQuote: QuoteItem? {
        guard !quotes.isEmpty else { return nil }
        return quotes[currentIndex % quotes.count]
    }

    var favoriteQuotes: [QuoteItem] { quotes.filter { $0.isFavorite } }

    var body: some View {
        NavigationView {
            ZStack {
                theme.backgroundGradient.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {

                        // Header
                        HStack {
                            Text("Quotes")
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

                        if let quote = displayedQuote {
                            VStack(spacing: 20) {
                                Image(systemName: "quote.opening")
                                    .font(.system(size: 32))
                                    .foregroundStyle(theme.accent.opacity(0.7))

                                Text(quote.text)
                                    .font(.system(size: 20, weight: .medium, design: .rounded))
                                    .multilineTextAlignment(.center)
                                    .lineSpacing(4)
                                    .foregroundStyle(theme.primaryText)
                                    .padding(.horizontal, 8)

                                Text("— \(quote.author)")
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundStyle(theme.secondaryText)

                                Button {
                                    withAnimation(.spring(duration: 0.3)) {
                                        quote.isFavorite.toggle()
                                    }
                                } label: {
                                    Image(systemName: quote.isFavorite ? "heart.fill" : "heart")
                                        .font(.title3)
                                        .foregroundStyle(quote.isFavorite ? .pink : theme.secondaryText)
                                }
                            }
                            .padding(28)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 24)
                                    .fill(theme.cardFill)
                                    .overlay(RoundedRectangle(cornerRadius: 24)
                                        .strokeBorder(theme.cardBorder, lineWidth: 1))
                            )
                            .padding(.horizontal)
                            .offset(x: cardOffset)
                            .opacity(cardOpacity)
                        }

                        // New Quote button
                        Button { animateToNext() } label: {
                            Label("New Quote", systemImage: "arrow.clockwise")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    LinearGradient(colors: [Color(hex: "a78bfa"), Color(hex: "7c3aed")],
                                                   startPoint: .leading, endPoint: .trailing)
                                )
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .padding(.horizontal)

                        // Favorites
                        if !favoriteQuotes.isEmpty {
                            VStack(alignment: .leading, spacing: 0) {
                                Text("FAVORITES")
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                    .foregroundStyle(theme.sectionLabel)
                                    .padding(.horizontal, 20)
                                    .padding(.bottom, 12)

                                List {
                                    ForEach(favoriteQuotes) { q in
                                        HStack(alignment: .top, spacing: 12) {
                                            Image(systemName: "heart.fill")
                                                .font(.caption)
                                                .foregroundStyle(.pink)
                                                .padding(.top, 3)
                                            VStack(alignment: .leading, spacing: 3) {
                                                Text(q.text)
                                                    .font(.system(size: 14, design: .rounded))
                                                    .lineLimit(2)
                                                    .foregroundStyle(theme.primaryText)
                                                Text("— \(q.author)")
                                                    .font(.system(size: 12, design: .rounded))
                                                    .foregroundStyle(theme.secondaryText)
                                            }
                                            Spacer()
                                        }
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 14)
                                                .fill(theme.cardFill)
                                                .overlay(RoundedRectangle(cornerRadius: 14)
                                                    .strokeBorder(theme.cardBorder, lineWidth: 1))
                                        )
                                        .listRowBackground(Color.clear)
                                        .listRowSeparator(.hidden)
                                        .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                            Button(role: .destructive) {
                                                q.isFavorite = false
                                            } label: {
                                                Label("Remove", systemImage: "heart.slash")
                                            }
                                        }
                                    }
                                }
                                .listStyle(.plain)
                                .scrollContentBackground(.hidden)
                                .scrollDisabled(true)
                                .frame(height: CGFloat(favoriteQuotes.count) * 90)
                            }
                        }

                        Spacer(minLength: 40)
                    }
                    .padding(.bottom, 20)
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showAddSheet) {
            AddQuoteSheet { text, author in
                let q = QuoteItem(text: text, author: author, isCustom: true)
                modelContext.insert(q)
            }
            .environmentObject(theme)
        }
        .onAppear {
            seedQuotesIfNeeded()
            currentIndex = Int.random(in: 0..<max(1, quotes.count))
        }
    }

    private func animateToNext() {
        withAnimation(.easeIn(duration: 0.15)) { cardOffset = -30; cardOpacity = 0 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            currentIndex = (currentIndex + 1) % max(1, quotes.count)
            cardOffset = 30
            withAnimation(.easeOut(duration: 0.2)) { cardOffset = 0; cardOpacity = 1 }
        }
    }

    private func seedQuotesIfNeeded() {
        guard quotes.isEmpty else { return }
        for item in QuoteItem.defaults {
            modelContext.insert(QuoteItem(text: item.text, author: item.author))
        }
    }
}

// MARK: - Add Quote Sheet (без Form — Form+TextEditor викликає лаги)
struct AddQuoteSheet: View {
    let onSave: (String, String) -> Void
    @EnvironmentObject private var theme: ThemeManager

    @State private var text = ""
    @State private var author = ""
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedField: QuoteField?

    enum QuoteField { case text, author }

    var body: some View {
        NavigationView {
            ZStack {
                theme.sheetBackground.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {

                        // Quote field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("QUOTE")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundStyle(theme.sectionLabel)

                        
                            ZStack(alignment: .topLeading) {
                                if text.isEmpty {
                                    Text("Write an inspiring quote…")
                                        .font(.system(size: 15, design: .rounded))
                                        .foregroundStyle(theme.secondaryText)
                                        .padding(.horizontal, 4)
                                        .padding(.vertical, 8)
                                        .allowsHitTesting(false)
                                }
                                TextEditor(text: $text)
                                    .font(.system(size: 15, design: .rounded))
                                    .foregroundStyle(theme.primaryText)
                                    .scrollContentBackground(.hidden)
                                    .background(Color.clear)
                                    .frame(minHeight: 100, maxHeight: 180)
                                    .focused($focusedField, equals: .text)
                                    // Вимикаємо автокорекцію — основна причина лагів
                                    .autocorrectionDisabled(false)
                                    .keyboardType(.default)
                            }
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(theme.cardFill)
                                    .overlay(RoundedRectangle(cornerRadius: 14)
                                        .strokeBorder(
                                            focusedField == .text ? theme.accent.opacity(0.5) : theme.cardBorder,
                                            lineWidth: 1))
                            )
                            .onTapGesture { focusedField = .text }
                        }

                        // Author field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("AUTHOR")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundStyle(theme.sectionLabel)

                            TextField("Author name (or 'Unknown')", text: $author)
                                .font(.system(size: 15, design: .rounded))
                                .foregroundStyle(theme.primaryText)
                                .focused($focusedField, equals: .author)
                                .padding(14)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(theme.cardFill)
                                        .overlay(RoundedRectangle(cornerRadius: 14)
                                            .strokeBorder(
                                                focusedField == .author ? theme.accent.opacity(0.5) : theme.cardBorder,
                                                lineWidth: 1))
                                )
                        }

                        // Add button
                        Button {
                            let t = text.trimmingCharacters(in: .whitespacesAndNewlines)
                            let a = author.trimmingCharacters(in: .whitespacesAndNewlines)
                            if !t.isEmpty {
                                onSave(t, a.isEmpty ? "Unknown" : a)
                                dismiss()
                            }
                        } label: {
                            Text("Add Quote")
                                .font(.system(size: 17, weight: .semibold, design: .rounded))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    LinearGradient(colors: [Color(hex: "a78bfa"), Color(hex: "7c3aed")],
                                                   startPoint: .leading, endPoint: .trailing)
                                )
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        .opacity(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1)
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Add Quote")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(theme.toolbarScheme, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(theme.secondaryText)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        let t = text.trimmingCharacters(in: .whitespacesAndNewlines)
                        let a = author.trimmingCharacters(in: .whitespacesAndNewlines)
                        if !t.isEmpty { onSave(t, a.isEmpty ? "Unknown" : a); dismiss() }
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(theme.accent)
                    .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .onAppear { focusedField = .text }
    }
}
