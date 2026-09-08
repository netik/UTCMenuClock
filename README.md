# UTCMenuClock

UTCMenuClock is a lightweight macOS menubar app that keeps Coordinated
Universal Time (UTC) visible at all times. It is handy for operations
teams, distributed work, aviation, astronomy, or anyone who needs a
reliable UTC reference next to the system clock.

## Features
- UTC clock in the menu bar using the system menu bar font (`menuBarFontOfSize`, 14pt) to match the macOS clock.
- Toggle 24-hour/12-hour display, seconds, date, Julian day, and timezone suffix.
- ISO-8601 override for the menubar text plus “Copy as ISO-8601.”
- Copy the current UTC timestamp (using your selected format) to the clipboard.
- “Open at Login” toggle built into the menu.

## Download prebuilt binary
- Grab the unsigned universal binary: [`downloads/UTCMenuClock_v1.6_universal.zip`](https://github.com/netik/UTCMenuClock/blob/master/downloads/UTCMenuClock_v1.6_universal.zip).
- Because the app is unsigned, macOS will warn on first launch. Use
  `Right Click > Open` to allow it, or permit it under System Settings → Privacy & Security.

## Build from source
- Requirements: macOS 15+, Xcode 16 (project is updated for ARC).
- Open `UTCMenuClock.xcodeproj`, select the `UTCMenuClock` scheme, then build & run.
- Code signing uses ad-hoc identity (`CODE_SIGN_IDENTITY = "-"`) so the project builds without an Apple Developer certificate. Debug builds disable hardened runtime so XCTest can load; Release builds keep hardened runtime enabled. To ship signed/notarized builds, set `CODE_SIGN_IDENTITY` to your Developer ID, restore `DEVELOPMENT_TEAM`, and archive from Xcode.
- App version is controlled by `MARKETING_VERSION` and `CURRENT_PROJECT_VERSION` in the Xcode target build settings.
- The built app will appear in Xcode’s derived data when using a Release build.

## Create installer or zip
The legacy PackageMaker project has been replaced with Apple’s modern
`pkgbuild` / `productbuild` tooling under `packaging/`.

```bash
./packaging/build-release.sh
```

This script:
1. Builds a Release universal `UTCMenuClock.app`
2. Writes `packaging/output/UTCMenuClock_<version>_installer.pkg`
3. Writes `packaging/output/UTCMenuClock_v<version>_universal.zip`

The `.pkg` installs the app into `/Applications` (system or user home,
depending on where the installer is run). Sign and notarize the package
before wide distribution if you use a Developer ID certificate.

## Using the app
- Launching the app adds the UTC clock to the menu bar; click it to open the menu.
- Menu items:
  - `Copy` copies the current UTC string using your chosen format.
  - `Copy as ISO-8601` copies an ISO-8601 UTC timestamp.
  - Toggles: `24 HR Time`, `Show Date`, `Show Seconds`, `Show Julian Date`,
    `Show Time Zone`, `Show ISO8601 Instead`.
  - `Open at Login` toggles a login item; `Quit` exits the app.
- When `Show ISO8601 Instead` is enabled, the other format toggles are disabled and
  the menubar displays a full ISO-8601 string.

## Troubleshooting
- Unsigned app: allow it via `Right Click > Open` or Security settings after the first block.
- If the clock stops updating after sleep, toggle a preference or restart the app
  to rebuild the timer (the app also listens for wake events).

## Credits
- Built and maintained by John Adams (`jna@retina.net`).
- LaunchAtLoginController by Ben Clark-Robinson (`ben.clarkrobinson@gmail.com`).
- Licensed under the Apache License 2.0. See `LICENSE` for details.
