# Ascended 0.18.0 (19): English atlas and staged house gallery

Standalone native app, branch `codex/ascended-ipad-dev-20261003`, based on clean remote e577b04. Source fetch confirmed before work and again before delivery. No Tony OS, TestFlight or web/domain deployment in this native cable scope.

## User-visible changes

- Global top current-map badge and styled Story Maps / Exploration Maps selectors. Left sidebar contains reference modules only; removed Maps & DLC entry. Header sits above the navigation split so it cannot intercept nested toolbars.
- English Swift screens and resource content, including creature categories, story, map information, boss campaigns, farming, base locations and cave/GIF directions. Stored IDs, user progress, coordinates and source metadata preserved. Local iPad OS status labels remain controlled by the device language.
- Equipment images reduced; seven items per wide landscape row, adaptive fewer columns at narrower widths. Complete names wrap. Story cards have clearer visual groups, map badges, spoiler disclosure and gameplay context.
- Map rail now 190–240pt with full English labels and retained checked states; scrollable resource filters.
- Manual construction palette grouped by Thatch, Wood, Stone, Metal, Greenhouse, Adobe and Tek. Framed position/action controls, persistent right Parts / Resources / Craft panel. Standard recipe/intermediate math retained.
- Fifteen actual community layouts across Home, Workshop, Storage, Greenhouse and Forge (three each). Scene geometry uses source placement/rotation data and reconstructed mesh families; cumulative Foundations / Frame / Roof / Equipment stages. Every phase's component count matches its bill. Gallery does not overwrite or clear the saved manual design.
- App-suggested functional equipment is separately flagged and labeled. It is included in equipment-phase bill but excluded from original creator structure counts. All houses retain creator/source access; four have creator-linked YouTube tutorials.

## Source boundaries

Public Wikily creator pages and downloadable template JSON supplied original placement data and grouped required structures. Original HTML/template SHA256 and records are in `2026-10-05-house-gallery-sources.json`. Acquisition and processing tools are checked in. Existing ASA recipe catalogue is joined by source slug, preserving combined ASA engrams rather than guessing item variants.

YouTube Data API search rejected parameters/key and the tested caption endpoint returned HTTP429. No video media downloaded, no spoken material count invented, no claim that all videos were watched or that the models reproduce original game meshes. Eleven templates do not have a creator-linked video; this remaining video research is incomplete. Stage progression is derived from exported structures, not a narrated step-by-step tutorial.

Planning appearance, pivot offsets and scale are approximate; cosmetic skins and unsupported objects are explicitly disclosed. Original game mesh dimensions, ARK support/collision checks and roof variants are not verified. Unsupported objects remain counted in bills; unknown recipes are excluded and named. Suggested equipment positions are planning proposals, not creator-authorized placements. Recipes exclude fuel, missing crafting station costs and blueprint multipliers.

## Verification

- Eight unit cases passed: existing six recipe/batch tests plus community phase/coverage integrity and unknown-recipe exclusion. All15 have exactly three per zone, valid placements/model IDs, per-stage count parity and cumulative totals.
- Four scoped UI cases passed across finalized runs: map selectors/full rail labels, all five gallery zones/three choices/stages/manual-save isolation, manual place/copy/move/delete/undo/material budget/persistence, English story/seven-column library/adaptive portrait header.
- Final shared-UI recheck passed after library responsive-grid adjustment. Landscape first seven item frames share a row. Screenshots reviewed for wide map rail, gallery, manual editor, story, library and portrait; proof images in `2026-10-05-ascended19-proof`.
- JSON translation invariants preserved keys/types/array lengths/numeric values/numeric tokens and URLs/IDs/assets/hashes; guide audit additionally manually corrected navigation semantics (pink plants, cave exit transport, retreat route, dismount point, lethal traps, Pyromane size, story events). Source occurrence counts: catalogue7556 and guide2161 translated strings; guide816 unique strings manually refined. Hidden provenance fields retained.
- Independent final review found phase classifier inconsistencies, absent functional fit-outs, missing source access and manual toolbar leakage; all were fixed and rereviewed without remaining focused blockers.
- Final device build succeeded; bundled community/story/expansion/equipment/stone/GIF JSON bytes were compared with repo sources and matched. First device install failed with a delta-manifest version0/expected18 mismatch; original app18 and its data remain intact. Delivery receipt below records the final retry.

## Physical delivery

Final signed cable install succeeded from a fresh APFS-cloned delivery path after the delta-manifest failure. Fresh physical device inventory confirms version0.18.0 build19; launch with terminate-existing succeeded at00:38:42 local on2026-10-05. All63 bundled JSON resource files match the repository. Deep/strict codesign verification passed. Receipts are in2026-10-05-ascended19-proof. These prove version/install/launch; physical touch/performance QA is separate from Simulator proof.
