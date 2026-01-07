import XCTest
@testable import OnlineNotifier

@MainActor
final class AppStateTests: XCTestCase {

    // MARK: - Initial State Tests

    func testInitialStateIsNotMonitoring() {
        // Given
        UserDefaults.standard.set(false, forKey: "AppState.isMonitoringEnabled")

        // When
        let appState = AppState()

        // Then
        XCTAssertFalse(appState.isMonitoringEnabled, "Initial state should be not monitoring")
    }

    func testRestoresPersistedMonitoringState() {
        // Given
        UserDefaults.standard.set(true, forKey: "AppState.isMonitoringEnabled")

        // When
        let appState = AppState()

        // Then
        XCTAssertTrue(appState.isMonitoringEnabled, "Should restore persisted monitoring state")

        // Cleanup
        UserDefaults.standard.set(false, forKey: "AppState.isMonitoringEnabled")
    }

    // MARK: - Toggle Tests

    func testToggleFromOffTurnsOn() async {
        // Given
        UserDefaults.standard.set(false, forKey: "AppState.isMonitoringEnabled")
        let appState = AppState()
        XCTAssertFalse(appState.isMonitoringEnabled)

        // When
        await appState.toggleMonitoring()

        // Then
        XCTAssertTrue(appState.isMonitoringEnabled, "Toggle from off should turn on")

        // Cleanup
        await appState.disableMonitoring()
    }

    func testToggleFromOnTurnsOff() async {
        // Given
        let appState = AppState()
        await appState.enableMonitoring()
        XCTAssertTrue(appState.isMonitoringEnabled)

        // When
        await appState.toggleMonitoring()

        // Then
        XCTAssertFalse(appState.isMonitoringEnabled, "Toggle from on should turn off")
    }

    // MARK: - Persistence Tests

    func testEnableMonitoringPersistsState() async {
        // Given
        UserDefaults.standard.set(false, forKey: "AppState.isMonitoringEnabled")
        let appState = AppState()

        // When
        await appState.enableMonitoring()

        // Then
        let persistedValue = UserDefaults.standard.bool(forKey: "AppState.isMonitoringEnabled")
        XCTAssertTrue(persistedValue, "Enabled state should be persisted")

        // Cleanup
        await appState.disableMonitoring()
    }

    func testDisableMonitoringPersistsState() async {
        // Given
        let appState = AppState()
        await appState.enableMonitoring()

        // When
        await appState.disableMonitoring()

        // Then
        let persistedValue = UserDefaults.standard.bool(forKey: "AppState.isMonitoringEnabled")
        XCTAssertFalse(persistedValue, "Disabled state should be persisted")
    }

    // MARK: - Background/Foreground Tests

    func testHandleEnterBackgroundDoesNotCrash() async {
        // Given
        let appState = AppState()
        await appState.enableMonitoring()

        // When/Then - should not crash
        appState.handleEnterBackground()

        // Cleanup
        await appState.disableMonitoring()
    }

    func testHandleEnterForegroundDoesNotCrash() async {
        // Given
        let appState = AppState()
        await appState.enableMonitoring()

        // When/Then - should not crash
        appState.handleEnterForeground()

        // Cleanup
        await appState.disableMonitoring()
    }

    func testConnectivityCheckDoesNotCrash() async {
        // Given
        let appState = AppState()
        await appState.enableMonitoring()

        // When/Then - should not crash
        appState.performConnectivityCheck()

        // Cleanup
        await appState.disableMonitoring()
    }

    // MARK: - Cleanup

    override func tearDown() async throws {
        // Clean up UserDefaults
        UserDefaults.standard.removeObject(forKey: "AppState.isMonitoringEnabled")
        UserDefaults.standard.removeObject(forKey: "ConnectivityMonitor.wasConnected")
        try await super.tearDown()
    }
}
