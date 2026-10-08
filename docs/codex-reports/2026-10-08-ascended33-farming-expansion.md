# Ascended 0.32.0 (33): 25 additional filmed farming regions

Delivered to the standalone Ascended iPad QA Simulator. The app has no official web domain. No Tony OS, physical iPad or TestFlight deployment.

## Content

Added 25 distinct regions with source-linked, silent H.264 previews, bringing the bundled library from 79 to 104 spots/guides. 94 distinct spots match the fourteen resources displayed in Farming; ten legacy spots concern other resources and remain outside that horizontal selection.

| Map plane | New regions | Resources |
|---|---:|---|
| Genesis Ocean |7| Silica Pearls ×3, Metal, Oil ×2, Chitin |
| Genesis land |3| Crystal, Obsidian, Organic Polymer |
| Scorched Earth |3| Obsidian, Silica Pearls, Oil |
| Lost Colony |6| Oil, Black Pearls ×2, Obsidian, Giant Bee Honey, Crystal |
| Aberration |2| Organic Polymer, Black Pearls |
| Valguero |1| Metal |
| Astraeos |2| Silica Pearls |
| Extinction |1| Crystal |

Each new clip is a continuous 6–8-second filmed approach or harvest. Full encoded decoding passed; source coordinate snapshots and chronological sampled contact sheets were visually reviewed. No M-map or inventory obstruction appears in these clean previews. Coordinate evidence can come from a separate frame. Creator-labelled farming regions, underwater GPS and filmed camera regions retain their different provenance; no region is represented as a guaranteed permanent individual node or guaranteed yield. Genesis Ocean coordinates are scoped separately from the land plane. Canonical resource names were corrected before delivery so new Silica Pearls and Organic Polymer points appear in the actual resource filters.

The Lost Colony citylamp Crystal preview includes a visible +86 Crystal pickup; the displayed farming-region coordinate describes the filmed camera position. The character marker elsewhere is not substituted for that filmed location. Other approach-only previews do not acquire a measured-yield claim.

## Remaining scope

The full-map request remains **incomplete**. The audit covers 154 combinations of 11 map planes and 14 curated resources. 14 combinations have at least 3 bundled distinct filmed regions; 140 still need additional source footage or an applicability determination. The raw matrix is a sourcing backlog, not proof that every resource exists on every map. Missing evidence is not recorded as resource absence. Seven legacy previews are shorter than 6 seconds; most concern resources outside the curated strip, and upgrading applicable legacy clips remains separate unfinished media work.

Newly selected sources often returned HTTP403 during ordinary licensed acquisition. Complete usable clips were cut only from already received approved media; denied sources were not retried and access restrictions were not bypassed. Public metadata search provided alternate new sources after the search API reported API_KEY_INVALID. Sources lacking coordinate proof, scenes shorter than 6 seconds, duplicate regions and cursor coordinates that disagreed with player position were excluded. Sampled review and complete decoding establish clip integrity, not continuous live verification of resource respawns or every later map revision.

Accepted/rejected source ledgers, GPS snapshots, contact sheets and the coverage matrix are in `tools/evidence/farming33/`. Original source media and redundant research frames remain on the external media drive. Raw signed media URLs are excluded from repository evidence.

## Validation and delivery

Final 104-clip manifest/hash/H.264/mute/duration/poster audit passed. All 25 new clips fully decoded. Final Simulator run passed 7 scoped map/resource unit tests and 4 UI flows: fixed Farming columns, compact harvesting names, changing selected Island pearl pins with exactly one matching preview, and Genesis Ocean/land resource-pin isolation. Ocean Silica Pearls shows 3 selectable regions; land Organic Polymer shows its own single region. QA screenshots were visually inspected.

An earlier provisional run detected two clips added after project generation and an incorrect test assumption that selecting a different map retained the Farming section. The project was regenerated after all content was frozen, and the test now enters Farming after each map selection. Final tests pass; no unrelated app UI change was introduced.

Installed Simulator bundle confirms 0.32.0 (33), and installed resource manifests exactly match the 104-spot/104-guide repository manifests. A fresh launch succeeded and Simulator was opened. Screenshots and delivery receipt are in `docs/codex-reports/ascended-0.32.0-33/`.
