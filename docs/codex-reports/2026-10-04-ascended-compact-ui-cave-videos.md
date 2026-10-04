# Ascended 0.6.0 (7) — compact cards and cave video chapters

## Implemented UI
Base and cave lists use responsive square cards with small corner radii, image, place name, short description and GPS. Shared cards have 8-point corners and 14-point padding. White Dino/Boss avatar rendering is retained. Removed Notes and Sources destinations from navigation without erasing stored notes/progress. Removed research dates, provenance panels, source links, base popularity/methodology panels, caption metadata and internal node counts from player screens. Reworded map copy for gameplay. Source URLs, licence/provenance and confidence records remain in bundled data or reports. Useful gameplay information—gear, coordinates, difficulty, HP, breed, risks—remains visible.

## Icon review
| Action | Display | Status |
|---|---|---|
| Open map from overview/base/cave/artifact | map icon | Implemented |
| Open Dino/Boss from overview | paw/shield | Implemented |
| Open army from campaign | paw | Implemented, 44-point hit area |
| Open base profile from map | house | Implemented |
| Choose map layer | diamond/mountain/shield/house | Implemented, labels retained for accessibility |
| Find location | magnifying glass | Implemented |
| Play base video | play rectangle | Implemented |
| Play cave chapter | play circle + chapter title/time | Implemented; title needed to identify route stage |
| Zoom/reset/close | plus/minus/expand/x | Existing controls retained |
| Sidebar categories, map/place names, GPS, gear and route instructions | readable text | Retained for recognition and navigation |

## Cave research and current delivery limit
Inspected 13 public ASA video metadata records: Frodo the Dodo's comprehensive Ragnarok artefact/Labyrinth guide, Kittykatlapurr's Center entrance/artefact guide, and 11 NoobGamer ASA Island cave/Tek Cave guides from the creator's ASA playlist. Covered all 26 catalogued routes: Ragnarok 6, Island 11, Center 9. The 119 timestamp links are creator chapter metadata, not independently verified turn-by-turn directions. Embedded a native SFSafariViewController sheet for each chapter URL; online playback is provided by YouTube, not bundled/offline media. The Island cave-tour candidate PpMUczTy3EM was rejected as a base-oriented tour with ambiguous artifact labels.

Detailed evidence: 2026-10-04-ascended-cave-video-research.json. Public API CC search was rejected, supported playlist/URL inspection worked. All inspected licence fields are unknown; none qualifies as verified Creative Commons. Download-plan ran for dB3V_7-s92s; no download/section/analyze commands were applied, no GIF/media copied. The user was asked to confirm owned/permitted video or verified CC-only scope through asynchronous input. Answer is still pending.

**Requested GIF walkthrough remains unfinished.** Before GIF work: confirm reuse rights, obtain authorized media through the skill's three gates, inspect actual route footage, cross-check ASA map/entrance and artifact pairing, then segment at landmarks/turns with overlapping continuity. Metadata alone is insufficient for exact left/right instructions; no invented walkthroughs or placeholder GIFs are delivered.

Skill gate: /Users/admin/.codex/skills/youtube-learning/SKILL.md explicitly requires “obtain explicit confirmation that the video is owned, permitted, licensed, or verified Creative Commons” before downloading for deep visual analysis.

## Verification
Initial UI suite passed 5/5 (zero failures, 177.984 seconds): /Users/admin/Ascended-QA-06.xcresult. A new test caught oversized accessibility bounds and inherited container identifiers hiding chapter buttons; fixed with clipped square card hit regions, combined accessibility labels, and removing the parent video identifier. The next failure was the test's old Safari Done label; observed real hierarchy has Close, and the source video/page loaded. Corrected the test to use Close and assert the chapter is hittable after dismissing the sheet. Final receipts are recorded below.

Signed build and initial physical cable install succeeded; launch receipt /tmp/ascended-06-launch.log confirms app opened. Inventory /tmp/ascended-06-device-apps.json confirms 0.6.0 (7). This is independent native deployment, no TestFlight, Tony OS or web deployment/new domain. Final build was reinstalled after verification.


Final targeted delivery QA: 2/2 tests passed with zero failures in 68.386 seconds (/Users/admin/Ascended-QA-06-delivery.xcresult), covering campaign/base round trips and compact-card/chapter presentation across all three maps. Explicit square geometry assertions passed; Safari chapter URL presentation and Close→hittable original chapter passed. Dataset audit confirms all 26 route IDs match their map catalogue and all 119 chapter ranges/IDs resolve. Visually inspected final compact grid and Jungle chapter screen in /Users/admin/Ascended-QA06-Delivery-Screenshots. Signed final build succeeded (/tmp/ascended-06-delivery-device-build.log), installed at 09:21 and launched successfully (/tmp/ascended-06-delivery-install.log, /tmp/ascended-06-delivery-launch.log). No physical touch/whole-route gameplay QA is claimed.

Delivery checkout /Users/admin/Ascended-iPad-Dev, branch codex/ascended-ipad-dev-20261003, baseline a963ea9 matched fetched origin. Commit/push includes only standalone native changes, research and reports. UI/chapter-link release is complete; GIF extraction and verified turn-by-turn coverage remain pending required user input.
