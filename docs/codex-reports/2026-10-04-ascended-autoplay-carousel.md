# Ascended 0.8.0 (9): autoplay cave card library

## Request and delivered behavior

The user requested one automatically running GIF with an ordered card library below and left/right browsing. Replaced the vertical list of manual Play/Pause clips with a large looping selected GIF, natural direction underneath and a horizontal library of numbered square cards. Swipe the large GIF to go forward/back, tap a card to jump, or use previous/next arrows. The selected card has a cyan outline and follows the selected page; position is shown within the section. Browsing the card strip alone preserves the selected page until a card is tapped. No manual Play tap or automatic jump to the next route step.

Multi-section caves keep an explicit branch/phase selector. Section changes reset to the first step and never merge alternative paths. Continuation clips inherit the relevant preceding phase direction, so useful instructions remain beneath the current GIF. A poster stays visible until the local GIF document finishes loading. Only the selected page mounts a nonpersistent local WKWebView; view exit/inactive scene removes it. All 467 source GIFs/posters, coordinates, map-scoped progress, white icons and full-video chapters are preserved.

## Scope and verification

Standalone checkout `/Users/admin/Ascended-iPad-Dev`, branch `codex/ascended-ipad-dev-20261003`; fetched clean baseline `7f9e48492a203bca27755521b31d489972d14c4b`. Changes are limited to `CaveGIFs.swift`, the affected cave UI tests, version/project generation and delivery documentation. No Tony OS/SSD primary checkout/web files were changed.

Final fresh Simulator suite: **3 tests, 0 failures**, 111.647 seconds, `TEST SUCCEEDED` in `/tmp/Ascended-Carousel-Final-09.xcresult` and `/tmp/ascended-carousel-final-tests.log`:

- Autoplay animation before any Play tap, main GIF left/right paging, selected-card autoplay animation, matching counter/selection, disabled first/last arrows, and map isolation across all three maps.
- Branch selection/reset, square card geometry, horizontal browsing to the final card, unchanged selection while browsing and jump on card tap.
- Existing compact Base/Hang tiles and full-video chapter presentation/return on all three maps.

Initial branch-card test tried swiping a first card after it had moved offscreen. Corrected the test gesture to use the visible library viewport; the final suite above includes the correction. A selected-page loading screenshot exposed a brief black frame; retaining the poster until document-ready resolved that in the final code. Final screenshot was visually reviewed and retained in `assets/ascended-0.8.0/autoplay-card-library.png`.

Final signed device build succeeded (`/tmp/ascended-carousel-device-build-final.log`). Cable installation succeeded (`/tmp/ascended-carousel-device-install.log`); CoreDevice inventory confirms bundle `com.tonytuanngoc.ascended`, **0.8.0 / build 9**, developer-built (`/tmp/ascended-carousel-device-apps.json`). Direct physical iPad launch succeeded at **11:13:48 on 4 October 2026**, log `/tmp/ascended-carousel-device-launch.log`. Physical touch/animation QA is not claimed: the earlier device automation initialization timeout is documented in the 0.7 receipt; this release's interaction evidence is from Simulator. `git diff --check` passed.

Native deployment is cable installation. No TestFlight upload or web domain applies. Repository changes are committed/pushed on the standalone branch.
