// File: ThemeManager.swift
import SwiftUI
import Combine
 
final class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
 
    @AppStorage("is_dark_theme") var isDark: Bool = true
 
    // MARK: - Градієнт фону
    var backgroundGradient: LinearGradient {
        isDark
            ? LinearGradient(
                colors: [Color(hex: "0f0c29"), Color(hex: "302b63"), Color(hex: "24243e")],
                startPoint: .topLeading, endPoint: .bottomTrailing)
            : LinearGradient(
                colors: [Color(hex: "f0f4ff"), Color(hex: "e8eaf6"), Color(hex: "f5f0ff")],
                startPoint: .topLeading, endPoint: .bottomTrailing)
    }
 
    // MARK: - Основний текст
    var primaryText: Color {
        isDark ? .white : Color(hex: "1a1a2e")
    }
 
    // MARK: - Вторинний текст
    var secondaryText: Color {
        isDark ? .white.opacity(0.4) : Color(hex: "1a1a2e").opacity(0.45)
    }
 
    // MARK: - Карточка (fill)
    var cardFill: Color {
        isDark ? .white.opacity(0.07) : .white.opacity(0.85)
    }
 
    // MARK: - Карточка (border)
    var cardBorder: Color {
        isDark ? .white.opacity(0.12) : Color(hex: "a78bfa").opacity(0.2)
    }
 
    // MARK: - Акцент (фіолетовий — однаковий в обох темах)
    var accent: Color { Color(hex: "a78bfa") }
 
    // MARK: - Фон редактора/шіту
    var sheetBackground: Color {
        isDark ? Color(hex: "0f0c29") : Color(hex: "f5f0ff")
    }
 
    // MARK: - Секція label (ALL CAPS)
    var sectionLabel: Color {
        isDark ? .white.opacity(0.4) : Color(hex: "1a1a2e").opacity(0.4)
    }
 
    // MARK: - Divider
    var dividerColor: Color {
        isDark ? .white.opacity(0.1) : Color(hex: "a78bfa").opacity(0.15)
    }
 
    // MARK: - colorScheme для toolbar
    var toolbarScheme: ColorScheme { isDark ? .dark : .light }
}
