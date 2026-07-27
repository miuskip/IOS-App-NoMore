// File: NotificationManager.swift
import UserNotifications
import Foundation
import Combine

final class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    @Published var isScheduled: Bool = false

    private init() {}

    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .badge, .sound]
        ) { _, _ in }
    }

    func checkAuthorizationStatus(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus == .authorized)
            }
        }
    }

    func scheduleDaily(hour: Int, minute: Int) {
        cancelAll()

        let content = UNMutableNotificationContent()
        content.title = "Stay Strong 💪"
        content.body = "You've got this. Check your progress and keep going!"
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: true
        )

        let request = UNNotificationRequest(
            identifier: "quitbuddy.daily",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }

    func cancelAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
