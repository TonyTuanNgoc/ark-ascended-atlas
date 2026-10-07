# Ascended0.23.0(24) — one-row navigation, clean resource footage and map detail

Standalone native Ascended. Baseline28020ad, correct branchcodex/ascended-ipad-dev-20261003, origin fetched before edits. User authorized direct implementation and continued source-video use. No TonyOS, TestFlight, new web domain or physical-device installation in this Simulator review.

## Navigation and resource UI

One86pt header contains the existingARKlogo, combined current-map artwork/name dropdown and9horizontal modules: ASAStory, Equipment, Farming, FieldGuide, BaseBuilding, Atlas, Creatures, Bosses, Artifacts&Caves. FieldGuide holds contextual map information; Atlas is the interactive map. All controls fit landscape iPad11; narrower displays scroll the module portion. Existing selected-map persistence and module IDs remain stable. The redundant standaloneMaps control/current-map card pair is removed.

Resource preview, three thumbnail selectors and their selection outlines use consistent rectangular rounded corners and plain button styling. The borderless buttons remove the system capsule wrapping rectangular photos. Source-video links remain attached to the selected timestamp. LAT/LON replace arrow-only coordinate labels in the sharedGPSbadge and personal-location editor; numeric meaning, map bounds and save keys are unchanged. Parser preserves signed coordinates when present.

## Map source and renderer

Eight DLC coordinate planes now contain source-native8192×8192 Wikily tile canvases (8,192 validated tiles total), with no upsample, rotation, crop or change to atlas bounds. Island/Center were already8192. Strong genuine detail gains are observed on ScorchedEarth, Aberration, Extinction and Genesis; some other map sources remain coarse. Ragnarok remains the better existing2048 ASA Wiki raster: alternate sources checked did not contain additional terrain detail. See map-quality24 research, source hashes and same-region comparison.

A CATiledLayer-backed terrain view draws source-image crops at the current zoom; marker/long-press coordinates remain in the same UIImage.size image-local plane. Zoom range increases from8× to32× relative to fit, with at least1:1 image-point access. Magnification does not create terrain information. Tiled drawing bounds visible layer textures; it does not promise that UIImage decoding avoids full source memory. Device memory/performance is not verified by this Simulator task.

## Evidence and verification

Resource video audit and final native test/deployment evidence are recorded below. No complete-game, game-GPS calibration or physical-performance claim is made.

## Resource media and source review

Re-cut all54 filmed-region guides:162 muted H.2641080p/24fps offline loops,162 posters and54 spot stills. Replaced coordinate-map scenes with source intervals after the map closes; first three Ragnarok examples retain their original region/source. Rectangular selector titles now describe the footage honestly. Only six guides contain observed harvesting; regional views, approach, combat or inventory are labeled accordingly rather than called harvesting.

All162 clips fully decode; file hashes, durations and posters/stills pass the media validator. Visual review covered1,572 source frames at4fps plus324 encoded clip-boundary frames. No M-map overlay was observed in those selected samples; this is not exhaustive every-frame certification. Some clean clips are0.75–1.5s. Nine licensed source caches remain partial afterHTTP403, affecting ten guides, but selected intervals are fully decodable. Public metadata inspection succeeded for all23 distinct source videos; timestamp/source URLs remain available.

The builder preserves the complete resource catalogue, including454 acquisition/availability rows and coverageScope. Added per-map coverage regression check. Corrected Farming card accessibility grouping so individual filmstrip buttons and video links retain their IDs.

Game coordinate labels were checked against actualASA footage showing Latitude/Longitude. The research-only map frame is in ascended-0.23.0-24/ASA-coordinate-label-reference.jpg; shipping resource loops exclude it. Shared UI uses compact LAT/LON labels.

## Final native QA and deployment

Fresh final app passed18 unit cases and14/15 scoped UI cases in Test-Ascended-2026.10.07_17-21-01-+0700.xcresult. The remaining personal-location case encountered an offscreen expanded filter row; the test now scrolls that rail before tapping, and the isolated case passed in Test-Ascended-2026.10.07_17-26-59-+0700.xcresult. Final unique coverage:18unit+15UI, no skipped cases. App source/resource bytes did not change between those runs; the rerun changed only test scrolling. Earlier Farming accessibility-ID propagation and deep-zoom test rail visibility were fixed and the three new build24 cases all passed.

Reviewed actual Farming, one-row navigation and deep-zoom screenshots exported to ascended-0.23.0-24. Version0.23.0/build24 installed and read back from the Ascended iPad QA Simulator; launch succeeded. This is Simulator delivery, not physical-device performance/touch proof. The physical iPad remains separately delivered0.21.0/build22. No TestFlight, TonyOS, web deployment or official domain exists for this standalone native task. Commit/push record is the repository history for this report.
