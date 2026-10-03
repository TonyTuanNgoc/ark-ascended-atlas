# Ascended iPad development 0.2.0 (2)

## Scope and repository inventory
Authorized: independent Ascended native app, original game logo, cable-installed development build, no TestFlight; Single Player Ragnarok, current creature and boss libraries, high-resolution zoomable map.

Worktree `/Users/admin/Ascended-iPad-Dev`, branch `codex/ascended-ipad-dev-20261003`, created from fetched `origin/main` at `82d5ba4`. Remote: TonyTuanNgoc/ark-ascended-atlas. Primary SSD checkout `/Volumes/TONY SSD/TONY_WORKSPACE/CODE/Other/ARK Ascended` is also reachable through `/Users/admin/ARK Ascended`; its untracked `.firebase` directory was preserved. Primary code and archived LOCAL-HOLD copy match by SHA; migrated Mac Documents GitHub copy has no commits/source. No additional active iCloud repo was found.

Existing data: 201 creatures, 135 labelled Ragnarok, nine maps, 13 boss entries, large item and practical taming/loot libraries. Historical source version April 2026; Ragnarok's Dragon/Manticore entry describes Evolved and was not reused as the Ascended boss. No source web data was overwritten.

## Delivered
- Independent SwiftUI iPad app `com.tonytuanngoc.ascended`, original ARK logo app icon.
- Offline 8192×8192 map from source zoom 5: 1,024 native-resolution tiles, no upscaling. Zoom 6 returns 404; this is the highest source level verified, not a universal claim about all possible map sources. Pinch/pan, double-tap, zoom buttons, fit/reset, rotation and dark native layout.
- Searchable, filterable 159-entry Ragnarok creature/variant roster: 151 Wikily map spawn-registry entries plus Xiphactinus and seven Alpha variants from official community wiki. Variants count separately; source records do not guarantee actual spawns in every save/settings combination.
- Current structured details for 140 entries; 19 explicitly roster-only. Twelve DLC-labelled entries. 152 offline icons; seven fallback symbols. Black transparent line icons render with native tint for visibility on dark cards.
- 126 explicitly dated archived notes (20 April 2026) retained from the existing repo, clearly separated from current records.
- Official 30 September update integrated: Cerberax, Gargantar, Cryolophosaurus on Ragnarok. Tek creatures/Dragon/Manticore are not presented as Ragnarok Ascended wildlife/boss.
- Five named boss profiles: Nunatak main boss with Gamma/Beta/Alpha; four named mini-bosses across three dungeon encounters (Iceworm Queen, Lava Elemental, Spirit Dire Bear, Spirit Direwolf).
- Local persistent notes and attributed source links. Existing notes key preserved across updates.

## Verification and deployment receipt
- Xcode 26.5, signed development build using team HP5W6N9V3N: BUILD SUCCEEDED.
- QA result bundles: `/Users/admin/Ascended-QA-6.xcresult` and subsequent final verification recorded below. QA6: two tests passed, zero failures; catalogue DLC/search/Cerberax profile/Nunatak navigation, landscape/portrait map, double-tap zoom value change, fit/reset and notes persisted after app relaunch.
- Fixed an intermediate packaging failure: XcodeGen did not include JSON through a separate resources key; Resources now participates explicitly in sources with resources build phase. Verified bundle file and functioning catalogue via UI test.
- Review found untameable entries displaying generic tame foods and sentinel method X; method/food now require tameable=true. Diet remains separately labelled.
- Physical A16 iPad, iPadOS 27.0: compatible usable development disk image after unlocking. devicectl installation and launch successful; app is independent of Tony OS/Tony OS Dev. Final update receipt recorded below. Physical install/launch is verified; simulator interaction/screenshot QA does not establish full physical interaction QA.
- Development provisioning expires 22 June 2027 (current profile). No App Store Connect/TestFlight upload.
- Source committed and pushed to the feature branch; exact commit is retrievable from Git history. Native source/docs excluded from Firebase Hosting to prevent upload by existing web CI.

No new web hosting deployment was requested. Configured existing domain https://ark-ascended-atlas.web.app returned HTTP 404, and configured Firebase project is not accessible to current account (only Tony OS project listed). No replacement domain created and no Tony OS deployment performed. Deployment for this task is the native iPad installation.

## Practical limits
Map is terrain only: no spawn/resource overlays or coordinates yet. No full progression phases/base planner/calculators yet. Catalogue has 19 entries awaiting detailed profiles. Sources are dated snapshots, not live updates. Notes remain local to device; deleting the app removes them. Development installation is subject to signing validity.

## Final verification
- Final signed build: `/tmp/ascended-device-build-final.log`, BUILD SUCCEEDED.
- Final UI QA: `/Users/admin/Ascended-QA-8.xcresult`, two tests, zero failures, TEST SUCCEEDED. Screenshots exported to `/Users/admin/Ascended-QA8-Screenshots`.
- Final installed app inventory confirms Ascended 0.2.0 (2). Earlier 0.2 launch succeeded; final installation succeeded, but subsequent automatic launch was denied because iPad locked again. Awaiting user unlock for final launch confirmation.
