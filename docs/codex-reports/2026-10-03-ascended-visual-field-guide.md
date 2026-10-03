# Ascended visual field guide — 0.3.0 (3)

## Delivered scope
Authorized expansion of the independent native iPad companion: more offline images, boss dossier and location routes, artifact GPS and cave entrance/approach positions. No Tony OS changes, no TestFlight upload and no replacement web hosting.

- 23 additional attributed offline assets: ten artifact icons, three 2000×1125 Nunatak difficulty renders, four dungeon boss icons and six Ragnarok illustrations. Existing 152 creature icons, original ARK app logo and source-native 8192×8192 terrain retained.
- Ten current Ragnarok Ascended artifacts, distributed over six cave/underwater routes. Strong is at the southern Wyvern Cave; old Evolved Strong/Brute coordinates were excluded.
- Nine separately identified cave entrance/approach points, three Obelisk terminals and one approximate Lava Elemental arena point. Artifact GPS is labelled separately from entrance GPS. Ocean Devourer is a dive route without a cave entrance; Wyvern point is an approach. No invented precise Iceworm Queen or Spirit arena coordinates.
- Selectable map layers and markers, direct focus from profiles, fixed marker size through zoom, nearby-location chooser for overlaps and focus retained through rotation. Existing pinch/pan/double-tap/reset retained.
- Nunatak Gamma/Beta/Alpha: HP, entry levels, ten artifacts, Beta/Alpha apex tributes, Element, trophy/flag, Tekgram unlocks, summon terminals, arena constraints, combat phases, equipment and preparation checklist.
- Iceworm Queen, Lava Elemental, Spirit Dire Bear and Spirit Direwolf: associated dungeon, access routes, mechanics, gear and source-dependent loot/stat notes. Reference values are not presented as measured Single Player save values; mixed Wiki Evolved material explicitly identified.
- Persistent collection checklist (`ascended.artifacts.collected.v1`) and preparation checklist (`ascended.guide.checklist.v1`); existing notes key preserved.

## Research and source integrity
Reviewed 3 October 2026. Artifact/Obelisk coordinates come from Wikily Ragnarok Ascended engine layers (mapId=14); generic cave-layer centres were not mislabelled as entrances. Entrance routes were checked against the June 2025 Ascended artifact guide and compatible community Wiki details.

Primary data references: https://wikily.gg/ark-survival-ascended/maps/ragnarok/ , https://ark.wiki.gg/wiki/Nunatak , https://ark.wiki.gg/wiki/Ragnarok_Arena_%28Ragnarok%29 , https://ark.wiki.gg/wiki/Iceworm_Queen , https://ark.wiki.gg/wiki/Lava_Elemental , https://ark.wiki.gg/wiki/Life%27s_Labyrinth_%28Ragnarok%29 . Entrance/illustration reference: https://thegameslayer.com/guides/all-ragnarok-artifact-locations-ark-ragnarok-ascended/ . Asset provenance recorded in Resources/field-guide-image-sources.json.

Route photographs are general Ragnarok illustrations, not verified photographs of the labelled entrance. Every route caption states this. Approximate access locations and source-based mechanics require checking against actual terrain/game settings.

## Review and QA
Read-only review completed; addressed marker focus after selection, overlapping pins and honest photo captions. UI testing identified plain NavigationLink spacer regions not accepting centre taps; artifact rows/checklists now have rectangular hit targets. Tests distinguish nearby-location context-menu actions and sidebar Boss navigation from the map Boss layer.

JSON relationship validation: ten artifacts, six routes, nine access points, three terminals; artifact-to-route references and bundled icons resolved. GPS projection matches the source renderer's normalized LAT/LON map axes. SwiftUI and signed development builds succeed.

Final UI verification: `/Users/admin/Ascended-QA-03-7.xcresult`, three tests, zero failures, TEST SUCCEEDED. Checks include cave→artifact→focused map, overlapping-pin menu, pin size/hit target through portrait/landscape rotation, map layer hide/show, Nunatak Alpha HP/Element, current creature search/DLC/profile navigation, double-tap/fit/reset and notes retained after relaunch. Screenshots exported to `/Users/admin/Ascended-QA03-7-Screenshots`.

Final signed build: `/tmp/ascended-03-device-final2.log`, BUILD SUCCEEDED. Updated physical A16 iPad (iPadOS 27.0), CoreDevice ID 8FA117DA-854A-5EEB-AEFC-EE54036237A9: install and launch succeeded at 23:05 local time; app inventory confirms Ascended 0.3.0, build 3, separate from Tony OS/Tony OS Dev. Simulator interaction proof is separate from the successful physical installation/launch; full physical interaction testing was not performed. No TestFlight upload.

## Delivery boundary
Source branch: codex/ascended-ipad-dev-20261003, remote TonyTuanNgoc/ark-ascended-atlas. Native deployment is cable installation of com.tonytuanngoc.ascended. Configured existing web domain https://ark-ascended-atlas.web.app returned 404 in the initial delivery; native work does not produce a new web domain. Existing native/docs Hosting exclusions retained. Creature library has nineteen roster-only records awaiting detailed profiles; resource/creature spawn overlays and full progression/base/calculator planning remain subsequent work.
