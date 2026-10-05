# Ascended portrait QA — 2026-10-05

Portrait rendering is now verified on the dedicated Ascended iPad QA Simulator, UUID `20C9346D-B0E6-4239-8152-1D85ADD57BA6` (iOS 26.5). The orientation diagnosis itself changed no app source, project orientation settings, version, user designs, or progress. A subsequently discovered narrow portrait rail was fixed by the root agent in `MapScreen.swift` and verified below.

## Diagnosis

Before the restart, rotating the Simulator bezel to portrait left both the system Home screen and Ascended sideways in landscape. This places the delivery failure below the app: an app-only orientation lock cannot explain the Home screen. The installed app supports all four iPad orientations, and its SwiftUI app declares no orientation lock. SpringBoard preferences contained `SBLastRotationLockedOrientationiPad = 0`; no enabled lock boolean was found.

A shutdown and boot of **only the dedicated Ascended simulator**, preserving its data, restored portrait system framebuffer and interface-orientation events. The exact internal Simulator defect is unproven; the observed cause was a stale Simulator orientation-delivery state. No product configuration change was necessary. Tony OS simulators were neither shut down nor modified.

## Test change and evidence

`Ascended19UITests.testPortraitHeaderGeometry` now fails, rather than skips, if actual app geometry does not rotate. It verifies landscape as a precondition, waits for actual portrait app geometry, checks that both map selectors remain hittable and inside the app without overlapping, and asserts screenshot width is less than height. It retains geometry and screenshot attachments.

Three focused runs passed after the restart, including the final stricter run after the rail fix: 1 test, 0 failures, 0 skips. `-collect-test-diagnostics never` was used.

- Final result: `/Volumes/TONY SSD/ASCENDED_MEDIA/builds/Ascended-Portrait-Readable.xcresult`
- Final log: `/Volumes/TONY SSD/ASCENDED_MEDIA/builds/Ascended-Portrait-Readable.log`
- Pixel proof: `/Volumes/TONY SSD/ASCENDED_MEDIA/builds/Ascended-Portrait-Readable-Proof/20E44994-267D-4DB6-8EE1-D4D019E496D8.png` — actual PNG 1640 × 2360 pixels.
- Geometry: `/Volumes/TONY SSD/ASCENDED_MEDIA/builds/Ascended-Portrait-Readable-Proof/CCCBB2EC-2970-490E-80B9-B6A842C716FC.txt`
- App frame: `(0, 0, 820, 1180)` points.
- Story Maps: `(427, 57, 157.5, 44)` points.
- Exploration Maps: `(596.5, 58, 203.5, 42.5)` points.
- XCTest log records interface transition `Landscape Right` → `Portrait`.

## Portrait rail regression found and verified

The first real portrait screenshot exposed severe word fragmentation in the map rail. The root agent changed the rail from a portrait minimum of 190 points to 240 points. This agent did not edit product source. The final screenshot visibly shows `Cave Entrances` on two whole-word lines and `Resources` and `My Locations` on one line, without word fragmentation. The test now also asserts these expansion labels exist and their button heights stay at or below 50 points, preventing a return to three or more lines at the tested default type size.

The final result is actual portrait UI with visible non-overlapping header selectors and readable map rail. No physical-device, TestFlight, public domain, or deployment proof is implied.
