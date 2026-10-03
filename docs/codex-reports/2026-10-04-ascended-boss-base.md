# Ascended 0.5.0 (5) — boss campaigns and Ragnarok bases

## Delivered scope
The Boss sidebar now opens an ordered map-specific campaign, retaining all existing tribute, artifact and boss profile links. Every named boss has a dedicated army planner: 27 options across 11 named boss records (five Ragnarok, four Island, two Center). Options identify composition, role, post-imprint/post-XP HP/melee/saddle goals, support, execution risks, source links and evidence limits. Shared preparation distinguishes survivor entry level from tame/breed level, inventory stats from buffed hit damage, rider imprint from AI bonuses and settings-dependent strength.

Island combat order is Megapithecus → Broodmother → Dragon → Overseer; first two can swap depending on artifacts/breeding, final gate requires all guardian trophies at chosen difficulty. Center is one joint arena, suggested monkey-first focus and Gamma→Beta→Alpha progression. Ragnarok dungeon prep leads to Nunatak; Lava is optional loot, spirit bear/wolf share one encounter, all other artifact routes still apply.

Ragnarok-only Base Location lists five SP-balanced choices, terrain region previews, pros/cons, suggested layout/checklist, timestamped YouTube external links and native map focus/profile round trips. Base layer/pins do not appear on Island/Center. Existing map progress/notes keys remain unchanged.

## Research, provenance and limits
Read firsthand Reddit ASA and Steam ASA threads, official community Wiki mechanics/patches and metadata/chapters from four ASA YouTube videos. No claim to exhaust every forum. Sources are stored in campaign/base JSON and visible in the app. Public API search was rejected; supported URL metadata inspection succeeded. Captions returned HTTP 429, so chapter metadata supplies video navigation; no video visual analysis or media download is claimed.

Deinosuchus Wiki patch 73.13 explicitly removes boss bleed; old croc-bleed strategies are excluded from defaults. Dragon's September 2026 reports include fire-spam failures, so published stats are not represented as guarantees. Guardian Alpha reference targets are source-informed planning goals; Gamma/Beta ranges and some alternative/support targets are editorial budgets, not certified minimums. Dungeon mount stats are marked inferred and conditioned on legal tame deployment. Tek Carcha clears the cave and is not included as an arena tame. Tek Cave notes distinguish 50 cave tames from 20 per teleport batch and possible multiple batches before starting the encounter; suggested solo armies intentionally stay at 20. Historical ASE dungeon discussion is labelled as such. Island/Center/Nunatak profiles do not share incompatible HP/Element or trophy rules.

## Base selection and popularity evidence
Ranking is Codex's balance assessment for Tony's SP use, not a verified per-location vote leaderboard. Public YouTube likes apply to entire videos. Exact source metadata snapshot: Phlinger Phoo: 617 likes, 21207 views; Ark: Survival Guide: 534 likes, 42474 views; The Outcasts: 166 likes, 15848 views; Inter: 7 likes, 642 views. App shows the actual inspected counts and source links. Reddit vote notes are per observed comment, with multi-location/region-only attribution explicitly identified.

| Rank | Location | Guide GPS | Timestamp source |
|---|---|---|---|
| 1 | Canyon Plateaus | 39.8 /44.8 | Ark: Survival Guide 3:53 |
| 2 | Ragnarok Falls / Large Waterfall Cave | 28.1 /48.3 | Ark: Survival Guide 6:00 |
| 3 | Viking Bay / Ribcage Cave | 22.8 /30.9 | Ark: Survival Guide 3:05 |
| 4 | Highlands Waterfall Cave | 18.0 /78.9 | Ark: Survival Guide 2:10 |
| 5 | Northeast Herbivore Island | 8.7 /96.7 | Phlinger 11:16; ASA guide GPS |

Main sources: [Ark: Survival Guide](https://www.youtube.com/watch?v=2-qtw1pdg2A), [Phlinger Phoo](https://www.youtube.com/watch?v=5mYGGM_bIhs), [The Outcasts](https://www.youtube.com/watch?v=7L82DkFipzU), [Top10PvE guide](https://www.youtube.com/watch?v=gK_j-65oX8w), [ASA region discussion](https://www.reddit.com/r/ARK/comments/1tu6s8z/base_locations_ragnarok/), [ASA main-base discussion](https://www.reddit.com/r/ArkSurvivalAscended/comments/1qzfkyz/), [ASA GPS corroboration](https://www.noobfeed.com/articles/ark-survival-ascended-guide-best-base-locations-on-ragnarok). Hidana/Green Obelisk has support but insufficient exact ASA/video evidence for a precise pin; not fabricated into this shortlist.

Terrain previews are native crops of the attributed offline terrain, explicitly not photos of built bases. Online YouTube thumbnails illustrate the source video, not an individual location. No media is downloaded to fake a screenshot. Coordinates are survey points, not foundations tested in the user's save. Cave build rules, spawns and transport routes must be checked in game.

## Review and validation
Existing independent reviewer found copied Dragon wording in other Theri options and overclaimed encounter-specific Alpha evidence. Corrected: non-Dragon/non-Overseer options use encounter-appropriate wording and state inferred targets without a matching success report. The full UI suite and final targeted regression passed; receipts below.

Deployment is standalone iPad Debug, no TestFlight, Tony OS or website update. Native app has no new official web domain; configured historical ARK hosting is not represented as a deployed 0.5 site.

Initial complete suite: 5/5 UI tests passed, zero failures, 207.273 seconds, `/Users/admin/Ascended-QA-05-1.xcresult`. After corrected source confidence/artwork, targeted boss/base round-trip test passed in `/Users/admin/Ascended-QA-05-2.xcresult`. Data audit confirms all 11 boss IDs covered with at least 2 options, every option artwork exists, all stage/army/base/video IDs resolve, 5 unique GPS pairs/ranks are valid. Screenshot inspection found the terrain-preview caption clipped; fixed the image sizing and added an explicit visibility assertion, with final rerun recorded below.


Final targeted UI regression passed with the preview-caption visibility assertion: `/Users/admin/Ascended-QA-05-3.xcresult`. Inspected final screenshots in `/Users/admin/Ascended-QA05-3-Screenshots`: terrain caption visible; Nunatak Theri artwork and source-confidence warning correct; focused base map/profile round trip verified by automation. Signed final device build succeeded (`/tmp/ascended-05-final3-device-build.log`). Cable install succeeded at 00:10 on 4 October 2026, bundle `com.tonytuanngoc.ascended`, on connected iPad (3), CoreDevice `8FA117DA-854A-5EEB-AEFC-EE54036237A9`. Final launch was denied because the physical device was locked; no physical interaction QA is claimed. Device inventory confirms Ascended version `0.5.0`, bundle version `5`, built by developer. Device inventory receipt is `/tmp/ascended-05-device-apps.json`.

Delivery checkout: `/Users/admin/Ascended-iPad-Dev`, branch `codex/ascended-ipad-dev-20261003`, remote `TonyTuanNgoc/ark-ascended-atlas`. Commit and push include only this standalone app and its reports. Native cable installation is this task's deployment; no web release or domain change.
