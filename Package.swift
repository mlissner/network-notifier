// swift-tools-version:6.2
import PackageDescription

let package = Package(
    name: "OnlineNotifier",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "OnlineNotifier",
            targets: ["OnlineNotifier"]
        ),
    ],
    targets: [
        .target(
            name: "OnlineNotifier",
            dependencies: [],
            path: "Sources",
            exclude: ["App/OnlineNotifierApp.swift", "Resources"],
            sources: [
                "Services/ConnectivityMonitor.swift",
                "Services/LocationMonitor.swift",
                "Services/NotificationService.swift",
                "Services/BackgroundTaskManager.swift",
                "Models/AppState.swift",
                "Views/ContentView.swift",
                "App/AppDelegate.swift"
            ]
        ),
        .testTarget(
            name: "OnlineNotifierTests",
            dependencies: ["OnlineNotifier"],
            path: "Tests"
        ),
    ]
)
