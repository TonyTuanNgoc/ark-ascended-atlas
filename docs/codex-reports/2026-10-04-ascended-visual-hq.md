# Ascended 0.10.0 (11): visual field guide and source-quality loops

Standalone native iPad scope, branch `codex/ascended-ipad-dev-20261003`, fetched from origin before editing. No Tony OS files or hosting configuration changed.

## Result
- Removed Hôm nay and outer map chooser; persistent map selection is in the left sidebar. Changing map opens its map and isolates all associated navigation and saved progress.
- Map covers the available viewport, with pan/zoom, smooth image sampling, rounded edges and floating controls. Cover fitting crops edges until panned; reset centers the map.
- Cave summaries place a cropped photo beside pictured hazards/enemies on wide layouts and stack on narrow layouts. Removed the redundant artifact section heading.
- GPS appears as vertical-axis latitude then horizontal-axis longitude, with accessible coordinate labels. Internal coordinate strings remain unchanged.
- Genuine item imagery for preparation, food, drops, immobilizers, tribute, team options and rewards. Creature/boss silhouettes remain white. Unknown images use a labelled generic symbol, never a different creature's picture.
- Explicit researched counts appear on image badges. Preparation quantities not specified by the source are editable per item and saved per map. Blank quantities are not invented recommended requirements. The amount field supports direct numeric entry as well as increments. Existing checklist and collection persistence keys are retained.
- Important prose remains accessible through a detail affordance; wayfinding descriptions stay directly below the clips. Alternative boss teams remain separate options.
- Existing reviewed clip ranges are re-encoded as silent 1920×1080 HEVC loops, using source cadence up to 60 fps. Source media are 1080p, so this is source-resolution playback, not 4K or lossless. AVPlayerLooper supplies automatic looping; only the selected active clip has a player. Posters persist until its first frame; background/exit teardown removes the player.

## Verification and deployment
- All 467 loops fully decoded and passed recipe/range/source-key, resolution/cadence/audio/duration and orphan-file audits. Breakdown: Ragnarok 189 / 6 routes; Island 148 / 10 routes; Center 130 / 9 routes. Movie bytes 5,413,780,431; total movies/posters 5,488,874,732 bytes. Report: `2026-10-04-hq-loop-validation.json`.
- Actual Swift matching fixtures verify explicit counts/ranges, aliases, HP/melee/level values, Iceworm versus Queen distinction and preservation of unknown item names; every referenced asset decodes. 351 visual definitions, 162 item images. Report: `2026-10-04-visual-facts-validation.json`.
- Source-versus-encode samples on all three maps: SSIM 0.972 / 0.980 / 0.984. Resolution/cadence are preserved; this is not lossless. Report: `2026-10-04-hq-sample-quality.json`.
- Full ten-test Simulator suite passed at `/Volumes/TONY SSD/ASCENDED_MEDIA/Ascended-Final-Visual-11.xcresult`, covering sidebar/map choice, zoom/pan/rotation/pins/layers, collection isolation/relaunch, pictured kit quantities/relaunch, boss difficulty/armies, base links, creature library, chapters, carousel branches and autoplay. Actual cropped video frames changed at different timestamps on every tested map; no tapping to start playback.
- Fixed a reproduced fast map-switch/sidebar selection race: remount only the detail NavigationStack and reset selection synchronously, preserving the sidebar identity. The exact formerly failing immediate switch→Boss test now passes. Final affected three-test suite passed at `Ascended-Stable-Sidebar-11.xcresult`, including collection/map isolation, sidebar/HD playback and per-Dino quantity units. Eleven distinct Simulator tests passed overall; the latest affected three were rechecked after the fix.
- Final signed build passed at `signed-stable-sidebar-build.log`; strict deep signature verification and bundled-media inventory passed (467 MP4s, zero legacy GIFs). Executable SHA-256 is in `2026-10-04-visual-build-receipt.json`.
- Final cable install succeeded, physical device inventory confirms Ascended 0.10.0 (11), and direct process launch succeeded at 15:23 on 4 October 2026. Receipt: `2026-10-04-visual-device-receipt.json`. Interaction/animation proof is from Simulator; no physical touch/animation QA is claimed.

## Sources and limitations
The existing reviewed recipes preserve source video IDs, licensed reuse evidence, timestamps and direction text. Original source SHA-256 hashes and render keys are retained in the HQ render manifest. Item-image URLs are recorded in `2026-10-04-visual-item-image-sources.json`, outside the player UI.

This release changes presentation and playback, without inventing new route geometry or telemetry. Unknown consumable recommendations remain unset. Exact combat needs vary by gear, character/tame stats and game settings.

No TestFlight upload or web deployment/domain is involved in this native cable release. Physical install/launch/version inventory and Simulator interaction proof are reported separately above.
