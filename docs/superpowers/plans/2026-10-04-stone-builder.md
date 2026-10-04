# Stone Builder Implementation Plan

Goal: Native iPad placement of eleven individually modelled Stone construction variants with persistence and sourced direct material totals.
Architecture: Blender generates reconstructions and exports triangulated mesh JSON; SceneKit loads those meshes. SwiftUI manages a snapped half-module cursor, heights,quarter-turn rotation, selection, placement, duplicate/delete/undo and map-scoped saved designs. Existing five-house layout stays intact.
Spec: User-approved eleven-piece Stone set and construction workflow in chat; dimensions approximate and all artwork reconstructed, no original game asset claims.
Tech: SwiftUI, SceneKit, Blender5.2.2, Codable/AppStorage, Python validators, XCTest UI.

- [x] Generate eleven textured mesh variants, verify finite coordinates, normals and nonempty triangles; preserve Blender file.
- [x] Add native builder entry and editor with persistent placed pieces, stable camera, selectable models and direct recipe counts; prevent exact duplicate placements.
- [x] UI test place/rotate/move/copy/delete/undo, bill change and relaunch persistence. Inspect real scene screenshot.
- [x] Build signed0.16.0(17), cable install and launch, distinguish Simulator and physical evidence. Commit/push/report.
Constraints: standalone Ascended, no Tony OS/web/TestFlight changes. Snapping is a planning aid, not ARK support/collision validation. Half-grid for boundary walls; triangle equilateral geometry is previewable but no automatic60-degree triangle-edge snapping claimed. Budget uses direct ASA engrams and combinesvariants that share the same ASA craft item. Persistent schema namespaced by map, does not overwrite existinghouse data.
Review focus: camera unchanged by edits; old saves ignored safely on malformed data; off-grid edits clamped; overlapping different shapes allowed deliberately for design; duplicate exact same piece position and orientation rejected visibly; costs count actual placed pieces only; variants remain qualified reconstructions.
