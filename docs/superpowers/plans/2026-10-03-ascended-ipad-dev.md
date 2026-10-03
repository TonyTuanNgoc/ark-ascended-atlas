# Ascended iPad development implementation plan
Goal: cable-install Ascended v1 with only Ragnarok.
Architecture: native SwiftUI shell, UIKit UIScrollView map, bundled attributed images, AppStorage notes. No third party SDKs.
Spec: docs/superpowers/specs/2026-10-03-ascended-ipad-dev.md
Execution: user explicitly requested implementation in this chat; implement inline.

- [x] Generate native/Ascended Xcode project with independent signing and original game icon.
- [x] Implement overview, offline zoomable map, persistent notes and source links.
- [x] Build and QA native navigation, landscape/portrait, zoom/reset and notes after relaunch.
- [x] Build signed development app, install and launch on iPad.
- [x] Record exact verification, commit/push and native installation receipt; report unavailable existing web domain.
Review focus: narrow portrait layouts, sidebar selection, zoom after resize, notes on relaunch, no network use for core content.

## Extended execution checklist
- [x] Inventory current repo and migrated/archive copies without overwriting them.
- [x] Build source-linked 159-entry current Ragnarok creature catalogue with current profiles, offline icons, search/filter and dated historical notes.
- [x] Build 5 named boss profiles with correct main/dungeon encounter counts.
- [x] Bundle source-native 8K terrain and verify zoom controls/rotation.
- [x] Verify data exclusions, catalogue detail/navigation and persistence; signed build/install/update on physical iPad; commit and push.
