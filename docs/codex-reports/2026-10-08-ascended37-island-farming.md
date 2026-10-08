# Ascended 0.36.0 (37) — The Island farming

## Delivered scope
The five supplied source topics now have at least five distinct reviewed farming regions: Metal 5, Obsidian 6, Oil 6, Organic Polymer 5, Cementing Paste 8. Added 26 clean local silent H.264 loops and matching photographs. Rare Flowers also reaches 5, and existing Silica Pearls remains 5. There are 43 verified Island catalogue regions, 42 visible under the curated resource selector. Other maps' catalogue entries are semantically unchanged.

Sources: https://www.youtube.com/watch?v=PwRVGX3yWYA (Metal), https://www.youtube.com/watch?v=iWJFZOZQ8TY (Obsidian), https://www.youtube.com/watch?v=_v__ROnbjv8 (Oil), https://www.youtube.com/watch?v=N5Qp_FNvIZI (Organic Polymer), https://www.youtube.com/watch?v=ThiYu0M6a_A (Paste); supplemental Obsidian https://www.youtube.com/watch?v=5aTpPyZRyZg. Source videos were reviewed through normal public playback under the user's existing permission for video excerpts.

## Evidence and presentation
Each new region has coordinate/terrain evidence and one natural-speed loop. New clips are 3.26–9.03 seconds; two supplemental Obsidian clips are shorter than the preferred six seconds because only clean continuous terrain footage was available. No fabricated repeats or stretched gameplay. Map/inventory overlays are excluded from the displayed loops. Source GPS and nearby terrain establish a farming search region, not a guarantee that a moving creature, harvested node, or beaver dam remains there on every server. Dam guides demonstrate search regions rather than item-transfer yields.

Browser buffering means some source clocks could not be recovered precisely. Those entries retain capture-relative timing and chapter hints or a plain source link, rather than inventing exact YouTube timestamps. Recoverable Polymer frames were cut before an interrupted browser recording; all delivered files passed full decoding. Original capture failures remain in the offline evidence.

Resource-specific selected-location cards recommend Beelzebufo for Swamp Cave paste and Megatherium/Beelzebufo for chitin, with cave preparation and tight-passage deployment notes. Metal locations recommend Anky/Argentavis; beaver dams distinguish transport mounts from hand looting. Optional metadata keeps older records compatible.

The Island now has an original generated landscape cover for the map picker and header. The geographical map image and coordinate calibration are unchanged. The cover is saved at native/Ascended/Assets.xcassets/MapLogo-the-island.imageset/image.png.

Corrected mushroom GPS to LAT 74.4 / LON 23.5 from the filmed source. Quarantined the mismatched historical cave Black Pearl pin and superseded a duplicate western Redwood paste region; neither contributes to active coverage. The valid western Black Pearl hunting region remains.

## Remaining coverage
This release completes the five supplied resource topics, not all fourteen categories. Below-five categories: Black Pearls 1, Chitin 2, Crystal 2, Giant Bee Honey 1, Rare Mushrooms 2, Rich Metal 1, Sap 0. These are source gaps, not claims that a resource is absent. No invented locations are shown to satisfy a count.

## Validation and delivery
13 native unit/UI cases passed, including map-specific resource switching, exactly one selected clip, location mount recommendations, other-map Farming regression, and Atlas selection/popup/pinch/reset regression. One packaging regression test passed. All 26 new movies passed codec, duration, hash, silent-track and full-decode checks; see ascended37/media-validation.json. git diff --check passed.

Built, installed and launched 0.36.0 (37), bundle com.tonytuanngoc.ascended, on Ascended iPad QA (20C9346D-B0E6-4239-8152-1D85ADD57BA6). Build-run log records PID 83638. Screenshots and manifest are in ascended37/screenshots. Simulator verification does not establish physical-iPad or live-server spawn proof. Standalone native Simulator deployment; no web domain or TestFlight deployment.
