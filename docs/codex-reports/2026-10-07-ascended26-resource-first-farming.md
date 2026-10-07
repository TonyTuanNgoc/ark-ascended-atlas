# Ascended 0.25.0 (26) — resource-first Farming

Standalone Ascended native app. Tony OS, web hosting and TestFlight unchanged. Existing personal data is preserved.

## Delivered

Farming opens with an always-visible horizontal illustrated resource selector and search. Selecting a resource shows a compact zoomable map containing only matching reviewed filmed-region pins, one active location preview, and a horizontal location gallery. Gathering and production/crafting advice lives below. Textual Watch/Read acquisition buttons and the three-clip filmstrip are removed; an accessible source-video icon remains in the preview. The selected resource defaults to Metal when available and scrolls into view.

The map-scoped roster has 959 map/category entries, 137 unique resource families across 11 map planes. Only Wood, Thatch, Fiber, Stone and Flint are excluded basics. Includes creature materials, berries/seeds, crop and tame production, boss rewards and expansion resources. Ordinary eggs/feces are grouped. The roster distinguishes obtaining mechanisms and retains applicable conditions; it does not claim every resource has a verified extraction pin. Map-specific obtaining methods appear before generic harvesting advice; conditional production/boss rewards suppress generic gathering instructions.

137 icon mappings resolve genuine ARK item art, including 42 new public Wiki inventory/stat icons and existing artwork. Berries, ordinary Eggs and Feces use representative family art. Water uses ARK's actual hydration artwork. Honey/Salt/Sand aliases match canonical resource selectors and existing pins; ambiguous mushroom/bone/gem labels are not invented as material categories.

54 existing guides now use one continuous clean interval each instead of three fragments. Nine additional GPS-reviewed locations add 6 Center regions, 1 Island cave chamber, 1 Ragnarok seabed oil field and 1 Valguero pearl bed. Total 63 reviewed regions, 63 muted H.264 autoplay loops, native source resolution capped at 1920×1080 without upscaling. All clips are at most 10 seconds; new intervals are 6–8 seconds. Coordinate qualifications remain beside GPS, including the Island interior chamber being distinct from its entrance.

## Evidence and limits

Location evidence uses actual camera GPS rather than copying a fullscreen map cursor, caption-only coordinate or legacy ASE node. Source-frame timestamps, clips, source URLs, hashes and review manifests are retained under tools/evidence/farming26-sources, farming26-additions.json, resource-media26, farming26-roster.json and farming26-icons.json. Natural/corpse/production map applicability combines local ASA catalogs with primary Wiki mechanics, documented as inference where appropriate. This is not independent in-game calibration of every map or a guarantee of node/creature respawn or yield.

Nine existing clean intervals remain only 2–5 seconds; a nominal six-second interval encodes to 5.958 seconds at 24 fps. Their available footage cuts or opens an obstructing interface before a longer clean window. No splicing, fake extension, interpolation or invented harvesting. Clips show terrain/approach/resource views; many do not show completed harvesting. Source contexts and encoded clips were sampled at up to 4 fps and decoded fully; sampled review is not every-frame certification.

Public video acquisition returned HTTP 403 and YouTube search/API diagnostics failed. Caption-only or incomplete source candidates were rejected. No authentication/challenge/rate-limit bypass. Expansion map density remains limited: Aberration 2, Astraeos 1, Extinction 1, Genesis 1, Genesis Ocean 1, Lost Colony 1, Scorched Earth 2, Valguero 2. Resource categories without verified footage show an empty map and applicable advice, not fabricated pins. More independent source footage/GPS research remains necessary before calling every resource/map complete.

Primary mechanics were checked against ARK Official Community Wiki. Raw Salt's page explicitly supports Extinction salt pillars/fossils as well as Gacha; review's initial Gacha-only assumption was withdrawn. Source URLs live in the evidence/data, not a player-facing source wall.

## Verification and delivery

Independent read-only review found map-specific conditions hidden by generic advice, GPS caveats removed and Water missing from the icon/roster data. All corrected and re-reviewed without further important findings. Initial 23 unit + 2 scoped UI cases passed. Final frozen verification and native installation receipt will be appended after completion.

Final frozen run passed all 23 unit and 4 scoped UI cases (resource selection/search, single loop, Atlas hierarchical filters, one-row map/header, source-tile deep zoom/reset). 63 clips and all 137 icon mappings passed the independent source-file validator. Both Simulator and signed iPad app bundles match 1138 current JSON/MP4/JPEG source files, resolving Xcode’s flattened resource packaging. Strict/deep device codesign passed.

Simulator 0.25.0/build26 was installed by the test runner and freshly launched with PID7856. Ascended iPad QA window was independently seen in landscape. Screenshots and receipts are in ascended-0.25.0-26. A hardware install attempt failed because iPad was locked; user then explicitly requested Simulator only, so no further hardware installation attempted. The signed iPad build is ready for a later authorized installation. No physical playback/touch proof is claimed. Standalone native deployment has no website/domain.
