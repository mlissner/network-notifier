import SwiftUI
import CoreLocation

/// Main view of the app - a single screen with a prominent toggle button.
struct ContentView: View {
    @ObservedObject var appState: AppState

    var body: some View {
        VStack(spacing: 40) {
            Spacer()

            // App title
            Text("app_title", tableName: nil, bundle: .main, comment: "App title")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            Spacer()

            // Main toggle button
            Button(action: {
                Task {
                    await appState.toggleMonitoring()
                }
            }) {
                VStack(spacing: 16) {
                    Image(systemName: appState.isMonitoringEnabled ? "wifi" : "wifi.slash")
                        .font(.system(size: 60))

                    Text(appState.isMonitoringEnabled ? "button_on" : "button_off", tableName: nil, bundle: .main, comment: "Button state")
                        .font(.title)
                        .fontWeight(.semibold)
                }
                .frame(width: 200, height: 200)
                .foregroundStyle(appState.isMonitoringEnabled ? .white : .primary)
                .background(
                    Circle()
                        .fill(appState.isMonitoringEnabled ? Color.accentColor : Color(.systemGray5))
                )
            }
            .buttonStyle(.plain)
            .accessibilityLabel(appState.isMonitoringEnabled ? "Disable monitoring" : "Enable monitoring")

            // Status text
            Text(statusText)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Spacer()

            // Permission warnings (if any)
            if appState.isMonitoringEnabled {
                permissionWarnings
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }

    // MARK: - Computed Properties

    private var statusText: LocalizedStringKey {
        if appState.isMonitoringEnabled {
            return "status_monitoring"
        } else {
            return "status_tap_to_start"
        }
    }

    @ViewBuilder
    private var permissionWarnings: some View {
        VStack(spacing: 8) {
            // Location permission warning
            if !isLocationAuthorized {
                HStack(spacing: 8) {
                    Image(systemName: "location.slash")
                        .foregroundStyle(.orange)
                    Text("warning_location", tableName: nil, bundle: .main, comment: "Location permission warning")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            // Notification permission warning
            if !appState.notificationsAuthorized {
                HStack(spacing: 8) {
                    Image(systemName: "bell.slash")
                        .foregroundStyle(.orange)
                    Text("warning_notifications", tableName: nil, bundle: .main, comment: "Notification permission warning")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.horizontal, 32)
    }

    private var isLocationAuthorized: Bool {
        switch appState.locationAuthStatus {
        case .authorizedAlways:
            return true
        case .authorizedWhenInUse, .denied, .restricted, .notDetermined:
            return false
        @unknown default:
            return false
        }
    }
}

#Preview {
    ContentView(appState: AppState())
}
