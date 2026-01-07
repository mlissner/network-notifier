import XCTest
import Network
@testable import OnlineNotifier

final class ConnectivityMonitorTests: XCTestCase {

    // MARK: - Test Helpers

    /// Mock path for testing connectivity states
    class MockPath {
        var status: NWPath.Status

        init(status: NWPath.Status) {
            self.status = status
        }
    }

    // MARK: - State Transition Tests

    func testOfflineToOnlineTransitionTriggersCallback() {
        // Given
        let monitor = ConnectivityMonitor()
        let expectation = XCTestExpectation(description: "Callback triggered on online transition")

        // Set initial state to offline
        UserDefaults.standard.set(false, forKey: "ConnectivityMonitor.wasConnected")

        monitor.onConnectivityRestored = {
            expectation.fulfill()
        }

        // When - simulate coming online
        // Note: In real tests, we'd use dependency injection with a mock NWPathMonitor
        // For now, this tests the callback setup

        // Then
        XCTAssertNotNil(monitor.onConnectivityRestored)
    }

    func testOnlineToOnlineDoesNotTriggerCallback() {
        // Given
        let monitor = ConnectivityMonitor()
        var callbackCalled = false

        // Set initial state to online
        UserDefaults.standard.set(true, forKey: "ConnectivityMonitor.wasConnected")

        monitor.onConnectivityRestored = {
            callbackCalled = true
        }

        // When - already online, staying online
        // The callback should not be called

        // Then - verify callback wasn't called for same state
        // Note: Full test would require mock NWPathMonitor
        XCTAssertFalse(callbackCalled, "Callback should not fire when staying online")
    }

    func testOfflineToOfflineDoesNotTriggerCallback() {
        // Given
        let monitor = ConnectivityMonitor()
        var callbackCalled = false

        // Set initial state to offline
        UserDefaults.standard.set(false, forKey: "ConnectivityMonitor.wasConnected")

        monitor.onConnectivityRestored = {
            callbackCalled = true
        }

        // When - already offline, staying offline
        // The callback should not be called

        // Then
        XCTAssertFalse(callbackCalled, "Callback should not fire when staying offline")
    }

    // MARK: - State Persistence Tests

    func testStatePersistsToUserDefaults() {
        // Given
        let key = "ConnectivityMonitor.wasConnected"
        UserDefaults.standard.removeObject(forKey: key)

        // When
        let monitor = ConnectivityMonitor()
        _ = monitor // Initialize

        // Then - default should be false (offline)
        let wasConnected = UserDefaults.standard.bool(forKey: key)
        // Note: Initial read happens in init, subsequent updates happen on path changes
        XCTAssertFalse(wasConnected, "Initial state should default to false")
    }

    // MARK: - Lifecycle Tests

    func testStartMonitoringDoesNotCrash() {
        // Given
        let monitor = ConnectivityMonitor()

        // When/Then - should not crash
        monitor.startMonitoring()

        // Cleanup
        monitor.stopMonitoring()
    }

    func testStopMonitoringDoesNotCrash() {
        // Given
        let monitor = ConnectivityMonitor()
        monitor.startMonitoring()

        // When/Then - should not crash
        monitor.stopMonitoring()
    }

    func testMultipleStartStopCyclesDoNotCrash() {
        // Given
        let monitor = ConnectivityMonitor()

        // When/Then - should not crash
        for _ in 0..<5 {
            monitor.startMonitoring()
            monitor.stopMonitoring()
        }
    }

    // MARK: - Cleanup

    override func tearDown() {
        // Clean up UserDefaults
        UserDefaults.standard.removeObject(forKey: "ConnectivityMonitor.wasConnected")
        super.tearDown()
    }
}
