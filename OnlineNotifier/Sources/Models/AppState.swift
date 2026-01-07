import Foundation
import SwiftUI
import CoreLocation

/// Central state management for the app.
/// Coordinates all services and exposes state to the UI.
@MainActor
final class AppState: ObservableObject {

    // MARK: - Published Properties

    /// Whether monitoring is currently enabled
    @Published private(set) var isMonitoringEnabled: Bool = false

    /// Current connectivity status
    @Published private(set) var isConnected: Bool = false

    /// Location authorization status
    @Published private(set) var locationAuthStatus: CLAuthorizationStatus = .notDetermined

    /// Whether notifications are authorized
    @Published private(set) var notificationsAuthorized: Bool = false

    // MARK: - Services

    private let connectivityMonitor: ConnectivityMonitor
    private let locationMonitor: LocationMonitor
    private let notificationService: NotificationService
    let backgroundTaskManager: BackgroundTaskManager

    // MARK: - UserDefaults Keys

    private enum Keys {
        static let isMonitoringEnabled = "AppState.isMonitoringEnabled"
    }

    // MARK: - Initialization

    init(connectivityMonitor: ConnectivityMonitor = ConnectivityMonitor(),
         locationMonitor: LocationMonitor = LocationMonitor(),
         notificationService: NotificationService = NotificationService(),
         backgroundTaskManager: BackgroundTaskManager = BackgroundTaskManager()) {
        self.connectivityMonitor = connectivityMonitor
        self.locationMonitor = locationMonitor
        self.notificationService = notificationService
        self.backgroundTaskManager = backgroundTaskManager

        // Restore persisted state
        self.isMonitoringEnabled = UserDefaults.standard.bool(forKey: Keys.isMonitoringEnabled)
        self.locationAuthStatus = locationMonitor.authorizationStatus

        setupCallbacks()

        // If monitoring was enabled, resume it
        if isMonitoringEnabled {
            startAllMonitors()
        }
    }

    // MARK: - Public Methods

    /// Toggles monitoring on/off
    func toggleMonitoring() async {
        if isMonitoringEnabled {
            await disableMonitoring()
        } else {
            await enableMonitoring()
        }
    }

    /// Enables monitoring and requests necessary permissions
    func enableMonitoring() async {
        // Request notification permission
        let notifGranted = await notificationService.requestAuthorization()
        notificationsAuthorized = notifGranted

        // Request location permission
        locationMonitor.requestAuthorization()

        // Start monitoring
        isMonitoringEnabled = true
        UserDefaults.standard.set(true, forKey: Keys.isMonitoringEnabled)
        startAllMonitors()
    }

    /// Disables monitoring and stops all services
    func disableMonitoring() async {
        isMonitoringEnabled = false
        UserDefaults.standard.set(false, forKey: Keys.isMonitoringEnabled)
        stopAllMonitors()
    }

    /// Called when app enters background
    func handleEnterBackground() {
        if isMonitoringEnabled {
            backgroundTaskManager.scheduleBackgroundTask()
        }
    }

    /// Called when app enters foreground
    func handleEnterForeground() {
        updateAuthorizationStatuses()
        if isMonitoringEnabled {
            // Refresh connectivity state
            connectivityMonitor.checkAndNotifyIfRestored()
        }
    }

    /// Performs a connectivity check (used by background tasks)
    func performConnectivityCheck() {
        connectivityMonitor.checkAndNotifyIfRestored()
    }

    // MARK: - Private Methods

    private func setupCallbacks() {
        // When connectivity is restored, send notification
        connectivityMonitor.onConnectivityRestored = { [weak self] in
            guard let self = self, self.isMonitoringEnabled else { return }
            self.notificationService.sendConnectivityRestoredNotification()
        }

        // When location changes, check connectivity
        locationMonitor.onLocationUpdate = { [weak self] in
            self?.connectivityMonitor.checkAndNotifyIfRestored()
        }

        // When background task runs, check connectivity
        backgroundTaskManager.onBackgroundWake = { [weak self] in
            self?.connectivityMonitor.checkAndNotifyIfRestored()
        }
    }

    private func startAllMonitors() {
        connectivityMonitor.startMonitoring()
        locationMonitor.startMonitoring()

        // Update initial states
        isConnected = connectivityMonitor.isConnected
        locationAuthStatus = locationMonitor.authorizationStatus
    }

    private func stopAllMonitors() {
        connectivityMonitor.stopMonitoring()
        locationMonitor.stopMonitoring()
        backgroundTaskManager.cancelBackgroundTask()
    }

    private func updateAuthorizationStatuses() {
        locationAuthStatus = locationMonitor.authorizationStatus

        Task {
            let status = await notificationService.checkAuthorizationStatus()
            notificationsAuthorized = (status == .authorized)
        }
    }
}
