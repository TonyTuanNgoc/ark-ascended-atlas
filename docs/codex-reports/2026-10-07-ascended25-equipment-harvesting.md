# Ascended0.24.0(25) — equipment references, harvesting and navigation hierarchy

Standalone native Ascended, branch codex/ascended-ipad-dev-20261003, baselinecd86a43. Clean checkout and fresh origin fetch before edits. Simulator preview scope; no TonyOS, TestFlight, web/domain or physical-device installation.

## Result

Ascended is the primary brand: enlarged unboxed100×88 logo, separated from a smaller selected-map image/name with a prominent cyan dropdown. Nine modules remain one horizontal row inside a common subtle panel representing the selected map. Existing map persistence, IDs and map-switch behavior preserved; all modules remain reachable in landscape, module strip scrolls on narrow displays.

Equipment details now load offline facts for all728 catalogue IDs. Primary item pages were acquired with per-page URL/hash/retrieval timestamps.591 rows have a selected ingredient formula;720 contain4,743 stat values. Eight do not have usable stats, including an Explosive Arrow source-parent mismatch (Tek Bow page); wrong-parent bow data is excluded. Per-item statuses preserve edition uncertainty. Recipes show item pictures, quantities, stations, batch controls, reviewed output counts and ingredient crafting/gathering breakdown. Stats include published weight, durability, stack, health, level/EP, damage and other item-specific fields. Base values and blueprint/server variations are distinguished; this is not personal-save verification.

41 resource harvesting guides cover tools, creature roles, prey/node targets and supported weight reductions, traced to58 primaryWiki URLs. Indexed source text was used where direct page opens were blocked; some index crawl dates are days to a month old. Metal Pick favors ordinary raw meat; Metal Hatchet favors hide. Prime fish, chainsaw underwater restrictions and other resource-specific exceptions are retained. No universal best creature or fixed harvest yield is invented. Raw meat guidance uses concise player-facing wording; provenance remains in metadata. Guides appear in resource details, relevant tool details and expandable Farming cards.

## Corrections found while auditing

- Standard Water Reservoir was incorrectly populated from a Frontier WaterTank_Large class: selected standard30Stone/5Paste, Inventory. Existing artwork already represents the standard tank.
- Bee Hive default blueprint inputs are not a player engram: removed fictitious craft costs; show Giant Bee acquisition instead.
- Absorbent Substrate:8BlackPearl/8Sap/8Oil→6. Mutagen800Mutagel→6; Mutagel4Mutagen→408. All three use Chemistry Bench batch references, not unmultiplied class defaults.
- Thalassian Hoversail uses450HardenedSteelIngot rather than genericMetalIngot.
- Cryofridge uses explicitASA12Crystal/7Electronics/115MetalIngot/30Polymer. Cryopod'sASA4Polymer recipe retained, mixed-edition station list needs in-game confirmation.
- Chemistry Bench's old electricity-onlyASA claim removed because primary pages conflict without a clearASA-specific exception. Operation requirement remains explicitly to confirm; Fabricator/TekReplicator ASA power exceptions have primary support.

Six identity/batch corrections also update the construction bill catalogue. Costs aggregate item counts before rounding batches, so sixAbsorbent Substrate outputs consume one batch, not six. Added reviewedAbsorbent Substrate process expansion; no automatic mutually recursiveMutagen/Mutagel dependency expansion. A reproducible corrections script runs after future secondary crafting acquisition and passed an exact-byte idempotence check.

43 remaining secondary/primary recipe disagreements are marked for review; ASA combined structure formulas are retained rather than replaced by ASE counterparts. Some ingredient alternatives and stats remain cross-edition references. Whole-catalogue fact coverage does not mean all728 items are obtainable on every map or every numerical field is independentlyASA-confirmed.

## Verification and delivery

Final app/code/data passed22unit+14scopedUI cases in Test-Ascended-2026.10.07_18-11-26-+0700.xcresult. Covers standard/core recipes, source identity fixes, batch rounding/aggregation, ingredient expansion, meat/tool reverse lookup, seven-column/horizontal library/search, one-row map picker/header, portrait, deep map zoom, personal location persistence, Farming selectors and scoped map information/base stages. Last own-English raw-meat wording cleanup is checked again by22unit+2detailUI cases, recorded below. No Home/Contact/Roadmap changes because this is notTonyOS.

Simulator receipt and final screenshots are in ascended-0.24.0-25; shipping resource hashes must match the installed bundle. Physical iPad remains separately delivered0.21.0(22); no physical touch or performance claim. Commit/push evidence is the repository history. Native-only deployment has no official web domain.

Final wording-only check passed22unit+2detailUI cases in Test-Ascended-2026.10.07_18-29-04-+0700.xcresult. FinalSimulator install/readback0.24.0(25) and launch succeeded; allfour updated bundledJSON files match repoSHA256/bytes. Screenshot review confirms the brand/map/modules hierarchy and visible intermediate ingredients and meat creature/prey rows.
