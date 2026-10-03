# Ascended 0.4.0 (4) — isolated map guides

## Delivered behavior
The standalone native iPad app opens with Ragnarok, The Island and The Center selection. The active map owns every sidebar page: searchable information, terrain, creatures, bosses, artifacts/caves, notes and sources. Changing map destroys the old detail navigation. Notes, artifact collection and preparation checklists use independent storage namespaces; existing Ragnarok keys remain intact. No Tony OS, TestFlight or ARK website changes.

## Content and visual assets
| Map | Creature/variant roster | Structured profiles | Artifacts | Exploration routes | Named bosses |
|---|---:|---:|---:|---:|---:|
| Ragnarok | 159 | 140 | 10 | 6 | 5 |
| The Island | 124 | 113 | 10 | 11 | 4 |
| The Center | 132 | 123 | 11 | 9 | 2, one shared arena |

Each map information guide covers identity, geography, resources, creatures, caves, bosses, suggested phases, base planning and Single Player considerations. New maps each bundle source-native 8192×8192 terrain assembled from 1,024 zoom-5 tiles; zoom 6 returned 404. Added four boss icons, Brute artifact artwork and six creature/variant illustrations; shared existing creature/artifact artwork is reused. `multi-map-image-sources.json` records provenance. Core guides/maps work offline; external sources need a connection.

## Research and limits
Snapshot reviewed 3 October 2026. Sources: [Island ASA registry](https://wikily.gg/ark-survival-ascended/maps/the-island/), [Center ASA registry](https://wikily.gg/ark-survival-ascended/maps/the-center/), their ASA artifact/cave/obelisk API layers (map IDs 22/21), [Island entrances](https://www.gamenguides.com/where-to-find-all-island-cave-entrances-in-ark-survival-ascended), [Center entrances](https://primagames.com/gaming/all-cave-locations-in-the-center-in-ark-survival-ascended), and linked [ARK community wiki](https://ark.wiki.gg/wiki/The_Island) species/boss tables.

Seven Alpha variants supplement each new map’s source registry. Variants count separately. Eleven Island and nine Center records explicitly lack detailed profiles. Map node counts are a source snapshot, not live save yields. Terrain illustrations do not claim to show exact cave doors. ASA artifact positions are separate from doorway GPS. The Tek Cave marker is an explicitly labelled approximate region centre, not a verified entrance; Island Obelisk pins are omitted because its ASA layer was empty. Center’s Gamma Element tables disagree (72 versus 92); the app explains the conflict. Center guide’s floating-island table mixed in an Underworld coordinate; that coordinate is assigned to Underworld, not duplicated as a floating-island entrance. Source-derived strategy/checklists are suggestions, not tested damage simulations or complete calculators.

## Review and verification
Fresh review by existing ascended_review agent found three P2 scope issues: generic creature fallback wording, Island-only source warning shown on other maps and a Nunatak-specific Obelisk label on Center. All corrected. UI QA also exposed inconsistent boss-to-artifact navigation; all guide links now share typed map-scoped destinations. Whole cave cards have a hit shape so tapping their images opens the route.

Four UI tests passed with zero failures (148.870 seconds), receipt `/Users/admin/Ascended-QA-04-3.xcresult`: Ragnarok creature details, cave/artifact/map layers and boss difficulty, Ragnarok notes persistence, and three-map selection/isolation/deep-navigation reset/persistent collection after process restart. Data audit confirmed artifact→route and route→artifact references for all three maps. Exported picker and Center focused-map screenshots inspected visually at `/Users/admin/Ascended-QA04-3-Screenshots`; no missing terrain/artwork observed. `git diff --check` passed.

Signed Debug device build succeeded. Development 0.4.0 (bundle build 4), `com.tonytuanngoc.ascended`, installed and launched on the physical A16 iPad (CoreDevice `8FA117DA-854A-5EEB-AEFC-EE54036237A9`). Device app inventory independently confirms version 0.4.0 and bundleVersion 4. Device installation/launch proves deployment; the automated functional/visual checks above were on Simulator, not physical touch interaction.

Delivery branch: `codex/ascended-ipad-dev-20261003` in `https://github.com/TonyTuanNgoc/ark-ascended-atlas`. Deployment target is the native iPad app. No new website/domain was created; existing configured `https://ark-ascended-atlas.web.app` remains outside this native-only change and was not presented as a live 0.4 web deployment.

Final receipt: implementation commit `596642e` was pushed and remote SHA verified. A final reinstall after adding the image-provenance manifest succeeded at 23:41; automatic launch on that reinstall was blocked because the iPad had auto-locked. The earlier 23:37 installation/launch of the same 0.4 functional code succeeded. Open Ascended after unlocking the iPad to use the final installed copy. No physical touch QA is claimed.
