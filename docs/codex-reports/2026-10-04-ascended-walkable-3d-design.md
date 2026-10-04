# Walkable cave 3D — clarified scope and data dependency

User clarified during the session pilot implementation: actual cave interior on iPad, simplified vegetation, retained rock walls, floors and junctions, manually controlled character able to move forward/back and turn. This is a separate deliverable from the waypoint/GIF pilot. No automatic game position is required for this manual rehearsal mode.

## Data acquisition
- ARK DevKit is a Windows custom UE5 editor; official store lists full game content: https://store.epicgames.com/p/ark-survival-ascended--devkit?lang=en-US
- Official changelog lists Ragnarok content update 67.35.228.728534: https://devkit.studiowildcard.com/changelog
- Installation guide recommends SSD with 1.2–1.5TB available: https://devkit.studiowildcard.com/getting-started/installing-the-devkit
- Generic Unreal USDExporter supports level and static mesh exports: https://dev.epicgames.com/documentation/en-us/unreal-engine/API/Plugins/USDExporter
These documents establish a candidate pipeline, not a verified export of Jungle Dungeon from the specific DevKit. No DevKit installation or export has been performed. The app repository and its cave media directory have no surveyed 3D cave model.

## Pilot acceptance target
1. Open current Ragnarok content in DevKit and locate the actual Jungle Dungeon world cells/actors. Preserve original actor transforms and units. Export a small entrance slice first to verify tools before a full cave.
2. Retain traversable rock geometry, wooden bridges, gaps, lava boundaries and any genuine navigational obstructions. Remove only decorative foliage; keep landmarks represented by distinct silhouettes/colors. Simplifying an obstruction away must not invent a traversable route.
3. Bake readable materials/lighting and reduce rendering complexity while preserving junction widths, elevations and connectivity. Validate export against the licensed footage and current game, especially bridge gaps and the Hunter ledge. Record original-to-iPad coordinate transform.
4. Native offline scene with avatar, camera look, forward/back/turn controls, wall/floor collision, optional overhead/cutaway view, reset to verified checkpoints and visible breadcrumb trail. Player position within this rehearsal scene stays distinct from any unconnected game position.
5. Link checkpoints to existing GIFs; changing viewpoints or watching clips never marks artifact collection. Return traversal uses real geometry, not reversed outbound footage.
6. Verify all junctions, recovery/rejoin branch, elevation transitions and entrance-to-artifact-to-exit traversal on iPad. Measure frame rate, responsiveness, memory and thermal behavior with the actual exported geometry.

## Current dependency
User answered: plays on a Windows computer at an internet cafe; uses Mac to prepare/install the iPad app. The cafe computer is not an established development machine and must not be assumed available for DevKit installation. A separate geometry-preparation environment/export is needed; the resulting iPad scene should run fully offline at the cafe. No accessible Windows/DevKit session or actual cave export currently established. Do not present the interim waypoint schematic as a walkable 3D cave and do not fabricate a matching cave from videos alone.
