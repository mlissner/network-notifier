import Foundation
import BackgroundTasks

/// Manages background task scheduling for periodic connectivity checks.
final class BackgroundTaskManager {

    // MARK: - Constants

    /// Background task identifier - must match Info.plist entry
    static let taskIdentifier = "com.onlinenotifier.connectivity-check"

    // MARK: - Properties

    /// Called when a background task runs - use to check connectivity
    var onBackgroundWake: (() -> Void)?

    // MARK: - Initialization

    init() {}

    // MARK: - Public Methods

    /// Registers the background task handler with the system.
    /// Must be called early in app launch (typically in AppDelegate).
    func registerBackgroundTask() {
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: Self.taskIdentifier,
            using: nil
        ) { [weak self] task in
            self?.handleBackgroundTask(task as! BGAppRefreshTask)
        }
    }

    /// Schedules the next background refresh task.
    /// Call this when the app enters background.
    func scheduleBackgroundTask() {
        let request = BGAppRefreshTaskRequest(identifier: Self.taskIdentifier)
        // Request earliest execution - iOS will schedule based on usage patterns
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60) // 15 minutes minimum

        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Failed to schedule background task: \(error.localizedDescription)")
        }
    }

    /// Cancels any pending background tasks.
    /// Call when monitoring is disabled.
    func cancelBackgroundTask() {
        BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: Self.taskIdentifier)
    }

    // MARK: - Private Methods

    private func handleBackgroundTask(_ task: BGAppRefreshTask) {
        // Schedule the next task immediately
        scheduleBackgroundTask()

        // Set up expiration handler
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }

        // Perform connectivity check
        onBackgroundWake?()

        // Mark task as complete
        task.setTaskCompleted(success: true)
    }
}
