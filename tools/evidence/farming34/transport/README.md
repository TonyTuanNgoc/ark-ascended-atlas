# Farming34 ordinary download transport investigation

Verified 2026-10-08 without changing Tony OS runtime, CLI or app sources.

## Concrete defect and current gate

Installed Tony YouTube runtime is yt-dlp 2026.7.4, yt-dlp-ejs0.8.0, Deno2.9.2, ffmpeg8.1.2. Its installed `extractor/youtube/_video.py:142` defaults to (`android_vr`, `web_safari`). yt-dlp maintainer PR17461 documents that all android_vr formats return403 from2026-08-17, and issue17456 pins the remedy to2026.08.19 or later. This upstream failure matches earlier partial-opening-then403 observations; prior recordings do not preserve selected client and therefore cannot conclusively prove the individual historical failures used android_vr.

Official latest stable release checked live is2026.08.19. It removes obsolete android_vr defaults, adds visionos and web_embedded fallbacks. Installed EJS0.8.0 matches upstream dependency, Deno2.9.2 exceeds current2.6.6 dependency minimum. Reinstalling only EJS, Deno or ffmpeg has no evidenced benefit. An old extractor is a concrete contributor; it is not the only present blocker.

Created isolated official2026.8.19[default] runtime under external media transport directory. No custom client flags, cookies, PO tokens, browser impersonation, proxies or chunk manipulation. One normal full-video request per fresh source, retries0, fragment_retries0, skip_unavailable_fragmentsFalse, <=1080p ordinary selection. Triple gates supplied `--apply --approval ID --rights licensed`, backed by existing human licence line2578 (`Duyệt,a có giấy phép hết`). Availability/live/age/rights validator retained; metadata failed before media and hence before current availability validation could complete.

Both newly selected ASA sources OwYNQrNlnv8 (Center crystal315s) and j0jU5sigiMA (Astraeos polymer199s, supplied by source research agent) stop at extraction with DownloadError and diagnostic classes Sign in / PO Token; default visionos and Deno2.9.2 observed. No media files and no HTTP response code stored. No retry of either denied source. These JSON categories establish an explicit account/attestation gate, not a decoder failure. Exact raw message subtype was intentionally not logged. Upgrade alone did not establish authorized download access here.

## Legitimate next paths

Use permitted public browser playback to identify source scenes; browser access still does not establish ordinary downloadable file access. Obtain original licensed MP4/MOV from creator/rights holder through their authorized file delivery; local trusted source import then fully decode and review GPS/resource/clean6-10s windows. Use existing already acquired licensed full local sources if complete and useful. If the user's own channel owns an upload, use YouTube Studio official download or Google Takeout. Platform offline downloads normally stay in the platform and are not original export assets. No cookies/PO-token harvesting, alternate client forcing or access-gate bypass proposed.

## Primary sources

- https://github.com/yt-dlp/yt-dlp/issues/17456 (maintainer resolution)
- https://github.com/yt-dlp/yt-dlp/pull/17461 (obsolete client failure)
- https://github.com/yt-dlp/yt-dlp/releases/tag/2026.08.19 (official release changes)
- https://github.com/yt-dlp/yt-dlp/blob/master/pyproject.toml (EJS/Deno compatibility)
- https://github.com/yt-dlp/yt-dlp/wiki/EJS (supported JavaScript installation)
- https://github.com/yt-dlp/yt-dlp/wiki/PO-Token-Guide (attestation limitations; no tokens used)
- https://support.google.com/youtube/answer/56100 (official own-upload Studio/Takeout downloads)
- https://support.google.com/youtube/answer/7381437 (platform offline encryption and playback limits)

JSONs store allowlisted metadata/diagnostic categories only; signed media URLs and secrets are absent. No app builds, repository source changes, commit or deployment performed by this investigation.

## Successful licensed normal-window recording

Root verified normal public non-DRM Chrome playback, manually selected the correct native active tab, recorded an isolated explicitly approved Chrome window without fetching restricted media or exporting cookies/tokens. `TUoB8ouWPYk-active-2x.mp4` is a valid Aberration reference source. Whole695.336667secondH264decode passes exit0 with demux timebase and zero diagnostics. SHA256 and durable play/capture clock mapping are in `TUoB8ouWPYk-clock-and-integrity.json`. Default null muxer had timestamp-rounding duplicateDTS warnings; preservingdemuxtimebase removed those warnings.

Encoded capture is1184x666,20304frames,1014781306bytes. These are capture dimensions, not a claim of native YouTube resolution.35samples at20second spacing all have distinct hashes, with mean grayscale difference39.006855/255 (minimum14.289063); this verifies sampled frame variation, not continuous motion at everyframe. Overview visibly contains distinct Aberration terrain with no Chrome toolbar. It includes authoredGPS/map/inventory overlays and YouTubeendcard, so those regions are research only and excluded from clean delivery footage.

Capture starts12.251seconds before playback. Source0.068941seconds at05:12:47.214UTC/rate2 maps via `movieTime=12.251+(sourceTime-0.068941)/2`. Independent root play anchor896.438464 at05:20:15.396UTC differs by0.005523source seconds (<0.01). Source speed must be restored for normal6–10second delivery playback. Priorpart1 was wrong-tab frozen footage and part2 was truncated: both remain preserved and rejected.

Reusable recorder source copied to `tools/window_recorder/` with relative build instructions; isolatedactivecapturebinary was not overwritten. Workstate now records valid/rejectedacquisition facts and current unverified rootcontrolledLostColonycapture separately. No native app source changed.

## Lost Colony source acquisition integrity

`Oxyw-jv19xQ-active-2x.mp4` passes whole330.501667seconddecode with preserved demuxtimebase, exit0/zero diagnostics. Encoded1184x666H264/9672frames,465363430bytes. SHA2567840598a437094947a86240c910dce4cb6f71dab8d2a738bd910012fff1a4b37. v2 title gate matched `ALLE RESSOURCEN`; sidecar compares9671frames, mean pixel difference14.751287, maximum stagnation23.613seconds/no30secondwarning.

Clock: firstsample05:25:56.702UTC; root source0.046994 at05:26:05.445UTC/rate2 gives `movieTime=8.743+(sourceTime-0.046994)/2`. No independent drift checkpoint supplied. Cropped overview shows distinct moving gameplay without Chrome toolbar. Source menus/HUD/promotional text and end recommendations are reference-only. Creator promotes custom cluster caves/systems/items; source agent must verify vanilla/current-map resource compatibility before native integration. Acquisition success does not clear that compatibility caveat.
