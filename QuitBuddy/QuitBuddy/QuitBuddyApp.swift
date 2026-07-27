import SwiftUI
import SwiftData

@main
struct QuitBuddyApp: App {
    let container: ModelContainer
    
    init() {
        do {
            container = try ModelContainer(
                for: HabitRecord.self, JournalEntry.self, QuoteItem.self
            )
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .modelContainer(container)
                .onAppear {
                    NotificationManager.shared.requestPermission()
                }
        }
    }
}
