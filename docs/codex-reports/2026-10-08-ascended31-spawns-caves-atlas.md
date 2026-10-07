# Ascended 0.30.0 (31): creature spawns, caves and horizontal Atlas

Standalone native Ascended iPad app; Simulator delivery only. No Tony OS changes, physical-device install or TestFlight upload. There is no official website domain for this native-only deployment.

## Changes
- Creature details keep one large creature heading. Original native vector artwork replaces font-symbol icons in profile panels and diet/taming/stat facts.
- Every creature detail has the selected map's spawn terrain. 1,449 of 1,471 map/creature records contain source-backed spawn regions across all eleven selectable maps. Remaining 22 records explicitly show unavailable verified coordinates rather than invented regions (21 Alpha supplements and Ragnarok Xiphactinus).
- Spawn regions use Wikily's map-specific coordinate plane and supported bulk creature endpoint. Genesis land and Ocean use different source map IDs. Surface/cave colors and tap-to-read GPS ranges distinguish regions from exact creature sightings. Pinch, drag and expanded view are supported.
- The dataset preserves original source bounds for 1,856 rectangles partially outside the 0–100 viewport and renders only their intersection. 244 wholly outside rectangles are excluded. Source URL, SHA256 and explicit map/creature identity remain bundled.
- Cave cards use authentic entrance/interior photographs or existing attributed walkthrough frames, full artifact names and artifact artwork. The Island's eleven routes fit one landscape viewport. Duplicate body title, root search and explanatory paragraphs were removed.
- Cave details have one large heading, compact aligned artifact GPS, full-aspect pinned route map and no repeated exterior coordinate row. Nearby entrance/artifact pins form a counted cluster until zoom separates them.
- Cave clips advance through each route's ordered sections; tapping pauses/resumes. Farming retains its looping media behavior.
- Farming removes role descriptions, filmed-area captions and approach directions; Locations/Harvesting/Creatures/Tools use original vector headers.
- Atlas categories form one horizontal strip with independent all-category toggles and a selected-category child list. Removed +/-/reset buttons and hold instruction. Pinch and long-press Add Location remain; double-tap restores the default full-map fit and closes selection.

## Media coverage and remaining work
All 467 existing MP4 clips and corresponding posters exist across 25 routes and 32 sections on Ragnarok, The Island and The Center. This release audits and reuses them; it does not claim 467 newly acquired clips. Ten route recipes have no omissions within a section; fifteen contain omitted intervals. Mounted, flying, swimming and Creative footage also remain. These are **not** complete uninterrupted walking-only entrance-to-artifact routes.

A new Jonna-X Life's Labyrinth source (`IqSiyoFUtn8`, 2,101 seconds) was identified, but normal section acquisition failed with ffmpeg exit code 8. No bypass was attempted. Expansion routes without verified photographs explicitly show Photo pending. All-map uninterrupted cave video acquisition and the 22 missing spawn records remain outstanding.

Raw spawn source cache: `/Volumes/TONY SSD/ASCENDED_MEDIA/creature-spawns31`. Bundled media audit: `native/Ascended/Resources/caves31-media-audit.json`. Selected screenshot evidence and final installed-bundle receipt are in `ascended-0.30.0-31/`.

## Verification and delivery
Thirteen scoped unit checks passed: four creature/map spawn checks, two terrain-rendering checks and seven GPS/personal-location/farming regression checks. Three UI flows passed: horizontal Atlas categories/pin selection/double-tap reset/Argentavis spawn expansion; compact Farming labels; and cave cards/detail map/tap pause-resume/automatic clip advance. Final Cave run after coordinate alignment passed in Test-Ascended-2026.10.08_01-17-08-+0700.xcresult. Other successful scoped cases are recorded in 01-13-07 and 01-06-14 results. Screenshots were visually reviewed.

Simulator installed version/build and fresh launch are recorded in the adjacent simulator-receipt.json. No physical-device QA is claimed. Source changes are committed and pushed on codex/ascended-ipad-dev-20261003; native Simulator deployment is the delivery target.
