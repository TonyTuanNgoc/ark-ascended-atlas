# Ascended 0.29.0 (30) — Atlas presentation and boss gallery

Scope: standalone Ascended native iPad app; Simulator-only delivery. No Tony OS, web hosting, physical iPad installation or TestFlight work.

## Changes
- Atlas heading includes map name plus Atlas. Find location appears above layer categories.
- Cave list rows and map pins share the same cave artwork. Genuine location photographs are reserved for the popup.
- Individual Obelisks use bright blue/red/green faceted marker artwork with consistent geometry.
- Map-scoped photo registry disambiguates repeated entrance IDs across maps. 32 genuine cave-photo assets are reused; provenance URLs and captions retained.
- Boss root is a viewport-fitted image gallery, deduplicated in existing recommended progression order. Details open in-place with Army, Tribute, Location and Combat segments.
- Army plans and difficulty-specific tribute use existing structured source-backed data. Summon terminals and approach entrances are explicitly distinguished from arena coordinates. Existing verified coordinates are unchanged.
- Nine source-based transparent boss cutouts plus two AI illustrated PNG portraits (Manticore, Rockwell). The two illustrated portraits are labeled inside detail UI; they are not extracted game models.

## Coverage and remaining gaps
This release applies the UI to every selectable map, but does not claim complete photo or tribute coverage. Some cave entrances, all individual Obelisk photographs, and multiple expansion boss portraits still lack usable verified imagery. Source downloads returned HTTP 403; no bypass was attempted. Missing photographs show an explicit placeholder; unverified army, tribute and coordinate data remain visibly unavailable. Exact boss difficulty ordering depends on chosen army/settings; gallery order is an existing suggested progression, not a measured universal strength ranking. The Center guardian pair is one shared arena encounter.

Existing source references: ARK community wiki and stored creator/source ledgers. Scorched screenshots identified at https://www.destructoid.com/all-artifact-locations-in-ark-ascended-scorched-earth/ ; individual Obelisk artwork identified at https://celiemma.artstation.com/projects/JwlOLm but direct originals could not be acquired. No location photograph was synthesized or replaced with another location.

## Verification and delivery
Final targeted checks: seven Atlas presentation/terrain unit checks and the boss-gallery/Atlas-photo UI flow. Additional regression: seven MapField unit checks plus personal-location persistence/map isolation and full-image Atlas layout. All completed runs passed. First UI attempt tapped map picker immediately after launch and failed to open its popover; the stable tested flow enters Story before opening the selector. This release does not claim to resolve that startup-tap timing issue.

Final screenshots are stored alongside the Simulator receipt in `ascended-0.29.0-30/`. Latest image/card/popup, correct boss pin portraits and square boss-map refinements passed final seven-unit/one-UI checks in Test-Ascended-2026.10.08_00-34-28-+0700.xcresult. Additional seven-unit/two-UI regression passed in Test-Ascended-2026.10.08_00-27-34-+0700.xcresult. Screenshots visually reviewed before delivery. No physical-device QA is claimed.

Installed bundle version/build confirmed 0.29.0/30; fresh Simulator launch PID 10264. Simulator foreground opened. No official web domain exists for this native-only deliverable.
