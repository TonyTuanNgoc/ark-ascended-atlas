# Ascended 0.9.0 (10) — session dashboard and Jungle waypoint pilot

## Delivered scope
Standalone native iPad app; selecting Ragnarok, The Island or The Center opens Hôm nay. Cave target persists under a new map-specific key. Entrance map, existing route gear checklist and full cave route are linked directly; Ragnarok base layouts and boss campaign are accessible from the dashboard. Existing artifact and checklist keys are preserved.

Jungle Dungeon Hunter pilot links nine landmarks to the existing 16 reviewed GIFs. The main route excludes the recorded fall clip; recovery remains an explicit optional action at the wooden branch. Only the selected GIF runs, with view/scene lifecycle cleanup from the existing player. Selecting a waypoint or viewing footage never changes confirmed location. Explicit confirmation stores the location and previews the next landmark. A fixed confirmation button names its target. New-trip reset clears only this pilot's checkpoint. Artifact collection still requires its separate existing manual action.

Exit mode reverses the landmark card order, independently of outbound footage. Footage is explicitly labelled as inbound and not a verified return video. The diagram is an abstract connectivity sketch, not measured cave geometry, floor heights, distance, live game location, or a walkable 3D cave. Landscape uses an adaptive two-column diagram/GIF layout with a GIF-first vertical fallback; card thumbnails come from actual local footage.

## Clarified requirement still pending
User now requires an actual simplified cave interior, retaining rock walls, floors and junctions, with a manually controlled avatar (forward/back/turn) to rehearse navigation. User plays on Windows at an internet cafe and prepares the app on Mac. No cafe computer development installation or telemetry is required. Actual cave geometry and an accessible extraction environment are not established; no fabricated cave has been shipped. See 2026-10-04-ascended-walkable-3d-design.md for the candidate DevKit pipeline and explicit verification gates. This release does not complete that 3D requirement or the larger full-game progression planner.

## Verification
- Baseline checkout clean, fetched remote; only this native app/reports changed.
- First targeted suite: SessionNavigatorConfirmationAndResume and GIFCarouselSectionsAndOrderedCards passed (2/2), /tmp/Ascended-Session-10.xcresult.
- Changed default landing regression: MapSelectionIsolationAndProgress, RagnarokMapNavigation, CurrentCreatureLibraryAndBosses passed (3/3), /tmp/Ascended-Session-Regression-10.xcresult.
- Subsequent layout runs: session confirmation/resume flow passed; final receipt below.
- Signed physical-device build succeeded. Final installation/launch/version receipt below.
- Interaction and screenshot evidence are Simulator proof. Physical UI automation is not claimed; previous automation-enabling timeout was not retried.
- No TestFlight, Tony OS or web deployment. This delivery has no new website domain; deployment is the cable-installed native app.

## Final receipt
- Final layout test: testSessionNavigatorConfirmationAndResume passed 1/1 on 2026-10-04 11:41:20 +0700; /tmp/Ascended-Session-Layout-10.xcresult. Exported screenshot /tmp/Ascended-Session-Layout-10-attachments/F3CA0F0D-91C9-4D75-BB12-72AEDDC48C97.png visually confirms diagram beside the GIF and named fixed confirmation control.
- Final signed build: /tmp/ascended-session-layout-device.log, BUILD SUCCEEDED.
- Final cable install: /tmp/ascended-session-layout-install.log, installed on paired iPad A16 8FA117DA-854A-5EEB-AEFC-EE54036237A9 at 11:41:56 +0700.
- Direct physical launch succeeded 11:42:15 +0700, bundle com.tonytuanngoc.ascended. Version inventory saved to /tmp/ascended-session-device-apps.json.
