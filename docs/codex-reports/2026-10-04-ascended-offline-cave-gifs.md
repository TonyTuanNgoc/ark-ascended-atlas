# Ascended 0.7.0 (8): offline cave walkthroughs

Standalone checkout `/Users/admin/Ascended-iPad-Dev`, branch `codex/ascended-ipad-dev-20261003`, fetched baseline `db6ea6b83e25aea65761fe01b92340e1ffe0fadc`. No Tony OS files, shared media runtime, primary SSD ARK checkout or web deployment changed. Licensed media reuse was explicitly approved by the user.

## Delivered behavior

| Map | Artifact-bearing routes | Local GIFs |
| --- | ---: | ---: |
| Ragnarok | 6 | 189 |
| The Island | 10 | 148 |
| The Center | 9 | 130 |
| Total | 25 | 467 |

GIFs follow the inspected forward footage in short sequential steps. Relevant landmarks, movement, hazards and interactions appear in conversational Vietnamese below the clip. Static posters load first; tapping plays a real local GIF and tapping again stops it. One clip is active; leaving the clip/map releases playback. GIFs use a nonpersistent local WKWebView with a data URL, no source-video download during playback, audio or external network requests. Full-video chapters remain collapsible above GIFs and use native Safari. Tek Cave has no artifact; its existing full-video chapters remain.

Square Base/Hang cards, icon actions, white Dino/Boss icons, map-scoped progress and the removal of Notes/source navigation are preserved. Source IDs, exact ranges, hashes, channels and review status remain in internal recipes rather than player-facing UI.

## Media verification and limits

All 467 GIFs were fully decoded frame by frame. Each has multiple frames, a 512×288 image, loop enabled, positive duration no greater than 16.25 seconds and a 640×360 poster. Actual time agrees with its source interval within 0.3 seconds. No orphan/missing/duplicate assets; recipe render hashes and every artifact-bearing route match the manifests. Assets total 2,457,032,172 bytes. Complete originals are retained outside Git; they support future higher-resolution re-renders.

Twenty-five used source MP4s passed actual last-video-packet checks against their final curated range and metadata duration, with SHA-256 recorded. This resolves the earlier HTTP 403/incomplete-prefix issue using an isolated yt-dlp 2026.08.19 runtime; shared Tony OS tools were not modified. No cookies, PO tokens, forced clients or access-control bypass was used. Cốc Cốc ordinary manual viewing/downloading is the user's future fallback preference; it was not the acquisition method claimed for this release.

Snow's GIF option requires unlocked Tek gear and Element; its full Yutyrannus video remains available for players without Tek. Frozen Dungeon's final Pack location demonstration uses Creative footage, explicitly stated below that step; the survival entrance/Queen path is separate. The Pyromane option requires paid DLC. Life's Labyrinth includes both branches and convergence; uncertain source button behavior is qualified rather than invented. Stationary combat/preparation/ads/return footage is shortened only with prerequisites and without claiming a tested battle outcome. Recorded meaningful falls/recovery/movement are retained.

Video inspection establishes the shown navigation, not a completed survival run in Tony's Single Player save, current-save spawn state or guaranteed combat success. Clips range from ASA releases in 2023–2025; a later game update can change mechanics or placement. Internal provenance supports refreshes. See acquisition report and per-map recipes for those qualifications.

## Fresh QA

- File validation, source integrity, Python syntax and `git diff --check`: passed. Every GIF/poster and all three manifests in the final signed device bundle also match source SHA-256; 467 bundled GIFs confirmed in `2026-10-04-cave-gif-bundle-validation.json`.
- Initial seven-case Simulator run: six cases passed; compact-video case had two assertions fail because the DisclosureGroup identifier propagated to chapter buttons.
- Fixed the group as an explicit accessible expand/collapse button. Fresh targeted run: both compact/video and local-GIF/map-isolation tests passed, 0 failures. Safari chapter presentation and return were verified on all three maps.
- Improved screenshot scrolling to show a whole GIF and its direction. Fresh playback/map-isolation run passed, 0 failures, including changing screenshots over time, play/pause and stopped state after changing maps. Screenshots visually reviewed in `assets/ascended-0.7.0/`.
- The five independent regressions passed: map zoom/portrait/landscape, artifact layers/boss difficulty, Dino/Boss library, boss armies/base links, and map progress across restart. No baseline regressions were observed.
- Final signed device build succeeded. Physical iPad installation succeeded; CoreDevice app inventory confirms `com.tonytuanngoc.ascended`, version **0.7.0**, build **8**, developer-built. Direct launch succeeded at 10:51 on 4 October 2026.
- Attempted physical UI automation failed before any test initialized: “Timed out while enabling automation mode.” Physical tap/animation QA is therefore not claimed. Device install/version/launch and Simulator interaction proof are separate.

## Evidence

- Simulator initial `/tmp/Ascended-GIF-08.xcresult`; targeted fix `/tmp/Ascended-GIF-Final-08.xcresult`; final viewport `/tmp/Ascended-GIF-Viewport-08.xcresult`.
- Signed build `/tmp/ascended-gif-device-build-final.log`; cable installation `/tmp/ascended-gif-device-install-08.log`; physical launch `/tmp/ascended-gif-device-launch-final.log`; version `/tmp/ascended-gif-device-apps-final.json`.
- Physical automation limitation `/tmp/Ascended-GIF-Physical-08.xcresult` and `/tmp/ascended-gif-physical-tests.log`.
- Durable validation `2026-10-04-cave-gif-validation.json`, source integrity `2026-10-04-cave-source-integrity.json`, and the three dated GIF recipes.

Native deployment is through cable; no TestFlight upload or official web domain applies. Media is committed/pushed in map-sized batches, then the native integration and delivery receipt, to keep each GitHub push below its pack-size limit.
