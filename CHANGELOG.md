# Changelog

All notable changes to UTCMenuClock are documented here. Dates use the
commit date from the repository history.

## 1.4 - 2025-12-11
- Modernized for macOS 15 / Xcode 16 and enabled ARC.
- Reduced CPU usage and tightened timer scheduling tolerance.
- Switched the menubar clock to monospaced digits and cleaned compiler warnings.

## 1.3 — 2022-10-07
- Added ISO-8601 display override and a separate “Copy as ISO-8601” action.
- Added clipboard copy for the current UTC string that respects user format.
- Fixed menu starting state, preference handling, and refreshed release packaging.

## 1.2.3 — 2016-12-25
- Added AM/PM support alongside the existing 24-hour display.
- Shipped new app icons and proper release configuration; published the 1.2.3 zip.
- Miscellaneous cleanups and README updates.

## 1.1 — 2012-08-31
- Added Julian date option, timezone suffix toggle, and improved default preferences.
- Introduced the “Show Seconds” toggle and refactored preference getters.
- Added the PackageMaker project and installer adjustments.

## 1.0 — 2011-11-14
- Initial public release: UTC menubar clock with show-date toggle, GitHub link, and open-at-login support.
- Added credits entry and Apache 2.0 licensing.
