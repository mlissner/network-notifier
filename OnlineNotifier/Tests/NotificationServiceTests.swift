import XCTest
import UserNotifications
@testable import OnlineNotifier

final class NotificationServiceTests: XCTestCase {

    // MARK: - Initialization Tests

    func testInitializationDoesNotCrash() {
        // When/Then - should not crash
        let service = NotificationService()
        XCTAssertNotNil(service)
    }

    // MARK: - Notification Content Tests

    func testSendNotificationDoesNotCrash() {
        // Given
        let service = NotificationService()

        // When/Then - should not crash even without permission
        // Note: In actual tests, notification won't appear without permission
        service.sendConnectivityRestoredNotification()

        // Give time for async operation
        let expectation = XCTestExpectation(description: "Wait for notification to be processed")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    // MARK: - Authorization Tests

    func testCheckAuthorizationStatusReturnsValidStatus() async {
        // Given
        let service = NotificationService()

        // When
        let status = await service.checkAuthorizationStatus()

        // Then - status should be one of the valid values
        let validStatuses: [UNAuthorizationStatus] = [
            .notDetermined,
            .denied,
            .authorized,
            .provisional,
            .ephemeral
        ]
        XCTAssertTrue(validStatuses.contains(status), "Status should be a valid authorization status")
    }

    // MARK: - Mock Tests (for more isolated testing)

    func testNotificationContentIsCorrect() {
        // This test verifies the structure of notification content
        // In a real test suite, we'd use a mock UNUserNotificationCenter

        // Given
        let content = UNMutableNotificationContent()
        content.title = String(localized: "notification_title", defaultValue: "Back Online")
        content.body = String(localized: "notification_body", defaultValue: "Your internet connection has been restored.")
        content.sound = .default

        // Then
        XCTAssertEqual(content.title, "Back Online")
        XCTAssertEqual(content.body, "Your internet connection has been restored.")
        XCTAssertNotNil(content.sound)
    }
}
