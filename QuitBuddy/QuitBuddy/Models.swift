// File: Models.swift
import Foundation
import SwiftData

// MARK: - Habit Record (main tracker data)
@Model
final class HabitRecord {
    var habitName: String
    var startDate: Date
    
    init(habitName: String = "Smoking", startDate: Date = Date()) {
        self.habitName = habitName
        self.startDate = startDate
    }
}

// MARK: - Journal Entry
@Model
final class JournalEntry {
    var text: String
    var date: Date
    
    init(text: String, date: Date = Date()) {
        self.text = text
        self.date = date
    }
}

// MARK: - Quote Item
@Model
final class QuoteItem {
    var text: String
    var author: String
    var isFavorite: Bool
    var isCustom: Bool
    
    init(text: String, author: String, isFavorite: Bool = false, isCustom: Bool = false) {
        self.text = text
        self.author = author
        self.isFavorite = isFavorite
        self.isCustom = isCustom
    }
}

// MARK: - Built-in quotes seed data
extension QuoteItem {
    static let defaults: [(text: String, author: String)] = [
        ("Every day is a new beginning. Take a deep breath and start again.", "Unknown"),
        ("The secret of getting ahead is getting started.", "Mark Twain"),
        ("You don't have to be great to start, but you have to start to be great.", "Zig Ziglar"),
        ("Believe you can and you're halfway there.", "Theodore Roosevelt"),
        ("It does not matter how slowly you go as long as you do not stop.", "Confucius"),
        ("Fall seven times, stand up eight.", "Japanese Proverb"),
        ("The best time to plant a tree was 20 years ago. The second best time is now.", "Chinese Proverb"),
        ("Strength does not come from physical capacity. It comes from an indomitable will.", "Mahatma Gandhi"),
        ("What lies behind us and what lies before us are tiny matters compared to what lies within us.", "Ralph Waldo Emerson"),
        ("You are stronger than you think.", "Unknown"),
        ("One day at a time — this is enough. Do not look back and grieve over the past.", "Unknown"),
        ("The only way out is through.", "Robert Frost"),
        ("Recovery is not a race. You don't have to feel guilty if it takes you longer than you thought it would.", "Unknown"),
        ("Your future self is watching you right now through your memories.", "Aubrey De Grey"),
        ("Every moment is a fresh beginning.", "T.S. Eliot")
    ]
}
