# Ascended — native iPad development 0.11.0 (12)
Single Player · Ragnarok / The Island / The Center. Independent app `com.tonytuanngoc.ascended`, installed by cable without TestFlight.

## Included
- Ordered boss campaigns for all three maps; 27 army options across every named boss, with composition, level/breed/imprint/XP explanation, planning HP/melee/saddle targets, source confidence and patch caveats. Existing boss profiles remain accessible.
- Ragnarok-only Base Location: five SP-balanced choices, offline in-game region photos, timestamped YouTube links and actual per-video popularity snapshots. Per-location forum signals are explicitly qualified; ranking is an editorial balance assessment, not a public vote leaderboard. Five base pins link map focus back to profiles.
- Persistent three-map selection in the left sidebar. Selecting a map opens its full map and clears previous detail navigation; Hôm nay is removed.
- New searchable **Thông tin map** guide: geography, resources, creatures, caves, bosses, progression, base planning, Single Player settings and dated sources.
- Island: 124 creature/variant entries (113 structured profiles), ten artifacts, eleven exploration routes including a labelled Tek Cave approach region; Broodmother, Megapithecus, Dragon and Overseer.
- Center: 132 creature/variant entries (123 structured profiles), eleven artifacts across nine routes; Broodmother and Megapithecus share the Center arena.
- Each map has an offline 8192×8192 terrain image and its own stored artifact collection and existing progress. Existing Ragnarok storage keys are preserved.
- Original ARK Survival Ascended logo and native SwiftUI navigation.
- Offline 8192×8192 terrain, pinch/pan, double-tap zoom, zoom buttons and fit/reset; portrait and landscape.
- 159 creature/variant entries: 151 entries in Wikily's Ragnarok spawn registry, supplemented by Xiphactinus and seven Alpha variants from the official community wiki. This is a source-based roster, not a measured count of a player's save. DLC creatures are labelled separately (12 entries).
- Current structured profiles for 140 entries: recorded taming method/food, base wild stats, drops and immobilization. Nineteen entries explicitly show that detailed information is pending. Variants are counted separately.
- 126 dated practical notes retained from the existing repo, labelled historical (20 April 2026), separate from current profile data.
- Boss catalogue: Nunatak main arena; Iceworm Queen, Lava Elemental, Spirit Dire Bear and Spirit Direwolf (four named mini-bosses across three dungeon encounters).
- Visual field guide: ten ASA artifacts across six cave/underwater routes; nine entrance/approach GPS points, three Obelisk terminals and an approximate Lava Elemental arena point. Map layers, selectable fixed-size markers, nearby-location chooser and direct focus from profiles.
- Nunatak Gamma/Beta/Alpha HP, entry levels, artifacts/apex tributes, Element, Tekgrams, arena rules and preparation; dungeon boss route/mechanics/gear notes with source-dependent values identified.
- 23 additional offline images: ten artifact icons, three Nunatak renders, four mini-boss icons and six attributed Ragnarok illustrations. Cave illustrations are not exact entrance photographs.
- Persistent artifact collection and preparation checklists.
- Core content and local 1080p looping walkthroughs work offline; full-video links require network. Notes/source navigation is removed; existing stored values are preserved.

## Build and install
Requires Xcode, xcodegen, a paired/unlocked iPad with Developer Mode and authorized signing team HP5W6N9V3N.

```sh
xcodegen generate --spec native/Ascended/project.yml
xcodebuild -project native/Ascended/Ascended.xcodeproj -scheme Ascended -configuration Debug -destination 'generic/platform=iOS' -derivedDataPath /Users/admin/Ascended-Build-Device -allowProvisioningUpdates -allowProvisioningDeviceRegistration build
xcrun devicectl device install app --device 'iPad (3)' /Users/admin/Ascended-Build-Device/Build/Products/Debug-iphoneos/Ascended.app
xcrun devicectl device process launch --device 'iPad (3)' com.tonytuanngoc.ascended
```

Native source and docs are excluded from Firebase Hosting. Notes use `ascended.ragnarok.notes.v1`; artifact collection uses `ascended.artifacts.collected.v1`, preparation uses `ascended.guide.checklist.v1`; updating preserves them, deleting the app removes them. No Tony OS synchronization.

## Sources and assets
Reviewed 3 October 2026; source URLs and update notes are included in the catalogue.
- Original logo: https://r2.wikily.gg/images/brand/asa-logo.webp (Studio Wildcard artwork, fitted to an opaque app icon without redrawing).
- Terrain: https://r2.wikily.gg/images/ark/maps/ragnarok_tiles/5/{x}/{y}.png — 1,024 tiles at 256×256, assembled into source-native 8K. Zoom 6 returned 404; zoom 5 is the highest source level verified. Artifact, cave entrance/approach and boss portal overlays added; no resource or creature spawn overlays.
- Current spawn registry and structured profiles: https://wikily.gg/ark-survival-ascended/maps/ragnarok/ and its creature profile pages.
- Offline creature icons from the linked Wikily profiles: 152 of 159 entries have artwork; seven use a fallback symbol.
- Official community wiki: https://ark.wiki.gg/wiki/Ragnarok , https://ark.wiki.gg/wiki/Nunatak and linked species/dungeon pages.
- Launch: https://survivetheark.com/index.php?/forums/topic/772489-ragnarok-ascended-and-lost-colony-expansion-pass-are-now-live/
- Latest additions: https://survivetheark.com/index.php?/forums/topic/774248-therizino-tlc-cerberax-and-gargantar-are-out-now/ (30 September 2026; Cerberax, Gargantar and Ragnarok Cryolophosaurus spawns).

Personal companion, not an official Studio Wildcard product. Full progression planning, base design and calculators remain subsequent steps.

Field-guide source manifest: `Resources/field-guide-image-sources.json`. Artifact coordinates use Wikily's ASA spawn layer; entrances use the June 2025 Ascended guide at https://thegameslayer.com/guides/all-ragnarok-artifact-locations-ark-ragnarok-ascended/ . Boss statistics/tributes/rewards cite the Ascended tables on the community wiki. These are dated source records, not measurements of a Single Player save.

## Multi-map source limits
Island/Center ASA creature registries, artifact positions and terrain come from their linked Wikily map pages. Cave entrances are cross-checked against ASA community guides, separate from cave-region coordinates. Tek Cave’s marker is a region centre, explicitly not a verified doorway. Exact Island Obelisk GPS pins are omitted because the ASA layer did not supply them. The Center Gamma Element total conflicts between wiki tables; the app displays that conflict rather than a definite value. Creature variants count separately; 11 Island and nine Center roster entries await structured profiles. Cave terrain illustrations are not entrance photographs. See `Resources/multi-map-image-sources.json` and the 0.4 report for provenance.

Boss/base source snapshot and detailed verification: `../../docs/codex-reports/2026-10-04-ascended-boss-base.md`. Dino targets are planning recommendations, not tested minimums. Deinosuchus boss bleed was removed; Tek Cave 20-tame teleport batches are distinct from the 50-tame cave and multiple pre-boss teleport batches.

### 0.5.1 (6) avatar contrast
Dino and icon-based Boss portraits share explicit white template rendering across cards, detail pages, campaign steps and army options. Original transparent assets and attribution are retained; map/photo assets keep their original colours.

### 0.6.0 (7) compact guide
Square Base/Hang cards, compact corners, icon actions and player-focused copy. Notes and research/source UI are removed; internal provenance and stored progress remain. All 26 cave routes have 119 online YouTube chapter links via native Safari presentation. This release does not contain GIF walkthroughs: media reuse confirmation and actual route-footage verification remain pending.

### 0.7.0 (8) offline cave GIFs
467 local GIFs across all 25 artifact-bearing routes: Ragnarok 189 / six routes, The Island 148 / ten routes, The Center 130 / nine routes. Play/pause one clip at a time; moving away releases playback. Short player-style Vietnamese directions identify landmarks, interactions and requirements below useful steps. Full-video chapters are collapsible above GIFs. Tek Cave retains full-video guidance because it has no Artifact.

The Snow GIF option requires unlocked Tek gear/Element; the full Yutyrannus video remains available. Frozen Dungeon Pack placement is a labelled Creative demonstration after the survival Queen route; Pyromane usage needs its paid DLC. These are reviewed video routes, not a survival completion test on Tony's save. Originals are retained outside Git; 512×288 GIFs occupy 2.46 GB and can be re-rendered from source. Tools, source hashes, time ranges and verification live under `tools/` and `docs/codex-reports/`; attribution remains outside player-facing UI.

### 0.8.0 (9) autoplay carousel
The selected cave GIF loops automatically. Swipe the large image left/right, use previous/next arrows, or tap an ordered square card in the horizontal library below. The selected card is highlighted; the counter shows position within the current section. Multi-branch caves have an explicit section picker and reset to the first step on section change. Relevant phase directions remain beneath continuation clips. A poster stays visible while the new GIF loads; no Play tap is needed. One active local GIF is released on map/view exit or inactive scene. The 467 media files and map-scoped progress are preserved.

### 0.9.0 (10) session dashboard and waypoint pilot
Selecting a map opens Hôm nay: choose a persistent map-scoped cave target, open its actual entrance map, use the same existing gear checklist, and jump to base layouts or boss campaigns. Ragnarok Jungle Hunter has a nine-landmark schematic linked to the existing reviewed GIFs. Viewing clips never advances confirmed location; explicit confirmation persists independently. Fall recovery is optional and excluded from the main sequence. Exit mode reverses landmark order, with outbound footage explicitly identified. Landscape pairs the schematic and GIF; a fixed confirmation button stays accessible. This is not surveyed cave geometry, live game telemetry, or a walkable 3D scene. The clarified walkable 3D requirement remains pending actual geometry acquisition; see the 3D design report.

### 0.10.0 (11) visual information and source-quality loops
Map selection stays on the left, with a map-first landing and no Hôm nay. Maps cover the viewport with pan/zoom, floating controls and softer edges. GPS uses latitude/longitude axis icons. Cave images sit beside visual hazard/creature information on wide layouts; redundant artifact headers are removed.

162 genuine item images support preparation, foods, drops, tools, tribute and rewards; explicit numbers appear with their images. Boss team alternatives are separate. Unspecified preparation quantities are user editable and persist separately for each map and route; they are not invented minimums. Directional captions remain beneath clips, while secondary prose uses a detail button. Unknown imagery uses labelled generic symbols.

All 467 reviewed clips are replaced by silent 1920×1080 HEVC loops at source cadence up to 60 fps, with 1080p posters and AVPlayerLooper autoplay. No upscaling beyond the source; no lossless or 4K claim. Only the selected active clip has a player, neighboring pages retain posters and small library cards use downsampled thumbnails. Source/render hashes, route correspondence and decoded-media verification remain in internal reports. Cable build 11, no TestFlight or hosting release. See `../../docs/codex-reports/2026-10-04-ascended-visual-hq.md` for final validation/deployment evidence.


### 0.11.0 (12) direct visual cave guide
Cave pages show artifact artwork/name/GPS and entrance GPS, a flat pictured equipment list, then the autoplay HD loop and thumbnail strip. Preparation has no checkboxes, quantity controls or amounts. Artifact rows no longer open an extra page; existing collection progress remains accessible from boss tribute profiles. Hunter navigation uses the same carousel instead of numbered landmarks, a schematic, checkpoint confirmation and multiple pages. GIF headings, step numbers, previous/next buttons and thumbnail titles are removed; route instructions remain below the active loop. Alternative artifact branches retain a compact branch selector so contradictory paths are never merged.

All ellipsis detail buttons are removed. Map points have fixed GPS anchors, actual artwork and names; tapping shows a floating information card without shrinking the map. Obelisks use the game's monument silhouette coloured by terminal; coordinates refer to terminals, not a boss wandering on the map. Lava indicators are orange. 162 creature/boss gallery/frame assets retain their actual colours, including the Spirit encounters. Thirteen entries lack a verified game photo and show an empty-photo state rather than the wrong species or a head avatar. Images from the community wiki can come from either game edition; edition-unconfirmed images are recorded internally and are not claimed as ASA captures.

All five base previews use game photos. Three 1280×720 photos show the specified region; two verified chapter storyboards are 320×180 because full video downloads returned HTTP 403. Camera coordinates can differ from approach pins. No artificial upscale, generated place images or map-crop fallback. Sources and limitations: `../../docs/codex-reports/2026-10-04-game-portrait-sources.json`, each base's `photoSource`, and the 0.11 report. Existing 467 source-native 1080p loops are preserved. No TestFlight or web deployment.
