# Licensed visible-window recorder

A standalone macOS ScreenCaptureKit helper for recording explicitly approved, public, non-DRM footage already playing normally in a selected Chrome window. It never operates a browser, fetches media URLs, exports account data, changes permissions or captures the full display/other windows/audio. Existing macOS screen-recording permission must already exist. The human must verify media rights and normal visible playback before applying.

From the repository root:

```sh
swiftc -swift-version 5 -parse-as-library tools/window_recorder/WindowRecorder.swift -o /tmp/ascended-window-recorder -framework ScreenCaptureKit -framework AVFoundation -framework CoreGraphics -framework AppKit
/tmp/ascended-window-recorder --window-id WINDOW_ID --approval VIDEO_ID --rights licensed --seconds 8 --expected-title 'PUBLIC SOURCE TITLE' --crop X,Y,WIDTH,HEIGHT
```

The command is a dryrun until `--apply` is supplied. Apply also needs `--output` ending.mp4 within the explicitly approved scratch folder `/Volumes/TONY SSD/ASCENDED_MEDIA/farming34/browser-recording/`; existing output never overwrites. No private window titles are logged. Crop coordinates use window points before pixel scaling; output rounds dimensions to even pixels.

Delivery capture is limited6–10seconds. `--source-review` allows30–1200seconds and labels output deliveryEligible=false. Source review footage requires local reference review, resource/GPS evidence and clean delivery cuts. Record source play timestamp, UTC and rate in a separate manifest. The sidecar capture PTS is a host capture clock, not a source timeline.

Optional `--expected-title` checks public window title before capture and every15seconds, aborting on mismatch. Optional `--stop-file` uses an initially absent path within approved scratch folder and ends recording when the file appears; the helper does not delete it. ProgressJSON prints every15seconds.

Sidecar records UTC first/lastframe, capturePTS, framecount and motion review. Entirely black/no-frame output is rejected. Sampled motion below0.1levels on255scale is treated as static/compressionnoise; no motion for30seconds emits a warning but does not reject legitimate staticGPSshots. Unexpected title changes invalidate capture. Root must visually reject blocked content, Chrome/playercontrols, source menus/maps and endcards before delivery.

Verified: Swift compile clean; matching expected-title dryrun passes; incorrect title and duration outside allowedrange reject. This helper does not prove footage identity or licenses by itself.

V3 preserves failed partial files and writes `.mp4.failure.json` even when stopping ScreenCaptureKit fails. Failure evidence includes safe NSError domain/code (and underlying domain/code), recording stage, frame count and first/last capture times, writer status and public source-title match result. System localized descriptions and userInfo are omitted because they can contain private paths, URLs or account data. Failure status always sets usableMedia=false and deliveryEligible=false, even if writer finalization succeeds. No failure file is promoted to delivery automatically.

Optional `--source-review --fragment-seconds 10` sets AVAssetWriter.movieFragmentInterval before writing. Apple documents fragment support for some container formats; actual interrupted MP4 recovery with this helper remains unverified. The option does not repair existing incomplete recordings. Prefer serial, bounded source segments, verify each finished file, and keep separate source/UTC playback anchors for every segment. Do not run overlapping captures when diagnosing a capture-service failure.

Apple references: [movieFragmentInterval](https://developer.apple.com/documentation/avfoundation/avassetwriter/moviefragmentinterval), [finishWriting](https://developer.apple.com/documentation/avfoundation/avassetwriter/finishwriting(completionhandler:)). Writer completion must be checked after finishing. Fragment creation cannot guarantee usable footage or bypass black/blocked content.
