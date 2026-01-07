import Foundation
import Network

/// Protocol for connectivity monitoring, enabling testability
protocol ConnectivityMonitoring: AnyObject {
    var isConnected: Bool { get }
    var onConnectivityRestored: (() -> Void)? { get set }
    func startMonitoring()
    func stopMonitoring()
    func checkAndNotifyIfRestored()
}

/// Monitors network connectivity using NWPathMonitor.
/// Detects transitions from offline to online and triggers callbacks.
final class ConnectivityMonitor: ConnectivityMonitoring {

    // MARK: - Properties

    private let monitor: NWPathMonitor
    private let queue: DispatchQueue
    private var wasConnected: Bool

    /// Current connectivity state
    private(set) var isConnected: Bool = false

    /// Called when connectivity is restored (offline → online transition)
    var onConnectivityRestored: (() -> Void)?

    // MARK: - UserDefaults Keys

    private enum Keys {
        static let wasConnected = "ConnectivityMonitor.wasConnected"
    }

    // MARK: - Initialization

    init(monitor: NWPathMonitor = NWPathMonitor(),
         queue: DispatchQueue = DispatchQueue(label: "com.onlinenotifier.connectivity", qos: .utility)) {
        self.monitor = monitor
        self.queue = queue
        self.wasConnected = UserDefaults.standard.bool(forKey: Keys.wasConnected)
    }

    // MARK: - Public Methods

    /// Starts monitoring network connectivity
    func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.handlePathUpdate(path)
        }
        monitor.start(queue: queue)
    }

    /// Stops monitoring network connectivity
    func stopMonitoring() {
        monitor.cancel()
    }

    /// Checks current connectivity and notifies if restored.
    /// Useful for background wake-ups where the monitor may not be active.
    func checkAndNotifyIfRestored() {
        let currentPath = monitor.currentPath
        handlePathUpdate(currentPath)
    }

    // MARK: - Private Methods

    private func handlePathUpdate(_ path: NWPath) {
        let nowConnected = path.status == .satisfied
        isConnected = nowConnected

        // Detect offline → online transition
        if nowConnected && !wasConnected {
            DispatchQueue.main.async { [weak self] in
                self?.onConnectivityRestored?()
            }
        }

        // Persist state for next launch / background wake
        wasConnected = nowConnected
        UserDefaults.standard.set(nowConnected, forKey: Keys.wasConnected)
    }
}
