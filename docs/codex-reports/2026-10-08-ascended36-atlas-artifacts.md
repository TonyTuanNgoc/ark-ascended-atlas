# Ascended 0.35.0 (36) — Atlas artifact selection and cave previews

User-requested Simulator delivery. Standalone ARK repository, branch `codex/ascended-ipad-dev-20261003`; fetched remote before changes and started from clean, synchronized build 35.

## Result

- Selecting a location in Atlas keeps the user's zoom and pan. Farming, cave-detail maps and other existing ZoomableMap consumers retain their prior focus behavior.
- Selected artifact pin uses its artifact artwork on a bright background with a cyan highlight, at the existing map-specific coordinates.
- Artifact popup follows the pin while panning/zooming, starts below it when there is space, moves beside/above near edges, and adapts its width to zoom and available room so the pin remains exposed.
- Bold rounded artifact name, full Artifact of the prefix, aligned LAT/LON, and a top-right external-page style icon opening the linked cave detail. Removed the old lower-left artifact information shortcut from the artifact popup.
- Popup plays one existing local cave preview. Tapping the preview opens the larger sequential CaveGIFWalkthrough; the preview stops while that sheet is open. Closing the sheet preserves map zoom. Existing walkthrough tap-to-pause behavior is retained.
- Atlas pinch works across the popup and before any pin is selected. Double tap resets map view and closes the selected popup.

## Existing media scope

All 10 The Island artifacts resolve to their own map's cave guide with a bundled playable preview. Existing Ragnarok and The Center guides use the same map-local route lookup. Maps without saved cave loops retain their own artwork and cave-page link; no footage is borrowed from another map, no new source searches or Farming locations were added.

## Verification

Final `ascended36/reset.xcresult`: **9 tests passed, 0 failed** (7 AtlasPresentation unit tests; new Atlas36 UI flow; existing Atlas/creature-spawn regression flow). Test summary and screenshot attachments are in `ascended36/test-results.json` and `ascended36/screenshots/`.

The new UI test verifies: pinch before selection, double-tap fit, selecting Clever without changing zoom, selected visible pin, popup not intersecting that pin, linked cave preview opening/closing without changing zoom, pinch with popup open, reset, Hunter edge placement, and top-right cave page navigation. Unit checks include all 10 Island artifact clip associations and corner/edge popup placement.

Red run confirmed the original selection changed zoom from 1 to 4 and lacked preview/highlight. Intermediate builds required decomposition of the SwiftUI body and argument-order repair. Subsequent UI run exposed pinch interception by the overlay; the next run exposed double-tap reset interception. Both were corrected and the final nine-test run is green. Intermediate xcresults/logs remain local on SSD, not part of the source commit.

Visual review inspected the exported final Clever popup: pin exposed above the card, bright artwork, readable name/GPS, actual cave footage, and upper-right page icon.

## Delivery

Installed application Info.plist verified **0.35.0 / 36** on existing `Ascended iPad QA` (`20C9346D-B0E6-4239-8152-1D85ADD57BA6`, iPad A16, iOS 26.5). Fresh app launch PID 36999. Simulator-only delivery; no physical-device or TestFlight claim. This native product has no web deployment/domain.

SSD mounted `/dev/disk7s1`, checked before builds: 449 GiB available on SSD, 104 GiB on Mac. Reused existing ARK DerivedData and existing Simulator; no extra devices or caches created.
