import UIKit
import BackgroundTasks

/// AppDelegate handles app lifecycle events and background task registration.
class AppDelegate: NSObject, UIApplicationDelegate {

    /// Reference to the shared app state - set by OnlineNotifierApp
    weak var appState: AppState?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // Background task registration must happen before app finishes launching
        // The actual handler is set up via appState after it's created
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: BackgroundTaskManager.taskIdentifier,
            using: nil
        ) { [weak self] task in
            self?.handleBackgroundTask(task as! BGAppRefreshTask)
        }

        return true
    }

    private func handleBackgroundTask(_ task: BGAppRefreshTask) {
        // Schedule the next task
        scheduleNextBackgroundTask()

        // Set up expiration handler
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }

        // Perform connectivity check via AppState
        Task { @MainActor in
            self.appState?.performConnectivityCheck()
        }

        // Mark task as complete
        task.setTaskCompleted(success: true)
    }

    private func scheduleNextBackgroundTask() {
        let request = BGAppRefreshTaskRequest(identifier: BackgroundTaskManager.taskIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60)

        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Failed to schedule background task: \(error)")
        }
    }
}
