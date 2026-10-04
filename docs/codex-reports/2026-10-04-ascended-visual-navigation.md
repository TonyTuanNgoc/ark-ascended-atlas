# Ascended 0.11.0 (12) — direct cave walkthrough and accurate visual references

Standalone iPad app, branch `codex/ascended-ipad-dev-20261003`, based on clean/fetched `d55c160ac024d1ff40f07697a91453d1e3fea4ab`. No Tony OS changes. Native delivery is cable installation; this app has no web deployment/domain and does not use TestFlight.

## Result

Cave detail is one scrollable page: artifact image/name/GPS and entrance GPS, a deduplicated pictured equipment list, then the existing 1080p autoplay loop, its player-style direction, and small horizontal image cards. Artifact rows are informational rather than links to a separate page. Preparation has no checkboxes, amounts or add/edit controls. Existing collection progress remains in boss tribute profiles; existing saved quantities/checklists are not erased.

Removed ellipsis detail buttons from all modules. Useful brief conditions stay visible. Removed GIF headings, step counters, card numbers/titles and previous/next buttons; paging by swipe and selecting a card remain. Hunter's numbered landmark/schematic/confirmation screen now uses the same media carousel. Multi-artifact routes retain branch choice because opposite entrance paths must not be concatenated as one route.

Map pins use actual artifact art, cave/base pictures, a coloured game Obelisk silhouette and the Lava Elemental image, with names at fixed screen size and unchanged GPS anchors. Close points keep their selection menu. Tapping a point opens a dark floating information card with art/name/GPS/short context and relevant profile action; the map does not shrink. Terminals are labelled separately from the teleported boss arena. Lava is orange.

162 creature/boss image references now use game gallery images or verified ASA footage frames in original colours. Gallery acquisition excludes avatar icons, dossiers, concept art, paint-region demonstrations, costumes, skeletal substitutions and mod artwork. An audit caught two skeletal variant images incorrectly prioritised by the infobox path; both were replaced by named ASA Brontosaurus/Giganotosaurus gallery photos. Spirit bear and wolf use actual spectral animals in licensed Life's Labyrinth footage, with visible game identity evidence. Edition-unconfirmed wiki captures are recorded internally, not asserted as ASA captures.

Five base previews now use in-game photos, with exact `photoSource` provenance in `ragnarok-bases.json`. Three 1280×720 region photos come from the guide's named sections; the camera coordinate and approach pin can differ within the same region. Highlands and Viking Bay use original 320×180 public chapter storyboard frames with GPS matching their pins. Full licensed video downloads, including a standard advertised format, returned HTTP 403; browser automation was unattached. No access restrictions were bypassed, no generated place images, no artificial upscaling and no map-crop fallback.

## Content limits

13 catalogue entries still lack a verified suitable game photo: Aberrant Megalania, Lightning Wyvern, Mosasaurus, Oil Jug Bug, Pegomastax, Poison Wyvern, Purlovia, Rock Elemental, Tapejara, Thorny Dragon, Troodon, Vulture and Water Jug Bug. They retain name/data and a missing-photo state instead of a wrong species/head avatar. Gallery/API file searches are exhausted for this pass; do not treat model colour charts or mod/costume pictures as natural gameplay captures. The two 320×180 base photos remain visibly less sharp. Region photography does not certify build permission or the same foundation spot in Tony's save.

## Verification

Eleven distinct relevant Simulator UI scenarios passed across bounded runs: cave single-page preparation, named map popups, sidebar HD playback/map switching, map pinch/pan/reset and rotation, creature profiles/boss library, artifact map layers/Alpha boss selection, independent map collection persistence, boss army/base↔map profiles, army counts/per-Dino units, autoplay/swipe/card/map isolation, and separate artifact branch selection/horizontal card ordering.

Evidence under `/Volumes/TONY SSD/ASCENDED_MEDIA`: `Ascended-Visual-12-Final.xcresult`, `Ascended-Carousel-12.xcresult` (three relevant passes; obsolete branch test failed), `Ascended-Carousel-12-Final.xcresult` (two passes), `Ascended-Markers-12-Verified.xcresult` (final named marker pass), and first-run map/army passes in `Ascended-Visual-12.xcresult`. Initial failures exposed inherited SwiftUI accessibility identifiers on a parent hiding its GPS/name children; the parent identifiers were removed. Updated tests accommodate the removed counters, offscreen menu items and a fit-view pin beneath floating controls instead of tapping obscured/offscreen elements.

`tools/validate_visual_navigation.py` validates every map artifact asset, all five genuine base photos, all referenced game images, forbidden substitute imagery, absence of ellipsis, no interactive preparation controls, inline cave order and caption-only carousel. `tools/validate_visual_facts.py` passed real Swift alias/count/metric fixtures and original asset decoding. `git diff --check` passed. Existing 467 1080p loops and 467 posters are unchanged and present in the signed bundle.

Final signed build and `codesign --verify --deep --strict` passed. Cable installation, direct physical launch and fresh device inventory confirm **0.11.0 (12)**, bundle `com.tonytuanngoc.ascended`, physical iPad `8FA117DA-854A-5EEB-AEFC-EE54036237A9`. Receipt: `2026-10-04-ascended-visual-navigation-device.json`; installer/launch JSONs remain on the SSD with source hashes. Physical touch/animation QA is not claimed; interaction and screenshots are Simulator evidence.

## Sources and proof

- Per-image game provenance: `2026-10-04-game-portrait-sources.json`.
- Monument asset and marker meaning: `2026-10-04-map-obelisk-source.json`.
- Base evidence: each location's `photoSource` in `native/Ascended/Resources/ragnarok-bases.json`.
- Validation: `2026-10-04-visual-navigation-validation.json`.
- Reviewed screenshots: `2026-10-04-navigation-proof/`.
