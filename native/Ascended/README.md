# Ascended — native iPad development 0.5.0 (5)
Single Player · Ragnarok / The Island / The Center. Independent app `com.tonytuanngoc.ascended`, installed by cable without TestFlight.

## Included
- Ordered boss campaigns for all three maps; 27 army options across every named boss, with composition, level/breed/imprint/XP explanation, planning HP/melee/saddle targets, source confidence and patch caveats. Existing boss profiles remain accessible.
- Ragnarok-only Base Location: five SP-balanced choices, offline region terrain previews, timestamped YouTube links and actual per-video popularity snapshots. Per-location forum signals are explicitly qualified; ranking is an editorial balance assessment, not a public vote leaderboard. Five base pins link map focus back to profiles.
- Outer three-map picker; every sidebar section is scoped to the selected map. Returning to the picker clears the previous map’s detail navigation.
- New searchable **Thông tin map** guide: geography, resources, creatures, caves, bosses, progression, base planning, Single Player settings and dated sources.
- Island: 124 creature/variant entries (113 structured profiles), ten artifacts, eleven exploration routes including a labelled Tek Cave approach region; Broodmother, Megapithecus, Dragon and Overseer.
- Center: 132 creature/variant entries (123 structured profiles), eleven artifacts across nine routes; Broodmother and Megapithecus share the Center arena.
- Each map has an offline 8192×8192 terrain image and its own notes, artifact collection and gear checklist. Existing Ragnarok storage keys are preserved.
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
- Local autosaved notes and source links. Core content works offline; links require network.

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
