import Foundation
import CoreLocation

/// Protocol for location monitoring, enabling testability
protocol LocationMonitoring: AnyObject {
    var authorizationStatus: CLAuthorizationStatus { get }
    var onLocationUpdate: (() -> Void)? { get set }
    func requestAuthorization()
    func startMonitoring()
    func stopMonitoring()
}

/// Monitors significant location changes to wake the app in background.
/// Used to trigger connectivity checks when the device moves to new network areas.
final class LocationMonitor: NSObject, LocationMonitoring {

    // MARK: - Properties

    private let locationManager: CLLocationManager

    /// Called when a significant location change is detected
    var onLocationUpdate: (() -> Void)?

    /// Current authorization status
    var authorizationStatus: CLAuthorizationStatus {
        locationManager.authorizationStatus
    }

    // MARK: - Initialization

    override init() {
        self.locationManager = CLLocationManager()
        super.init()
        locationManager.delegate = self
        locationManager.pausesLocationUpdatesAutomatically = false
    }

    // MARK: - Public Methods

    /// Requests "Always" location authorization
    func requestAuthorization() {
        locationManager.requestAlwaysAuthorization()
    }

    /// Starts monitoring for significant location changes
    func startMonitoring() {
        guard CLLocationManager.significantLocationChangeMonitoringAvailable() else {
            return
        }
        // Only enable background updates if the app is configured for it
        // This will fail in test environments without proper Info.plist configuration
        if Bundle.main.object(forInfoDictionaryKey: "UIBackgroundModes") != nil {
            locationManager.allowsBackgroundLocationUpdates = true
        }
        locationManager.startMonitoringSignificantLocationChanges()
    }

    /// Stops monitoring for significant location changes
    func stopMonitoring() {
        locationManager.stopMonitoringSignificantLocationChanges()
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationMonitor: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Significant location change detected - trigger connectivity check
        onLocationUpdate?()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        // Authorization changed - UI will react via published state in AppState
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Location errors are non-fatal for this app's purpose
        // The app will still work via foreground monitoring and background refresh
    }
}
