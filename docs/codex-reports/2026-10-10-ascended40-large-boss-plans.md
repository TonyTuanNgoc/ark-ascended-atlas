# Ascended 0.39.0 (40): large boss plans

Scope: standalone Ascended native app. Ragnarok five gallery entries and The Island four bosses. No Tony OS changes, web deployment or TestFlight upload.

## Behavior

- Full-screen boss presentation, large fixed name/portrait and dismiss button.
- Fight video at the top; chapter/sample excerpt sequence totals at most 120 source seconds, approximately 60 seconds at 2×. Supports individual segments, replay, 1×/2× and full video. Official YouTube streaming iframe plus external source fallback; internet required.
- Army / Preparation / Tribute / Location / Combat horizontal tabs. Named creatures and equipment, explicit quantities, preserved map/boss-specific stat targets and tier-specific tribute. Pinned full-aspect map uses existing location records.
- Arena teams and dungeon/on-foot encounters are distinguished. Spirit bear/wolf share one encounter. Overseer cave Carcha remains separate from the 19 Theri + Yuty arena roster. Planning quantities and current-save/patch dependency are visibly explained.
- Named artifact cards use actual map-specific artifact artwork. Unknown/new maps retain the previous detail content.

## Evidence and limitations

Compact source metadata: `ascended40/video-evidence.json`; in-app source drawer retains original mechanics/player reports and new creator video links. Creator-described exact roster is distinguished from a compiled planning recommendation. Historical single-tame strategies are optional examples rather than current guaranteed minimums.

No new YouTube video was downloaded or locally cut. API search rejected request parameters; caption requests returned 429. Metadata and published chapters were available. Visual streaming review was impeded by ads/playback errors; excerpt scene boundaries are not all frame-verified. Jonna-X no-chapter clips are explicitly sample excerpts; Spirit video is a dungeon-route guide rather than a certified complete kill montage. Video playback on physical hardware still requires user review/network. No successful fight guarantee is claimed.

## Validation

15 scoped tests passed: 6 boss-data cases, 7 existing Atlas presentation regression cases, 2 UI flows. Island Army/Tribute/Location and all five Ragnarok detail pages exercised; portrait Lava preparation verified. Eight UI screenshots exported and landscape Army plus portrait preparation visually reviewed. First run exposed accessibility identifier inheritance; corrected parent identifiers and reran successfully.

Simulator result: `ascended40/final.xcresult` (local untracked evidence). Screenshots: `ascended40/screenshots` (local untracked evidence).
Device build succeeded in 46.9 seconds. Built app readback: com.tonytuanngoc.ascended, 0.39.0 (40). Existing MapScreen contentEdgeInsets deprecation remains unrelated.

Physical cable installation succeeded on iPad (3), device 8FA117DA-854A-5EEB-AEFC-EE54036237A9. devicectl app inventory confirms 0.39.0 / 40. Launch succeeded with process ID 3101. Receipt: `ascended40/device-inventory.json`. Physical installation/launch is confirmed; physical fight-video playback and every-page touch behavior are not hardware-verified. Storage: SSD ~337 GiB available; Mac ~35 GiB (below the 40 GiB threshold); no cleanup or unrelated data changes.
