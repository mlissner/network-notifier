import SwiftUI

/// Main entry point for the Online Notifier app.
@main
struct OnlineNotifierApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var appState = AppState()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView(appState: appState)
                .onAppear {
                    // Connect AppDelegate to AppState for background task handling
                    appDelegate.appState = appState
                }
                .onChange(of: scenePhase) { oldPhase, newPhase in
                    switch newPhase {
                    case .background:
                        appState.handleEnterBackground()
                    case .active:
                        appState.handleEnterForeground()
                    case .inactive:
                        break
                    @unknown default:
                        break
                    }
                }
        }
    }
}
