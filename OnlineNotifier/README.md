# Online Notifier - iOS App

A simple iOS app that notifies you when your internet connection is restored. Perfect for knowing exactly when you can send that message or check your email after being offline.

## Features

- One-button interface: tap to enable, tap to disable
- Background monitoring using location-based wake-ups
- Local notifications when connectivity is restored
- No backend required - everything runs on-device
- Supports 20 languages

## How It Works

The app uses a multi-layer approach to detect when you come back online:

1. **Foreground**: Instant detection using Apple's Network framework
2. **Background**: Near-instant detection by monitoring significant location changes (which correlate with network changes like entering WiFi zones or changing cell towers)
3. **Fallback**: Periodic background refresh for stationary scenarios

## Requirements

- Mac with Xcode 15 or later
- Apple Developer account ($99/year) - for device testing and distribution
- iPhone running iOS 16.0 or later

---

## Setup Instructions (For the person with a Mac)

### Step 1: Create a New Xcode Project

1. Open Xcode
2. File → New → Project
3. Select **iOS** → **App**
4. Configure the project:
   - Product Name: `OnlineNotifier`
   - Team: Select your/the owner's Apple Developer team
   - Organization Identifier: `com.yourname` (or any reverse-domain identifier)
   - Interface: **SwiftUI**
   - Language: **Swift**
   - Uncheck "Include Tests" (we'll add them manually)
5. Click **Next** and save the project

### Step 2: Copy Source Files

Copy the provided source files into the Xcode project:

1. In Xcode, delete the auto-generated `ContentView.swift` (move to trash)

2. In Finder, navigate to the `OnlineNotifier/Sources` folder provided

3. Drag the following folders into Xcode's project navigator (under the `OnlineNotifier` group):
   - `App/` folder
   - `Views/` folder
   - `Services/` folder
   - `Models/` folder

   When prompted:
   - Check "Copy items if needed"
   - Select "Create groups"
   - Make sure the target `OnlineNotifier` is checked

4. Delete the auto-generated `OnlineNotifierApp.swift` if Xcode created one (we have our own)

### Step 3: Add the Localization File

1. Drag `Sources/Resources/Localizable.xcstrings` into the project
2. When prompted, ensure the target is checked

### Step 4: Configure Info.plist

1. Select the project in the navigator (blue icon at top)
2. Select the `OnlineNotifier` target
3. Go to the **Info** tab
4. Add the following keys by clicking the `+` button:

| Key | Type | Value |
|-----|------|-------|
| `NSLocationAlwaysAndWhenInUseUsageDescription` | String | `To notify you when you regain internet connection, we monitor location changes which correlate with network changes. Your location is never stored or shared.` |
| `NSLocationWhenInUseUsageDescription` | String | `To notify you when you regain internet connection, we monitor location changes which correlate with network changes. Your location is never stored or shared.` |
| `NSLocationAlwaysUsageDescription` | String | `To notify you when you regain internet connection, we monitor location changes which correlate with network changes. Your location is never stored or shared.` |

5. Add `BGTaskSchedulerPermittedIdentifiers` as an Array with one item:
   - Item 0: `com.onlinenotifier.connectivity-check`

### Step 5: Add Capabilities

1. Select the project in the navigator
2. Select the `OnlineNotifier` target
3. Go to **Signing & Capabilities** tab
4. Click **+ Capability** and add:
   - **Background Modes**
5. Under Background Modes, check:
   - [x] Location updates
   - [x] Background fetch
   - [x] Background processing

### Step 6: Sign the App

1. In **Signing & Capabilities**
2. Select your Team (Apple Developer account)
3. Ensure "Automatically manage signing" is checked
4. Xcode will create a provisioning profile

### Step 7: Build and Run

#### Option A: Direct Install (for testing)

1. Connect the iPhone to the Mac via USB
2. Trust the computer on the iPhone if prompted
3. Select the iPhone as the destination in Xcode (top bar)
4. Click the **Play** button (or Cmd+R)
5. Wait for the app to install and launch

#### Option B: TestFlight (for distribution)

1. Product → Archive
2. Once archived, click **Distribute App**
3. Select **TestFlight & App Store**
4. Follow the prompts to upload
5. In App Store Connect, add the iPhone owner as a tester
6. They can install via the TestFlight app

---

## Adding Unit Tests (Optional)

1. File → New → Target
2. Select **Unit Testing Bundle**
3. Name it `OnlineNotifierTests`
4. Copy the test files from `Tests/` folder into the new test target

---

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
│   │   ├── ConnectivityMonitor.swift  # Network monitoring
│   │   ├── LocationMonitor.swift      # Background wake-ups
│   │   ├── NotificationService.swift  # Local notifications
│   │   └── BackgroundTaskManager.swift # Periodic checks
│   ├── Models/
│   │   └── AppState.swift             # Central state
│   └── Resources/
│       └── Localizable.xcstrings      # 20 languages
├── Tests/
│   ├── ConnectivityMonitorTests.swift
│   ├── AppStateTests.swift
│   └── NotificationServiceTests.swift
├── Config/
│   └── Info.plist                     # Reference for permissions
└── README.md
```

---

## How to Use the App

1. Open the app
2. Tap the button to enable monitoring
3. Grant location permission when prompted (select "Always Allow" for best results)
4. Grant notification permission when prompted
5. That's it! You'll receive a notification whenever you come back online

To disable: Open the app and tap the button again.

---

## Troubleshooting

### "Location permission needed" warning
Go to Settings → Privacy & Security → Location Services → Online Notifier → select "Always"

### "Notification permission needed" warning
Go to Settings → Notifications → Online Notifier → enable "Allow Notifications"

### Notifications not appearing in background
- Ensure "Always" location permission is granted
- Background notifications may have a slight delay when stationary
- Works best when moving (entering WiFi zones, changing cell towers)

### Build errors in Xcode
- Ensure you're using Xcode 15+
- Check that all source files are added to the target
- Clean build folder (Cmd+Shift+K) and rebuild

---

## App Store Submission (Optional)

If you want to publish to the App Store:

1. In App Store Connect, create a new app
2. Fill in the required metadata:
   - App Name: Online Notifier
   - Subtitle: Know when you're back online
   - Category: Utilities
   - Privacy Policy URL: (you'll need to create one)
3. Prepare screenshots (at least for 6.7" and 6.5" iPhone sizes)
4. Archive and upload from Xcode
5. Fill in App Privacy information:
   - Location: Used for background monitoring, not collected
   - No other data collected
6. Submit for review

---

## Supported Languages

English, Chinese (Simplified), Chinese (Traditional), Spanish, Japanese, French, German, Portuguese (Brazil), Korean, Italian, Russian, Arabic, Dutch, Turkish, Polish, Swedish, Thai, Vietnamese, Indonesian, Hindi

---

## Privacy

- **Location**: Used only to wake the app in background when you move to new network areas. Never stored or transmitted.
- **No data collection**: Everything runs locally on your device.
- **No backend**: No servers, no accounts, no tracking.

---

## License

MIT License - feel free to modify and distribute.
