# Ascended Stone builder — 0.16.0 (17)

Native iPad now has a separate individual Stone construction editor under Xây base → Xây từng cấu kiện Stone. The original five-house functional floorplan, save key, media and other modules remain intact.

## Delivered
- Eleven Blender reconstruction collections: square/triangle foundation, wall, doorframe, reinforced door, square/triangle ceiling, sloped roof, stairs, pillar and railing. 12,942 triangulated faces; rough geometry, vertex colours, UVs and bundled procedural grain. Approximate module dimensions, not original game meshes/textures.
- SceneKit selection and half-module ground cursor; height levels 0–5, quarter-turn rotation, place/move, duplicate/delete and 50-step undo. Camera survives edits. Exact same-kind/position/orientation duplicates are rejected. Up to 500 pieces per map-scoped saved design; restored after relaunch.
- Ingredient bill counts actual placed pieces using standard ASA recipes. No machinery/fuel or blueprint-quality multipliers. No ARK support/collision simulation or automatic 60-degree triangle-edge snapping.
- Source Blender kit preserved at artifacts/blender/stone-builder/Ascended-Stone-Building-Kit.blend and on SSD. Opened all eleven collections in Blender; saved a copy of the dirty prior sample before switching files.

## Verification
- tools/validate_stone_builder.py passes all eleven mesh/normal/UV/colour/asset/recipe checks and normalized roof rise/run. Two foundations + one wall = 200 Stone,100 Wood,75 Thatch.
- Final Simulator result: Test-Ascended-2026.10.04_22-25-53-+0700.xcresult. Both testStoneBuilderEditingBudgetAndPersistence and testPracticalBase3DAndMapLayerChecks passed (0 failures). Actual UI covers placement, rotation/move, copy/delete/undo, duplicate prevention, exact ingredient amounts and relaunch persistence; previous base cost and map checkboxes pass. Screenshot inspected: mesh appears, palette and controls fit landscape.
- Initial regression failure was prior QA's saved resized-house state (36,420 vs default33,860). Test now resets that existing layout through its reset button before checking default cost. No production-layout data migration was introduced.
- Fresh read-only review found texture packaging, half-grid duplication boundary and roof span issues; all three corrected before the final run/build. Source recipes and SHA256 evidence: 2026-10-04-stone-builder-validation.json.
- Signed device build succeeded; deep strict codesign verification passed. Cable installation and inventory/launch receipts are below. Physical interaction is not covered by Simulator assertions.

## Delivery
Cable install completed successfully. Fresh CoreDevice inventory confirms Ascended0.16.0, bundle17 on iPad A16 (8FA117DA-854A-5EEB-AEFC-EE54036237A9); direct process launch succeeded at22:31 local. This proves install/version/launch, not physical tap, camera-gesture or performance QA. Receipts preserved in the proof folder.

Standalone Ascended only. No Tony OS, TestFlight, web or domain deployment; native delivery is the signed cable app. Public web atlas is a different artifact.
