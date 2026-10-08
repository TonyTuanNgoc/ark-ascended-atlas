# Ascended 0.37.0 (38) — The Island Survival Guide

Added a map-specific visual PvE route that balances a lasting attractive home, utility and exploration tames, caves/ocean trips and guardian/Overseer progression. Open The Island → Survival Guide beside Story. Server explanations remain deferred.

## Delivered behavior
- Eight freely browsable phases: Beach Home, First Flight, A Base to Keep, Caves & Ocean, Raise Your Army, First Guardians, Face the Dragon, The Island Complete.
- 87 illustrated goals: 74 checklist milestones and 13 optional activities/alternatives. Suggested quantities are planning choices rather than guaranteed victory requirements.
- Four compact top-aligned groups on the QA iPad landscape layout, horizontal phase strip, existing Dino/item/artifact artwork, source detail sheets and direct shortcuts into the existing relevant modules.
- Manual completion persists under a new Island-only storage key; optional goals do not block a phase. No game telemetry or automatic acquisition claim. Existing map/progress keys and catalogues preserved.
- Other maps explicitly show that the Island guide comes first; no reused Island progression presented as their guide.

## Research and limits
17 attributed references: six player/gameplay sources and eleven mechanics/game-data references. Every goal retains source IDs; source sheets expose links, claim scope and review date. See [source audit](ascended38/research/source-audit.md).

Read actual community playthrough discussions, cross-checked primary Wiki excerpts and the ASA cake recipe, and reused previously reviewed BEYPlaysGames Swamp Cave footage. New YouTube API searches were rejected; no fresh video watching or captions claimed. Some direct Wiki pages failed to open, so indexed primary excerpts supplied the corresponding checks. The route order and leisure milestones are editorial synthesis, not sourced mandatory unlocks.

Guardian/Dragon artifact sets are explicit. Gamma Tek Cave requires level 60 and three guardian trophies or higher equivalents. Shared Therizino/Yuty army quantities remain suggested; an optional pig replaces a fighter. Cakes do not cancel percent-health Dragon breath, no fixed Alpha stat threshold or old Deinosuchus boss-bleed shortcut is promoted, and AI armies are not assumed to receive rider-only imprint bonuses. No uncertain cave caps, new coordinates or server-rate formulas imported.

## Verification
- 16 scoped tests passed: four new guide data/progress tests, existing Atlas presentation/Farming37 units and guide/Atlas UI flows.
- UI flow verifies actual save/relaunch, undo back to original user checklist, goal references, Sources sheet, map isolation and all 87 goal controls fitting the QA iPad landscape viewport across eight phases.
- Final guide UI rerun after the single top-alignment adjustment passed (1 UI flow, 99.0 seconds). Beach Home and Army screenshots were visually reviewed: group tops align, headings/artwork are readable, checklist controls remain visible.
- Existing source artwork resolves, Dino references belong to the Island roster, source/goal IDs and required/optional semantics checked. `git diff --check` passes.

## Delivery
Standalone Ascended native iPad app. No Tony OS, physical-device, TestFlight or web/domain release. Regular build-and-run targets only Ascended iPad QA (20C9346D-B0E6-4239-8152-1D85ADD57BA6), preserving the other Simulator sessions.

Final screenshots: [Beach Home](ascended38/final-screenshots/AFAEEA7F-00CB-42E2-A90F-8C64B674B205.png), [Army](ascended38/final-screenshots/9E511F25-359A-41C1-A1E3-3574164810CC.png). QA logs: [16-test run](ascended38/qa-compact.txt), [final layout rerun](ascended38/qa-aligned.txt).

Regular Simulator build/install/launch succeeded (27.5 seconds), bundle `com.tonytuanngoc.ascended`, PID 29565. Installed bundle readback confirms 0.37.0 (38): [runtime receipt](ascended38/runtime-receipt.json). Ascended QA Simulator window was activated through its Window menu. Final screenshot attachments show the guide during UI QA; ordinary fresh launch retains the existing Atlas default, and the guide opens through the header.
