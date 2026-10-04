# Ascended 0.14.0 (15): story, base planning and equipment library

Standalone native iPad companion. Baseline 91cf7418f4a0ffa870a07ac9b5987dfaad0f14b7 on codex/ascended-ipad-dev-20261003, origin fetched before edits. No Tony OS changes, TestFlight or web hosting deployment.

## Delivered

- Twenty-six Vietnamese story sections: five introductory sections, twelve chapters and nine character/concept sections. Original ARK narrative through Genesis Part 2, ARK origin and survival/progression purpose, Lost Colony context and exploration-map distinction. Full-story spoilers remain behind a closed group. Narrative chronology and suggested ASA play order are distinct; Lost Colony is not presented as a simple chronological chapter between Extinction and Genesis. Catalog/story sidebar order updated accordingly.
- Genuine inline map badges for every playable map and most upcoming entries, on the sidebar, map catalog, story chapter and map information. Fifteen map badges plus an Ocean alias; originals retain their source dimensions. Atlantis source art does not exist and Santiago retrieval was unavailable; these use the existing ARK artwork fallback. No invented map logos.
- Map lists, map/DLC catalog groups and detailed map information sections default closed. Selected map remains visible in the sidebar. Existing original-three map-scoped data/progress and photographic farming guides preserved.
- Five recommended base phases and nine functional zones: main house, storage/unloading, industry, garden/greenhouse, kitchen/cold storage, electricity/water, Dino yard/taming, breeding and expedition outposts. Each zone has purpose, placement, approximate size, equipment, work flow and practical steps. A clickable nine-zone arrangement opens and scrolls to its matching zone. Sizes and arrangement are suggestions, not measured building footprints. Applies to all maps; the five photographed Ragnarok base locations remain accessible under a closed group.
- Seven hundred thirty-two library entries: 78 resources, 184 tools/equipment, 79 machines/utilities, 299 building structures and 92 consumables/food. Five closed groups, searchable pictured cards and item details. All forty-four distinct equipment names referenced by the base plan resolve to the library and have real game artwork.
- Fifty genuine new equipment PNGs plus existing exact assets; 208 unique library artwork references. Forty-four base-kit items are pictured. The other catalog items retain a symbol when artwork is unavailable; no claim that all 732 items have artwork.
- Availability evidence: 407 published core engram matches, 33 core raw-resource matches, 18 existing map-resource matches and one ASA DLC entry; 87 entries retain existing individual item-source evidence and 186 remain explicitly unconfirmed for ASA. Broad source tables contain both editions; this library is a reference catalog, not proof every entry is obtainable in the current save. No invented quantities, recipes or unlock levels. Common machine/water/electricity and baby-feeding guidance has individual ASA checks.

## Verification

Companion validator passes: unique IDs, text/schema, story-to-map references, 732 items, every category and image reference, PNG integrity, all base equipment links, nine zones/five phases and every playable-map badge. Existing expansion/farm and visual-fact validators pass. Final source manifests and assets are frozen.

Three scoped Simulator scenarios passed together:
- collapsed sidebar/map catalog and map selection;
- resource photo/GPS/video popups and zoom on Ragnarok, The Island and The Center;
- closed story sections, base equipment, interactive base arrangement and searchable machine detail.

Result: /Volumes/TONY SSD/ASCENDED_MEDIA/builds/Ascended-0.14.0-Simulator/Logs/Test/Test-Ascended-2026.10.04_20-42-31-+0700.xcresult.

A final compact item-detail wording change was checked again in the story/base/library scenario. One infrastructure attempt failed before app launch due insufficient Mac storage, not a UI assertion. Old generated Ascended build directories were moved to SSD with path-preserving symlinks, and the disposable Ascended QA Simulator app was reset; physical iPad data was preserved. Retry passed: /Volumes/TONY SSD/ASCENDED_MEDIA/builds/Ascended-0.14.0-Simulator/Logs/Test/Test-Ascended-2026.10.04_20-49-38-+0700.xcresult. The full bundle, including existing cave movies, was used; no QA-only media stripping.

Signed final device build and strict codesign verification succeeded. Cable install succeeded; bundle inventory and launch receipts are in knowledge-device-install.json, knowledge-device-apps.json and knowledge-device-launch.json. Physical bundle inventory confirms 0.14.0 (15). Automatic physical launch was denied because the iPad remained locked. Physical touch QA is not claimed from Simulator results.

## Accountability and limits

Story and map badge evidence: story-sources.json and map-badge-sources.json. Catalog acquisition and exact image hashes: equipment-sources.json. Base layouts are authored single-player recommendations grounded in the verified machine mechanics; they are not official game blueprints. Catalog sizes are counted independently from data. Per-item unconfirmed availability is surfaced compactly, while technical source details remain in reports.

Earlier new-map creature detail/cave video gaps remain unchanged. This release does not complete those separate content collections. Official repository: https://github.com/TonyTuanNgoc/ark-ascended-atlas . Native cable installation has no web domain.
