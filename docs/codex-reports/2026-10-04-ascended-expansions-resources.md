# Ascended 0.13.0 (14): maps, DLC and resource guides

Standalone native iPad release, installed by cable. No TestFlight, Tony OS changes or web hosting deployment.

## Delivered

- Ten released maps with eleven independent map planes, including separate Genesis Ocean coordinates. Seventeen map catalog records and twenty-two DLC/product records distinguish released, upcoming and unconfirmed content.
- Story order, ownership/purchase requirements, map goals, preparation, biomes, creature rosters and source-confirmed boss names. Available map selection stays in the left sidebar; upcoming maps cannot be selected as playable terrain.
- Eight new genuine 2048px terrain planes and 112,072 source resource nodes. Existing three map identifiers and progress remain intact.
- Resource guides for twenty-four essential resource groups on Ragnarok, The Island and The Center: seventy-two coverage entries, sixty-one verified location entries, four creature methods, four crafting entries and three boss acquisition entries.
- Forty-one unique photo/GPS farm regions: Ragnarok 18, The Island 12, The Center 11. Sixteen source videos were locally inspected. Every farm popup uses a hash-validated screenshot from its corresponding video, resource images, coordinates, short directions, equipment and a timed YouTube link.
- Four creature-method entries use footage and mechanics without invented GPS. Center Black Pearls footage does not verify a natural spawn, so its survey coordinate is excluded from map pins. Dynamic honey spawns and harvest quantities are not guaranteed.
- Existing original-three raw resource nodes remain preserved in data; their public resource layer now uses verified photographic farm regions. New maps retain source resource nodes without claiming equivalent video verification.
- Genuine artifact and equipment artwork. Clay recipe corrected to 2 Sand + 1 Cactus Sap → 2 Clay in a Mortar and Pestle.

## Verification

Final expansion/farm validator passed: ten available maps, eleven planes, twenty-two DLCs, forty-one photographic spots, all seventy-two coverage entries resolved. Asset hashes, screenshot dimensions, source/video identity, coordinate ranges and cross-map references checked. Existing visual facts, navigation and map asset validators passed.

Simulator scenarios passed: all eleven planes plus map information and Dino selection; original-three farm photo/GPS/video popup and zoom behavior; resource search/acquisition methods and selection from the DLC catalog.

Final results include:
- /Users/admin/Ascended-Build-Simulator/Logs/Test/Test-Ascended-2026.10.04_19-16-15-+0700.xcresult
- /Users/admin/Ascended-Build-Simulator/Logs/Test/Test-Ascended-2026.10.04_19-35-15-+0700.xcresult
- Farm popup run: /tmp/ascended-acquisition-final-test.log (its separate catalog assertion was subsequently corrected and passed in the final result above).

Signed device build succeeded; strict codesign verification passed. Cable installation succeeded and physical bundle inventory confirms 0.13.0 (14). Automatic physical launch was denied because the iPad was locked. Simulator interaction proof is not physical touch QA. Receipts: expanded-device-install.json, expanded-device-apps.json, expanded-device-launch.json.

## Scope and remaining content limits

New-map rosters include unreviewed species with unavailable artwork/detail profiles. New maps do not yet have complete cave video routes or verified obelisk coordinates; these are left absent rather than fabricated. Boss overview information does not constitute fully researched army campaigns for every new map. Existing thirteen entrance-photo gaps and earlier cave media limits are unchanged. The first three maps are the verified resource-video scope of this release.

## Source accountability

Source URLs, evidence, screenshot timestamps and hashes are retained in the expansion-sources, new-map-data-sources, resource-video-research, honey-resource-research, center-extra-farms, center-black-pearls and resource-crafting-sources JSON reports. Ordinary UI keeps concise gameplay guidance.

Baseline: branch codex/ascended-ipad-dev-20261003, fetched origin, starting commit 4b5a79e8b0e53efd9fbbcdba7c1ba66b59700781. Official repository: https://github.com/TonyTuanNgoc/ark-ascended-atlas . Native deployment has no web domain.
