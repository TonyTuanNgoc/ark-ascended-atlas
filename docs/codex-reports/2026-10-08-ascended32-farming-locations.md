# Ascended 0.31.0 (32): additional filmed farming locations

Standalone native iPad app, delivered to Ascended iPad QA Simulator. No Tony OS change, physical-device install or TestFlight upload. This app has no official web domain.

## Delivered content

Added 16 distinct source-filmed farming regions, increasing bundled locations and single-location loops from 63 to 79:

- The Island: three Silica Pearl regions and three Rare Flower regions.
- Ragnarok: Black Pearls, Crystal, Metal, Oil, two Organic Polymer regions and Silica Pearls.
- Scorched Earth: southeastern Metal ridge.
- Lost Colony: northwestern Metal region.
- Astraeos: coastal Crystal terrace, with the original 2025 source revision retained in provenance.

Each new preview is a continuous 6–8-second silent H.264 loop, with one poster and a source link. No M-map or inventory obstruction is present in the sampled manual review. Full encoded video decoding passed. Coordinate evidence remains separate from the clean preview; waypoints describe filmed farming regions rather than guaranteed permanent individual resource nodes. No measured yield is inferred from an approach-only preview.

Farming retains its fourteen-resource horizontal strip and fixed map/location/harvesting columns. Selecting a location changes the sole visible preview and highlights its pin. Nearby locations are available through a counted pin's location menu. No duplicate clips at the same GPS were counted as separate farming places.

## Coverage remains incomplete

The all-map target is **not complete**. The audit covers 154 map/resource combinations across eleven map planes and fourteen resources. Thirteen combinations currently have at least three independently located bundled clips; 141 need more source evidence or an availability determination. Missing footage is not treated as proof that a resource is absent.

New public sources for Lost Colony (`c9eDoDDGZ5Q`), Aberration (`DDVATkHon0s`) and Scorched Earth (`4GieC-G-9Nw`) returned HTTP403 during normal authorized acquisition. Those denied sources were not retried. The successfully received opening fragment of the Scorched source supplied one complete clean preview. Earlier section acquisitions also failed; YouTube search API reports API_KEY_INVALID. No access restriction was bypassed.

Short 1–4.9-second candidates, map-only alternatives in Top 3 videos, duplicate waypoints and footage without specific resource authority were excluded. Astraeos's 2025 creator-labelled region has nearby Crystal nodes in the current local terrain dataset; this supports region consistency, not frame-level verification of every later map revision.

The durable per-map/resource matrix, accepted/rejected candidate ledgers, coordinate snapshots and sampled review sheets are in `tools/evidence/farming32/`. Original source media stays on the external media drive. Previous creature-spawn and cave-walkthrough gaps remain outside this Farming-only change.

## Verification and delivery

Media manifest, H.264/mute/duration/poster/hash checks passed for all 79 bundled Farming locations. Seven scoped map/GPS/farming unit checks and two existing Farming UI regressions passed. The new nearby-pin selection test initially failed because it did not choose the location from the cluster menu; the test was corrected to exercise the actual menu and passed on recheck. The assertions include selected-pin highlighting, exactly one visible matching clip, and isolation after switching to Ragnarok.

Installed Simulator receipt confirms 0.31.0 (32), 79 Farming locations/guides and a fresh launch. Three UI flows and seven unit tests passed; the corrected pin test result is Test-Ascended-2026.10.08_09-49-54-+0700.xcresult. Other scoped passes are in the 09-44-19 result. Screenshots were visually reviewed and saved beside simulator-receipt.json in ascended-0.31.0-32/. Source changes are committed and pushed on codex/ascended-ipad-dev-20261003. No full-target completion is claimed.
