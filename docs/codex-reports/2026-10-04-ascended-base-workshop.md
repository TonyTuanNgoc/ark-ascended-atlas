# Ascended base workshop — 0.17.0 (18)

Xây base opens the individual construction editor directly. The old base-map/3D segment, five-zone prose and width/depth controls are removed. Five practical 3D house templates show cutaway previews; selecting one lists actual component counts and equipment. The scene is brighter and controls/cards are compact. Original five-zone stored data remains intact, and the current map-scoped individual design key is preserved. Selecting a template saves the previous design for durable restore; normal edit undo remains available.

The Island now uses its actual bundled ASA terrain thumbnail, rather than a generic ARK logo. Map artwork is rounded; wider sidebar and two-line names prevent previous tiny columns of broken words.

## Catalogue and crafting

- 728 existing library entries imported into the builder catalogue: construction, machines, tools and resources. 378 construction/machine entries can be placed: 231 geometry reconstructions and147 explicitly labelled inventory-picture references. No original game meshes or textures were obtained.
- 511 entries have verified source recipe records; remaining entries are visibly unverified and excluded from totals. Sources/HTML SHA256 are retained internally. Standard items do not imply complete DLC or variant coverage. Exact ASA slugs take priority over legacy name normalization. Staircase/trapdoor variants and an invalid fractional source recipe are excluded rather than guessed.
- Actual placed counts feed per-component ingredient bills, direct ingredient totals and nine standard intermediate processing routes. Shared intermediates aggregate before batch rounding. Standard Sparkpowder produces2 per batch; Gasoline5. Crafting station names appear beside each process.
- Eight Stone Foundations =640 Stone,320 Wood,240 Thatch. Fabricator's50 Sparkpowder requires25 standard mortar batches. Chemistry Bench's Polymer/Electronics/Paste share intermediate demand rather than double-rounding each path.
- Fuel, construction of unowned stations, Chemistry Bench efficiency, blueprint quality and special DLC processing routes are not included. The final ingredient list may still contain intermediates without a supported process; it is labelled “Nguyên liệu cuối tuyến”, not universally harvestable raw resources.

## Size research and representation

79 wiki machine URLs attempted,28 successfully retrieved; three contain historical size notes. Beer Barrel notes half-foundation width,three-quarter depth,one-wall height. Fireplace notes roughly half-module footprint and four-wall chimney. Industrial Forge3×3×6 is enclosed housing clearance, not measured mesh bounds. These notes inform reconstructions only; no exact ASA mesh bounds or metre conversion claimed. Ordinary models display “Tỷ lệ mô phỏng”; picture references explicitly say no measured geometry. Snapping/support/collision rules are not a game simulation.

Source pages: https://wikily.gg/ark-survival-ascended/items/stone-foundation/ ; https://wikily.gg/ark-survival-ascended/items/large-crop-plot/ ; https://wikily.gg/ark-survival-ascended/items/industrial-forge/ ; https://ark.wiki.gg/wiki/Beer_Barrel ; https://ark.wiki.gg/wiki/Stone_Fireplace ; https://ark.wiki.gg/wiki/Industrial_Forge . Recipe and size-source records remain in bundled JSON and the size-research report.

## Verification and delivery

Six native unit cases and three scoped Simulator UI cases passed, covering foundation totals, shared intermediate batches, template recipe completeness, unverified exclusion, greenhouse module bounds, scene placement/edit/copy/delete/undo/relaunch, template component counts, bills, catalogue selection, map-layer checkboxes, story and machine-library routes. Source validator verifies378 unique models, asset references, finite geometry and normalized normals. Legacy eleven-model validator still passes. The first run completed all nine cases but Xcode hung during result finalization after a Simulator SpringBoard crash. Its case log is preserved; no completed result bundle is claimed for that run. After fixing clipped forge preview framing, all six unit cases and the directly affected template/crafting UI case reran successfully with diagnostics collection disabled: Test-Ascended-2026.10.04_23-24-08-+0700.xcresult. Final attachments visually confirm the brighter scene, complete forge preview and actual component panel. Fresh read-only review identified stale Blender transforms and recipe slug normalization; both fixed and tested before final delivery.

Signed device build succeeded and deep/strict codesign verification passed. Fresh cable install, device inventory and process launch confirm Ascended0.17.0 build18 on iPad A16 at23:29 local. These prove installation/version/launch; physical gesture and performance QA is not inferred from Simulator tests. Receipts in2026-10-04-base-workshop-proof.

Blender collection gallery preserved as artifacts/blender/construction-catalogue/Ascended-Construction-Catalogue.blend, plus SSD source. Earlier Blender files preserved. Models are reconstruction assets for planning, not DevKit imports.

Standalone Ascended cable delivery only; no Tony OS changes or TestFlight upload. The separate web atlas/domain is unchanged.

The task-generated Simulator app was moved intact to SSD QA-retained-0.17.0-18-Ascended.app to relieve internal disk pressure; the original Simulator path links to it. No user data, other apps, source footage or earlier artifacts were deleted. Simulator may need reinstall from the signed Simulator build for future QA.
