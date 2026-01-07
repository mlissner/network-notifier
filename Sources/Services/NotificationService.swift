import Foundation
import UserNotifications

/// Protocol for notification handling, enabling testability
protocol NotificationHandling: AnyObject {
    func requestAuthorization() async -> Bool
    func sendConnectivityRestoredNotification()
    func checkAuthorizationStatus() async -> UNAuthorizationStatus
}

/// Protocol for notification center operations, enabling testability
protocol NotificationCenterProtocol {
    func requestAuthorization(options: UNAuthorizationOptions) async throws -> Bool
    func getAuthorizationStatus() async -> UNAuthorizationStatus
    func add(_ request: UNNotificationRequest) async throws
}

/// Make UNUserNotificationCenter conform to our protocol
extension UNUserNotificationCenter: NotificationCenterProtocol {
    func getAuthorizationStatus() async -> UNAuthorizationStatus {
        let settings = await notificationSettings()
        return settings.authorizationStatus
    }
}

/// Handles local notification requests and delivery.
final class NotificationService: NotificationHandling {

    // MARK: - Properties

    private let notificationCenter: NotificationCenterProtocol

    // MARK: - Initialization

    init(notificationCenter: NotificationCenterProtocol? = nil) {
        // Only access UNUserNotificationCenter.current() when not in test environment
        self.notificationCenter = notificationCenter ?? UNUserNotificationCenter.current()
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
        return await notificationCenter.getAuthorizationStatus()
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

        Task {
            do {
                try await notificationCenter.add(request)
            } catch {
                print("Failed to send notification: \(error.localizedDescription)")
            }
        }
    }
}
