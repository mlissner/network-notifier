# Development Guide

This document covers how to build, test, and contribute to Online Notifier.

## Prerequisites

- Mac with Xcode 15 or later
- Apple Developer account ($99/year) - required for device testing and distribution
- iPhone running iOS 16.0 or later (for device testing)

## Project Structure

```
OnlineNotifier/
├── Sources/
│   ├── App/
│   │   ├── OnlineNotifierApp.swift    # Main entry point
│   │   └── AppDelegate.swift          # Background task registration
│   ├── Views/
│   │   └── ContentView.swift          # Main UI
│   ├── Services/
│   │   ├── ConnectivityMonitor.swift  # Network monitoring (NWPathMonitor)
│   │   ├── LocationMonitor.swift      # Background wake-ups (CLLocationManager)
│   │   ├── NotificationService.swift  # Local notifications
│   │   └── BackgroundTaskManager.swift # Periodic checks (BGTaskScheduler)
│   ├── Models/
│   │   └── AppState.swift             # Central state coordinator
│   └── Resources/
│       └── Localizable.xcstrings      # 20 language translations
├── Tests/
│   ├── ConnectivityMonitorTests.swift
│   ├── AppStateTests.swift
│   └── NotificationServiceTests.swift
├── Config/
│   └── Info.plist                     # Permission descriptions & background modes
├── README.md                          # User documentation
└── DEVELOPMENT.md                     # This file
```

## Setting Up the Xcode Project

### Step 1: Create a New Xcode Project

1. Open Xcode
2. File → New → Project
3. Select **iOS** → **App**
4. Configure the project:
   - Product Name: `OnlineNotifier`
   - Team: Select your Apple Developer team
   - Organization Identifier: `com.yourname` (or any reverse-domain identifier)
   - Interface: **SwiftUI**
   - Language: **Swift**
   - Uncheck "Include Tests" (we'll add them manually)
5. Click **Next** and save the project

### Step 2: Copy Source Files

1. In Xcode, delete the auto-generated `ContentView.swift` (move to trash)
2. In Finder, navigate to the `OnlineNotifier/Sources` folder
3. Drag the following folders into Xcode's project navigator (under the `OnlineNotifier` group):
   - `App/`
   - `Views/`
   - `Services/`
   - `Models/`

   When prompted:
   - Check "Copy items if needed"
   - Select "Create groups"
   - Ensure the target `OnlineNotifier` is checked

4. Delete the auto-generated `OnlineNotifierApp.swift` if Xcode created one

### Step 3: Add the Localization File

1. Drag `Sources/Resources/Localizable.xcstrings` into the project
2. Ensure the target is checked when prompted

### Step 4: Configure Info.plist

1. Select the project in the navigator (blue icon at top)
2. Select the `OnlineNotifier` target
3. Go to the **Info** tab
4. Add the following keys:

| Key | Type | Value |
|-----|------|-------|
| `NSLocationAlwaysAndWhenInUseUsageDescription` | String | `To notify you when you regain internet connection, we monitor location changes which correlate with network changes. Your location is never stored or shared.` |
| `NSLocationWhenInUseUsageDescription` | String | (same as above) |
| `NSLocationAlwaysUsageDescription` | String | (same as above) |

5. Add `BGTaskSchedulerPermittedIdentifiers` as an Array with one item:
   - Item 0: `com.onlinenotifier.connectivity-check`

### Step 5: Add Capabilities

1. Select the project in the navigator
2. Select the `OnlineNotifier` target
3. Go to **Signing & Capabilities** tab
4. Click **+ Capability** and add **Background Modes**
5. Check the following:
   - [x] Location updates
   - [x] Background fetch
   - [x] Background processing

### Step 6: Sign the App

1. In **Signing & Capabilities**, select your Team
2. Ensure "Automatically manage signing" is checked

## Running Tests

### From Xcode

1. Add a test target: File → New → Target → Unit Testing Bundle
2. Name it `OnlineNotifierTests`
3. Copy the test files from `Tests/` into the test target
4. Run tests: Cmd+U or Product → Test

### From Command Line

```bash
# Run tests using xcodebuild (requires Xcode project to be set up first)
xcodebuild test \
  -project OnlineNotifier.xcodeproj \
  -scheme OnlineNotifier \
  -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest' \
  -only-testing:OnlineNotifierTests
```

### Using Swift Package Manager (for logic tests only)

The test files can also be run as a Swift package for unit tests that don't require iOS frameworks:

```bash
swift test
```

Note: Some tests require iOS simulator due to framework dependencies.

## Building for Device

### Direct Install (USB)

1. Connect iPhone to Mac via USB
2. Trust the computer on iPhone if prompted
3. Select iPhone as destination in Xcode toolbar
4. Click Play (Cmd+R)

### TestFlight Distribution

1. Product → Archive
2. Click **Distribute App**
3. Select **TestFlight & App Store**
4. Follow prompts to upload
5. In App Store Connect, add testers

## App Store Submission

1. In App Store Connect, create a new app
2. Fill in metadata:
   - App Name: Online Notifier
   - Subtitle: Know when you're back online
   - Category: Utilities
   - Privacy Policy URL: (required)
3. Prepare screenshots (6.7" and 6.5" iPhone sizes minimum)
4. Archive and upload from Xcode
5. App Privacy information:
   - Location: Used for app functionality, not collected
   - No other data collected
6. Submit for review

## Architecture

### Multi-Layer Monitoring

The app uses three layers to detect connectivity restoration:

1. **ConnectivityMonitor** (`NWPathMonitor`): Instant detection when app is in foreground
2. **LocationMonitor** (`CLLocationManager.startMonitoringSignificantLocationChanges`): Wakes app on location changes (WiFi/cell tower changes)
3. **BackgroundTaskManager** (`BGTaskScheduler`): Periodic fallback for stationary scenarios

### State Management

`AppState` is the central coordinator that:
- Manages monitoring enabled/disabled state (persisted in UserDefaults)
- Coordinates all three monitors
- Triggers notifications via `NotificationService`

### Localization

All user-facing strings are in `Localizable.xcstrings` using Apple's String Catalog format. Supported languages:
- English, Chinese (Simplified/Traditional), Spanish, Japanese, French, German, Portuguese (Brazil), Korean, Italian, Russian, Arabic, Dutch, Turkish, Polish, Swedish, Thai, Vietnamese, Indonesian, Hindi

## Troubleshooting Development Issues

### Build Errors

- Ensure Xcode 15+ is installed
- Clean build folder: Cmd+Shift+K
- Check all source files are added to the target

### Tests Not Running

- Verify test target is properly configured
- Check that `@testable import OnlineNotifier` works (may need to build main target first)
- Ensure iOS Simulator is available

### Background Monitoring Not Working

- Verify all three background modes are enabled in capabilities
- Check Info.plist has correct permission strings
- Test on real device (simulator has limitations)

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Ensure tests pass
5. Submit a pull request

Please follow the existing code style and add tests for new functionality.
