// File: MoneySavedView.swift
import SwiftUI
 
// MARK: - Money Saved Card
struct MoneySavedCard: View {
    let startDate: Date
    let currentTime: Date
 
    @EnvironmentObject private var theme: ThemeManager
    @AppStorage("money_cost_per_day")    private var costPerDay: Double = 0
    @AppStorage("money_currency")        private var currency: String = "$"
    @State private var isExpanded: Bool = false
 
    private var daysSince: Double {
        max(0, currentTime.timeIntervalSince(startDate)) / 86400
    }
 
    private var totalSaved: Double {
        daysSince * costPerDay
    }
 
    var body: some View {
        if costPerDay > 0 {
            VStack(spacing: 0) {

                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        isExpanded.toggle()
                    }
                } label: {
                    HStack {
                        Label("Money Saved", systemImage: "banknote")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundStyle(theme.sectionLabel)
                            .textCase(.uppercase)
                        Spacer()
                        HStack(spacing: 6) {
                            Text("\(currency)\(formatAmount(totalSaved))")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundStyle(Color(hex: "34d399"))
                                .contentTransition(.numericText(value: totalSaved))
                                .animation(.easeOut(duration: 0.4), value: totalSaved)
                            Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(theme.secondaryText)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
                .buttonStyle(.plain)
 
                if isExpanded {
                    Divider()
                        .background(Color(hex: "34d399").opacity(0.2))
                        .padding(.horizontal, 20)
 
                    VStack(spacing: 12) {
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text(currency)
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundStyle(Color(hex: "34d399"))
                            Text(formatAmount(totalSaved))
                                .font(.system(size: 44, weight: .black, design: .rounded))
                                .foregroundStyle(Color(hex: "34d399"))
                                .contentTransition(.numericText(value: totalSaved))
                                .animation(.easeOut(duration: 0.4), value: totalSaved)
                        }
 
                        Text("saved so far")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundStyle(theme.secondaryText)
 
                        HStack(spacing: 0) {
                            MoneyStat(
                                label: "today",
                                value: "\(currency)\(formatAmount(costPerDay * min(daysSince, 1)))",
                                theme: theme
                            )
                            Divider()
                                .frame(height: 32)
                                .background(theme.dividerColor)
                            MoneyStat(
                                label: "this week",
                                value: "\(currency)\(formatAmount(costPerDay * min(daysSince, 7)))",
                                theme: theme
                            )
                            Divider()
                                .frame(height: 32)
                                .background(theme.dividerColor)
                            MoneyStat(
                                label: "this month",
                                value: "\(currency)\(formatAmount(costPerDay * min(daysSince, 30)))",
                                theme: theme
                            )
                        }
                        .padding(.top, 4)
 
                        NavigationLink {
                            MoneySettingsView()
                                .environmentObject(theme)
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "pencil")
                                    .font(.system(size: 11, weight: .medium))
                                Text("Edit settings")
                                    .font(.system(size: 12, design: .rounded))
                            }
                            .foregroundStyle(theme.secondaryText)
                        }
                        .padding(.bottom, 4)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(theme.cardFill)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .strokeBorder(Color(hex: "34d399").opacity(0.3), lineWidth: 1)
                    )
            )
            .shadow(color: Color(hex: "34d399").opacity(0.08), radius: 12, x: 0, y: 4)
            .clipped()
        } else {
            NavigationLink {
                MoneySettingsView()
                    .environmentObject(theme)
            } label: {
                HStack(spacing: 14) {
                    Image(systemName: "banknote")
                        .font(.system(size: 22))
                        .foregroundStyle(Color(hex: "34d399"))
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Track money saved")
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundStyle(theme.primaryText)
                        Text("Set your daily spending to see savings")
                            .font(.system(size: 12, design: .rounded))
                            .foregroundStyle(theme.secondaryText)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(theme.secondaryText)
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(theme.cardFill)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .strokeBorder(Color(hex: "34d399").opacity(0.25), lineWidth: 1)
                        )
                )
            }
        }
    }
 
    private func formatAmount(_ value: Double) -> String {
        if value >= 1000 { return String(format: "%.0f", value) }
        else if value >= 10 { return String(format: "%.1f", value) }
        else { return String(format: "%.2f", value) }
    }
}
 
// MARK: - Stat subcomponent
private struct MoneyStat: View {
    let label: String
    let value: String
    let theme: ThemeManager
 
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(theme.primaryText)
            Text(label)
                .font(.system(size: 11, design: .rounded))
                .foregroundStyle(theme.secondaryText)
        }
        .frame(maxWidth: .infinity)
    }
}
 
// MARK: - Money Settings View
struct MoneySettingsView: View {
    @EnvironmentObject private var theme: ThemeManager
    @Environment(\.dismiss) private var dismiss
 
    @AppStorage("money_cost_per_day") private var costPerDay: Double = 0
    @AppStorage("money_currency")     private var currency: String = "$"
 
    @State private var inputText: String = ""
    @FocusState private var focused: Bool
 
    private let currencies = ["$", "€", "£", "₴", "zł", "Fr", "¥"]
 
    private let presets: [(label: String, subtitle: String, daily: Double)] = [
        ("½ pack/day",  "$5/day",  5),
        ("1 pack/day",  "$10/day", 10),
        ("2 packs/day", "$20/day", 20),
        ("Daily beer",  "$4/day",  4),
        ("Bar night",   "$25/day", 25),
        ("Custom",      "enter below", 0)
    ]
 
    var body: some View {
        ZStack {
            theme.backgroundGradient.ignoresSafeArea()
 
            ScrollView {
                VStack(spacing: 28) {
 
                    VStack(alignment: .leading, spacing: 10) {
                        Text("CURRENCY")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundStyle(theme.sectionLabel)
 
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(currencies, id: \.self) { c in
                                    Button {
                                        currency = c
                                    } label: {
                                        Text(c)
                                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                                            .foregroundStyle(currency == c ? .white : theme.primaryText)
                                            .frame(width: 52, height: 44)
                                            .background(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .fill(currency == c
                                                          ? Color(hex: "a78bfa")
                                                          : theme.cardFill)
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 12)
                                                            .strokeBorder(
                                                                currency == c ? Color.clear : theme.cardBorder,
                                                                lineWidth: 1
                                                            )
                                                    )
                                            )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
 
                    VStack(alignment: .leading, spacing: 10) {
                        Text("QUICK PRESET")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundStyle(theme.sectionLabel)
 
                        LazyVGrid(
                            columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())],
                            spacing: 8
                        ) {
                            ForEach(presets, id: \.label) { preset in
                                let isSelected = preset.daily > 0 && costPerDay == preset.daily
 
                                Button {
                                    if preset.daily > 0 {
                                        costPerDay = preset.daily
                                        inputText = String(format: "%.2f", preset.daily)
                                    } else {
                                        inputText = ""
                                        focused = true
                                    }
                                } label: {
                                    VStack(spacing: 4) {
                                        Text(preset.label)
                                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                                            .multilineTextAlignment(.center)
                                            .foregroundStyle(isSelected ? .white : theme.primaryText)
 
                                        Text(preset.subtitle)
                                            .font(.system(size: 10, design: .rounded))
                                            .foregroundStyle(isSelected ? .white.opacity(0.8) : theme.secondaryText)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 56)
                                    .background(
                                        RoundedRectangle(cornerRadius: 14)
                                            .fill(isSelected ? Color(hex: "a78bfa") : theme.cardFill)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 14)
                                                    .strokeBorder(theme.cardBorder, lineWidth: 1)
                                            )
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
 
                  
                    VStack(alignment: .leading, spacing: 10) {
                        Text("DAILY SPENDING (\(currency)/day)")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundStyle(theme.sectionLabel)
 
                        HStack(spacing: 12) {
                            Text(currency)
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundStyle(Color(hex: "34d399"))
                            TextField("0.00", text: $inputText)
                                .font(.system(size: 28, weight: .black, design: .rounded))
                                .foregroundStyle(theme.primaryText)
                                .keyboardType(.decimalPad)
                                .focused($focused)
                                .onChange(of: inputText) { _, newVal in
                                    if let v = Double(newVal.replacingOccurrences(of: ",", with: ".")) {
                                        costPerDay = v
                                    }
                                }
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(theme.cardFill)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .strokeBorder(
                                            focused ? Color(hex: "34d399").opacity(0.6) : theme.cardBorder,
                                            lineWidth: 1
                                        )
                                )
                        )
 
                        Text("How much did you spend per day on this habit?")
                            .font(.system(size: 12, design: .rounded))
                            .foregroundStyle(theme.secondaryText)
                    }
 
                    if costPerDay > 0 {
                        VStack(spacing: 12) {
                            Text("PROJECTION")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundStyle(theme.sectionLabel)
                                .frame(maxWidth: .infinity, alignment: .leading)
 
                            HStack(spacing: 0) {
                                projectionStat(label: "1 month",  value: costPerDay * 30)
                                projectionStat(label: "3 months", value: costPerDay * 90)
                                projectionStat(label: "1 year",   value: costPerDay * 365)
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(theme.cardFill)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .strokeBorder(Color(hex: "34d399").opacity(0.25), lineWidth: 1)
                                    )
                            )
                        }
                    }
 
                    // Save button
                    Button {
                        dismiss()
                    } label: {
                        Text("Save")
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: [Color(hex: "34d399"), Color(hex: "059669")],
                                    startPoint: .leading, endPoint: .trailing
                                )
                            )
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
 
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
        }
        .navigationTitle("Money Saved Setup")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(theme.toolbarScheme, for: .navigationBar)
        .onAppear {
            if costPerDay > 0 {
                inputText = String(format: "%.2f", costPerDay)
            }
        }
    }
 
    @ViewBuilder
    private func projectionStat(label: String, value: Double) -> some View {
        VStack(spacing: 4) {
            Text("\(currency)\(formatLarge(value))")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(Color(hex: "34d399"))
            Text(label)
                .font(.system(size: 11, design: .rounded))
                .foregroundStyle(theme.secondaryText)
        }
        .frame(maxWidth: .infinity)
    }
 
    private func formatLarge(_ value: Double) -> String {
        value >= 1000 ? String(format: "%.0f", value) : String(format: "%.0f", value)
    }
}
