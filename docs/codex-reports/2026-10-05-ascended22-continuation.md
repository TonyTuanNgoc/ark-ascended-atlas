# Ascended 0.21.0 (22) — continuation

Standalone native iPad app. No Tony OS, TestFlight or web deployment. Preserve user designs, progress and personal locations.

## Content delivered

- 163 ASA source references, including126 cave entrances. Lost Colony and Astraeos add90 entrances.103 expansion entrance cards now open directly:5Scorched,8Aberration,25Lost Colony,65Astraeos. Reference geometry retains six outside-plane records without clamping or false pins. Cards distinguish source-atlas coordinates from independently calibrated game GPS, and terrain overview from an actual entrance photograph.
- External walkthrough links where canonical source metadata is known. Existing genuine offline walkthroughs remain. New entrance cards are not completed turn-by-turn media guides.
-95 previously missing practical creature profiles; remaining215 incomplete rows across11unchanged rosters. Field guides formerly stored but hidden in archive.notes now render in creature detail.178 duplicated update-note passages removed. Stats and uncertain acquisition remain unfilled/flagged.15 exact transparent species icons acquired or refreshed and rendered with the requested white silhouette style; normal source downloading stopped on429.
- Four campaign outlines enriched: Lost Colony encounter mechanics, Astraeos paired ascension, Extinction sequence/role preparation, Genesis controller mechanic cycle. Seven army guides/eight options distinguish primary encounter evidence from planning recommendations. Unverified numeric thresholds are absent; warning/confidence visible and empty stat panels hidden.
-54 filmed resource regions/162 distinct fully decoded offline loops,17 actual harvesting/loot guides and37 other evidence guides. Source footage1920×1080; packaged loops1280×720,24fps,mutedH264. New Blue Gem and wild-vegetable regions plus PlantSpeciesX seed proof on Ragnarok.54 spot images match recorded source hashes. Acquisition ledger454rows:75GPS reviewed,110mechanics references,5filmed methods,12native unavailable,252pending.

## Review and verification

Independent review found an unlinked Aberration artifact hidden once cave routes were added and source-atlas cave coordinates missing their visible limitation. Both fixed; standalone unlinked artifacts stay searchable alongside cave cards, and cave details disclose source-atlas provenance. Stable IDs and outside-plane omission have meaningful unit coverage. Final test/device evidence appended after completion.

First unit run occurred during media generation:17 cases, two missing-preview failures for the two new resource spots. Both imagesets were subsequently generated correctly; the final frozen run supersedes this transient result.

## Remaining work and source limits

215 creature profiles remain incomplete.252 acquisition category rows remain unverified; the original-map source categories still include generic mushroom types and Center Plant X, while Island Plant X is only a nonGPSmethod reference.37region/method guides do not depict real harvesting. Expansion entrance photographs, offline walkthroughs, full boss art/requirements, independent runtimeGPScalibration and11creator-video house examples remain partial.

Normal public requests succeeded after cooldown for15 species PNGs, then429 stopped acquisition. Video acquisition remains limited by public403; API diagnosis returnedAPI_KEY_INVALID, and nativeCốcCốc download discovery stayedSearching. No authentication/challenge/rate-limit bypass and no footage/GPS invented. Licensed usable cached footage was used for this delivery.

Evidence:2026-10-05-asa-reference-locations-continuation.md;2026-10-05-creature-profile-completion22.json;2026-10-05-species-icon-sources22.json;tools/evidence/RESOURCE_ACQUISITION.md;tools/evidence/resource-acquisition-ledger.json. Canonical campaign evidence URLs retained in bundled data.

## Final verification and native delivery

17 unit cases and all10 scoped UI cases passed across the main run and focused new-case retest. The first broad UI run passed9/10; the remaining failure was the test querying a SwiftUI Link as XCTest.Link while iPad exposes it as Button. The screenshot showed the actual walkthrough control. The selector was corrected, both new UI cases reran successfully, and application source remained unchanged. No hidden skips. Results:Test-Ascended-2026.10.05_10-05-18-+0700.xcresult and Test-Ascended-2026.10.05_10-10-44-+0700.xcresult in the Ascended Simulator build Logs/Test folder. Screenshots copied to ascended-0.21.0-22. Independent review confirmed both P2 fixes.

Signed device build succeeded.1332 bundled JSON/video/JPEG files match current source SHA256; strict/deep codesign verification passed. Fresh APFS-cloned delivery path: `/Volumes/TONY SSD/ASCENDED_MEDIA/builds/Ascended-0.21.0-22-final-delivery/Ascended.app`. USB install succeeded, database sequence1624. Fresh device inventory confirms0.21.0/build22 at the same installation URL, then native launch succeeded, process1431, at10:12local. Receipt:2026-10-05-ascended22-device-receipt.json. Installation and launch are proven; physical touch interaction/playback performance are not inferred from Simulator screenshots. No uninstall or user-data wipe. No TestFlight/web/domain deployment.
