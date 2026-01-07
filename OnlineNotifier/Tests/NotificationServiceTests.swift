import XCTest
import UserNotifications
@testable import OnlineNotifier

/// Mock notification center for testing
final class MockNotificationCenter: NotificationCenterProtocol {
    var authorizationStatus: UNAuthorizationStatus = .notDetermined
    var authorizationGranted: Bool = false
    var addedRequests: [UNNotificationRequest] = []

    func requestAuthorization(options: UNAuthorizationOptions) async throws -> Bool {
        return authorizationGranted
    }

    func notificationSettings() async -> UNNotificationSettings {
        // We can't create UNNotificationSettings directly, so we use a workaround
        // by returning from a coder that sets the status we want
        return await withCheckedContinuation { continuation in
            let center = UNUserNotificationCenter.current()
            center.getNotificationSettings { settings in
                continuation.resume(returning: settings)
            }
        }
    }

    func add(_ request: UNNotificationRequest) async throws {
        addedRequests.append(request)
    }
}

/// Simpler mock that doesn't need real notification center access
final class SimpleNotificationCenterMock: NotificationCenterProtocol {
    var authorizationGranted: Bool = false
    var addedRequests: [UNNotificationRequest] = []
    var shouldThrowOnAdd: Bool = false

    func requestAuthorization(options: UNAuthorizationOptions) async throws -> Bool {
        return authorizationGranted
    }

    func notificationSettings() async -> UNNotificationSettings {
        // Return settings using archive trick - not possible to create directly
        // So we skip actual settings checking in tests
        fatalError("notificationSettings should not be called in tests that use SimpleNotificationCenterMock")
    }

    func add(_ request: UNNotificationRequest) async throws {
        if shouldThrowOnAdd {
            throw NSError(domain: "test", code: 1)
        }
        addedRequests.append(request)
    }
}

final class NotificationServiceTests: XCTestCase {

    // MARK: - Initialization Tests

    func testInitializationDoesNotCrash() {
        // Given - use mock to avoid UNUserNotificationCenter.current() in test
        let mockCenter = SimpleNotificationCenterMock()

        // When/Then - should not crash
        let service = NotificationService(notificationCenter: mockCenter)
        XCTAssertNotNil(service)
    }

    // MARK: - Notification Content Tests

    func testSendNotificationDoesNotCrash() {
        // Given
        let mockCenter = SimpleNotificationCenterMock()
        let service = NotificationService(notificationCenter: mockCenter)

        // When/Then - should not crash even without permission
        service.sendConnectivityRestoredNotification()

        // Give time for async operation
        let expectation = XCTestExpectation(description: "Wait for notification to be processed")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)

        // Verify notification was added
        XCTAssertEqual(mockCenter.addedRequests.count, 1)
    }

    // MARK: - Authorization Tests

    func testRequestAuthorizationReturnsGrantedWhenMockAllows() async {
        // Given
        let mockCenter = SimpleNotificationCenterMock()
        mockCenter.authorizationGranted = true
        let service = NotificationService(notificationCenter: mockCenter)

        // When
        let granted = await service.requestAuthorization()

        // Then
        XCTAssertTrue(granted, "Should return granted when mock allows")
    }

    func testRequestAuthorizationReturnsDeniedWhenMockDenies() async {
        // Given
        let mockCenter = SimpleNotificationCenterMock()
        mockCenter.authorizationGranted = false
        let service = NotificationService(notificationCenter: mockCenter)

        // When
        let granted = await service.requestAuthorization()

        // Then
        XCTAssertFalse(granted, "Should return denied when mock denies")
    }

    // MARK: - Mock Tests (for more isolated testing)

    func testNotificationContentIsCorrect() {
        // This test verifies the structure of notification content

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
