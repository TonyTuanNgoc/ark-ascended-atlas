# Ascended — native iPad development 0.2.0 (2)
Single Player · Ragnarok. Independent app `com.tonytuanngoc.ascended`, installed by cable without TestFlight.

## Included
- Original ARK Survival Ascended logo and native SwiftUI navigation.
- Offline 8192×8192 terrain, pinch/pan, double-tap zoom, zoom buttons and fit/reset; portrait and landscape.
- 159 creature/variant entries: 151 entries in Wikily's Ragnarok spawn registry, supplemented by Xiphactinus and seven Alpha variants from the official community wiki. This is a source-based roster, not a measured count of a player's save. DLC creatures are labelled separately (12 entries).
- Current structured profiles for 140 entries: recorded taming method/food, base wild stats, drops and immobilization. Nineteen entries explicitly show that detailed information is pending. Variants are counted separately.
- 126 dated practical notes retained from the existing repo, labelled historical (20 April 2026), separate from current profile data.
- Boss catalogue: Nunatak main arena; Iceworm Queen, Lava Elemental, Spirit Dire Bear and Spirit Direwolf (four named mini-bosses across three dungeon encounters).
- Local autosaved notes and source links. Core content works offline; links require network.

## Build and install
Requires Xcode, xcodegen, a paired/unlocked iPad with Developer Mode and authorized signing team HP5W6N9V3N.

```sh
xcodegen generate --spec native/Ascended/project.yml
xcodebuild -project native/Ascended/Ascended.xcodeproj -scheme Ascended -configuration Debug -destination 'generic/platform=iOS' -derivedDataPath /Users/admin/Ascended-Build-Device -allowProvisioningUpdates -allowProvisioningDeviceRegistration build
xcrun devicectl device install app --device 'iPad (3)' /Users/admin/Ascended-Build-Device/Build/Products/Debug-iphoneos/Ascended.app
xcrun devicectl device process launch --device 'iPad (3)' com.tonytuanngoc.ascended
```

Native source and docs are excluded from Firebase Hosting. Notes use `ascended.ragnarok.notes.v1`; updating preserves them, deleting the app removes them. No Tony OS synchronization.

## Sources and assets
Reviewed 3 October 2026; source URLs and update notes are included in the catalogue.
- Original logo: https://r2.wikily.gg/images/brand/asa-logo.webp (Studio Wildcard artwork, fitted to an opaque app icon without redrawing).
- Terrain: https://r2.wikily.gg/images/ark/maps/ragnarok_tiles/5/{x}/{y}.png — 1,024 tiles at 256×256, assembled into source-native 8K. Zoom 6 returned 404; zoom 5 is the highest source level verified. No resource/spawn overlays or coordinates yet.
- Current spawn registry and structured profiles: https://wikily.gg/ark-survival-ascended/maps/ragnarok/ and its creature profile pages.
- Offline creature icons from the linked Wikily profiles: 152 of 159 entries have artwork; seven use a fallback symbol.
- Official community wiki: https://ark.wiki.gg/wiki/Ragnarok , https://ark.wiki.gg/wiki/Nunatak and linked species/dungeon pages.
- Launch: https://survivetheark.com/index.php?/forums/topic/772489-ragnarok-ascended-and-lost-colony-expansion-pass-are-now-live/
- Latest additions: https://survivetheark.com/index.php?/forums/topic/774248-therizino-tlc-cerberax-and-gargantar-are-out-now/ (30 September 2026; Cerberax, Gargantar and Ragnarok Cryolophosaurus spawns).

Personal companion, not an official Studio Wildcard product. Full progression planning, base design and calculators remain subsequent steps.
