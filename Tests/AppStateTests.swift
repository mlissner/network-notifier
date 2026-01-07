import XCTest
import UserNotifications
@testable import OnlineNotifier

/// Mock notification center for AppState tests
private final class TestNotificationCenterMock: NotificationCenterProtocol, @unchecked Sendable {
    var authorizationGranted: Bool = true
    var authorizationStatus: UNAuthorizationStatus = .authorized

    func requestAuthorization(options: UNAuthorizationOptions) async throws -> Bool {
        return authorizationGranted
    }

    func getAuthorizationStatus() async -> UNAuthorizationStatus {
        return authorizationStatus
    }

    func add(_ request: UNNotificationRequest) async throws {
        // No-op for tests
    }
}

final class AppStateTests: XCTestCase {

    // Helper to create AppState with mock notification service
    @MainActor
    private func createTestAppState() -> AppState {
        let mockNotificationCenter = TestNotificationCenterMock()
        let notificationService = NotificationService(notificationCenter: mockNotificationCenter)
        return AppState(notificationService: notificationService)
    }

    // MARK: - Initial State Tests

    @MainActor
    func testInitialStateIsNotMonitoring() {
        // Given
        UserDefaults.standard.set(false, forKey: "AppState.isMonitoringEnabled")

        // When
        let appState = createTestAppState()

        // Then
        XCTAssertFalse(appState.isMonitoringEnabled, "Initial state should be not monitoring")
    }

    @MainActor
    func testRestoresPersistedMonitoringState() {
        // Given
        UserDefaults.standard.set(true, forKey: "AppState.isMonitoringEnabled")

        // When
        let appState = createTestAppState()

        // Then
        XCTAssertTrue(appState.isMonitoringEnabled, "Should restore persisted monitoring state")

        // Cleanup
        UserDefaults.standard.set(false, forKey: "AppState.isMonitoringEnabled")
    }

    // MARK: - Toggle Tests

    @MainActor
    func testToggleFromOffTurnsOn() async {
        // Given
        UserDefaults.standard.set(false, forKey: "AppState.isMonitoringEnabled")
        let appState = createTestAppState()
        XCTAssertFalse(appState.isMonitoringEnabled)

        // When
        await appState.toggleMonitoring()

        // Then
        XCTAssertTrue(appState.isMonitoringEnabled, "Toggle from off should turn on")

        // Cleanup
        await appState.disableMonitoring()
    }

    @MainActor
    func testToggleFromOnTurnsOff() async {
        // Given
        let appState = createTestAppState()
        await appState.enableMonitoring()
        XCTAssertTrue(appState.isMonitoringEnabled)

        // When
        await appState.toggleMonitoring()

        // Then
        XCTAssertFalse(appState.isMonitoringEnabled, "Toggle from on should turn off")
    }

    // MARK: - Persistence Tests

    @MainActor
    func testEnableMonitoringPersistsState() async {
        // Given
        UserDefaults.standard.set(false, forKey: "AppState.isMonitoringEnabled")
        let appState = createTestAppState()

        // When
        await appState.enableMonitoring()

        // Then
        let persistedValue = UserDefaults.standard.bool(forKey: "AppState.isMonitoringEnabled")
        XCTAssertTrue(persistedValue, "Enabled state should be persisted")

        // Cleanup
        await appState.disableMonitoring()
    }

    @MainActor
    func testDisableMonitoringPersistsState() async {
        // Given
        let appState = createTestAppState()
        await appState.enableMonitoring()

        // When
        await appState.disableMonitoring()

        // Then
        let persistedValue = UserDefaults.standard.bool(forKey: "AppState.isMonitoringEnabled")
        XCTAssertFalse(persistedValue, "Disabled state should be persisted")
    }

    // MARK: - Background/Foreground Tests

    @MainActor
    func testHandleEnterBackgroundDoesNotCrash() async {
        // Given
        let appState = createTestAppState()
        await appState.enableMonitoring()

        // When/Then - should not crash
        appState.handleEnterBackground()

        // Cleanup
        await appState.disableMonitoring()
    }

    @MainActor
    func testHandleEnterForegroundDoesNotCrash() async {
        // Given
        let appState = createTestAppState()
        await appState.enableMonitoring()

        // When/Then - should not crash
        appState.handleEnterForeground()

        // Cleanup
        await appState.disableMonitoring()
    }

    @MainActor
    func testConnectivityCheckDoesNotCrash() async {
        // Given
        let appState = createTestAppState()
        await appState.enableMonitoring()

        // When/Then - should not crash
        appState.performConnectivityCheck()

        // Cleanup
        await appState.disableMonitoring()
    }

    // MARK: - Cleanup

    override func tearDown() async throws {
        await MainActor.run {
            UserDefaults.standard.removeObject(forKey: "AppState.isMonitoringEnabled")
            UserDefaults.standard.removeObject(forKey: "ConnectivityMonitor.wasConnected")
        }
        try await super.tearDown()
    }
}
