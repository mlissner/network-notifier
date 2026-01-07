import Foundation
import UserNotifications

/// Protocol for notification handling, enabling testability
protocol NotificationHandling: AnyObject {
    func requestAuthorization() async -> Bool
    func sendConnectivityRestoredNotification()
    func checkAuthorizationStatus() async -> UNAuthorizationStatus
}

/// Handles local notification requests and delivery.
final class NotificationService: NotificationHandling {

    // MARK: - Properties

    private let notificationCenter: UNUserNotificationCenter

    // MARK: - Initialization

    init(notificationCenter: UNUserNotificationCenter = .current()) {
        self.notificationCenter = notificationCenter
    }

    // MARK: - Public Methods

    /// Requests notification authorization from the user
    /// - Returns: Whether authorization was granted
    @discardableResult
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
            return granted
        } catch {
            return false
        }
    }

    /// Checks current notification authorization status
    func checkAuthorizationStatus() async -> UNAuthorizationStatus {
        let settings = await notificationCenter.notificationSettings()
        return settings.authorizationStatus
    }

    /// Sends a local notification informing the user that connectivity has been restored
    func sendConnectivityRestoredNotification() {
        let content = UNMutableNotificationContent()
        content.title = String(localized: "notification_title", defaultValue: "Back Online")
        content.body = String(localized: "notification_body", defaultValue: "Your internet connection has been restored.")
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil // Deliver immediately
        )

        notificationCenter.add(request) { error in
            if let error = error {
                print("Failed to send notification: \(error.localizedDescription)")
            }
        }
    }
}
