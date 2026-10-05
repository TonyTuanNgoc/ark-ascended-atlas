# ASA map reference acquisition — 5 October 2026

This addition contains 73 source references, including 36 entrances, from ASA-specific Wiki DataMaps and the Wikily ASA extracted actor registry. Coordinates describe source atlas planes. They are not presented as independently observed in-game GPS, and entrance photographs identify terrain rather than calibrate GPS.

| Plane | New ASA entrances | Obelisk/terminal records | Limitation |
|---|---:|---:|---|
| Island | 23 | 3 | Includes 12 unnamed underwater entrances; existing route IDs retained for 11 named routes. |
| Ragnarok | 0 | 3 | Existing reviewed entrance routes remain; addition excludes actor cave centers. |
| Center | 0 | 3 | ASA Wiki contains obelisks but no entrance layer; legacy Evolved entrance layer rejected. |
| Scorched Earth | 5 | 3 | Correct colors confirmed by ASA Wiki, despite extraction's generic terminal labels. |
| Aberration | 8 | 4 | Three artifact cave entrances and five surface entrances; Lost artifact cave entrance unresolved. Rockwell terminal explicitly named. |
| Extinction | 0 | 4 | Three terminals outside 0–100; boss association unresolved. Chaos artifact also outside plane, preserved separately. |
| Lost Colony | 0 | 7 | ASA Wiki configuration found; marker request rate limited. Generic terminal names retained. |
| Genesis Part 1 | 0 | 0 | Extracted terminal layer empty; no invented GPS for HLN-A/mission initiation. |
| Genesis Ocean | 0 | 0 | Same limitation; biome is not an independent expansion. |
| Valguero | 0 | 0 | Cave actor centers rejected as entrances; licensed GPS video retrieval failed. |
| Astraeos | 0 | 9 | ASA Wiki configuration found; marker API rate limited. One extracted terminal beyond longitude 100. Orientation and expanded boss coverage unresolved. |

## Evidence and acquisition

`tools/acquire_atlas_reference_layers.py` requests only Wiki DataMap containers explicitly ending `_ASA`. It uses the site's public `queryDataMap` API, recording page/revision, request URL and cached source SHA-256. Legacy inline maps, Evolved coordinates, and extraction cave centers are excluded.

Primary ASA datasets retrieved: Island DataMap page 72797 revision 600695; Scorched Earth page 78055 revision 600987; Aberration and Center exact revisions are included in each JSON source object. Lost Colony configuration page 86916 revision 600802 and Astraeos page 87859 revision 601078 were retrieved, but markers returned HTTP 429. No bypass attempted. Configuration's terminal icons/names alone do not establish terminal coordinates or boss associations.

Raw acquisition snapshots reside at `/Volumes/TONY SSD/ASCENDED_MEDIA/reference-locations-20261005`. Wikily map IDs are preserved in per-plane coverage. Every admitted point includes canonical page URL, exact data API URL, source type and source cache hash. No inferred color is assigned to a generic terminal. Rockwell is the only explicit named boss terminal association; Tek Cave retains Overseer association and existing route navigation.

`tools/acquire_atlas_reference_photos.py` downloads exact ASA Wiki entrance JPEG references, stopping on a refused request rather than substituting unrelated media. Twelve source photos succeeded: 11 named Island entrances and Grave of the Tyrants. Remaining photos retain canonical source URL, without a local-image claim.

YouTube metadata inspected via `youtube-learning` and `/Users/admin/bin/tony-youtube`: RP7bA_veAYc, 10qmkPXO3zg, xi2891FLTB4, kgEXDdJpTek, IzKTaVjnciA. User's existing licensed-media authorization passed download-plan and three download gates for RP7bA_veAYc and xi2891FLTB4. Both media requests failed HTTP 403. Caption retrieval failed HTTP 429. No GPS frame was observed; metadata chapters and artifact-description coordinates were not promoted to entrance proof.

## Integration

`AtlasReferenceLocations.references(in:)` retains all source records, including five outside-plane points. `points(in:)` admits only `insideAtlas` records within 0–100. It does not clamp or invert coordinates. Root owns calibration and merge priority. Prefer ASA Wiki entrance references over actor-based route fallbacks, matching `routeID` to preserve navigation. Keep existing reviewed routes where this addition lacks entrance proof. Generic terminals are terminal pins, with no guessed boss portal or arena claim. A terminal position cannot stand in for the distant arena or approach.

Validation: all 73 IDs are unique, all local image references resolve, source metadata is present, and Chaos's artifact key is `chaos`. Full Xcode/device QA and catalogue/project integration belong to the root task. No commits, deployment or project changes were made by this subtask.
