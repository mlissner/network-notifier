# Online Notifier

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

- iPhone running iOS 16.0 or later
- Location permission (for background monitoring)
- Notification permission (for alerts)

## How to Use

1. Open the app
2. Tap the button to enable monitoring
3. Grant location permission when prompted (select "Always Allow" for best results)
4. Grant notification permission when prompted
5. That's it! You'll receive a notification whenever you come back online

To disable: Open the app and tap the button again.

## Troubleshooting

### "Location permission needed" warning
Go to Settings → Privacy & Security → Location Services → Online Notifier → select "Always"

### "Notification permission needed" warning
Go to Settings → Notifications → Online Notifier → enable "Allow Notifications"

### Notifications not appearing in background
- Ensure "Always" location permission is granted
- Background notifications may have a slight delay when stationary
- Works best when moving (entering WiFi zones, changing cell towers)

## Supported Languages

English, Chinese (Simplified), Chinese (Traditional), Spanish, Japanese, French, German, Portuguese (Brazil), Korean, Italian, Russian, Arabic, Dutch, Turkish, Polish, Swedish, Thai, Vietnamese, Indonesian, Hindi

## Privacy

- **Location**: Used only to wake the app in background when you move to new network areas. Never stored or transmitted.
- **No data collection**: Everything runs locally on your device.
- **No backend**: No servers, no accounts, no tracking.

## License

MIT License - feel free to modify and distribute.

## Contributing

See [DEVELOPMENT.md](DEVELOPMENT.md) for build instructions and development details.
