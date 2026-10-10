# Ascended 0.38.0 (39): physical iPad delivery

Tony changed the delivery request from TestFlight to a development install over the connected cable. No TestFlight upload was performed.

- Source: c799aa36c2e471099981eae31e10db8fb99b948c, branch codex/ascended-ipad-dev-20261003; source and upstream matched before installation.
- Product: standalone Ascended, com.tonytuanngoc.ascended; no Tony OS changes and no official web domain.
- Device: iPad (3), iPadOS 27.0.1, identifier 8FA117DA-854A-5EEB-AEFC-EE54036237A9.
- Debug device build succeeded in 108.2 seconds using the existing SSD DerivedData directory. The single existing contentEdgeInsets deprecation warning does not prevent the build.
- Built Info.plist readback: 0.38.0, build 39. Strict recursive code-sign verification passed. Development profile expires 2027-06-22.
- MobileBuildMCP reported successful cable installation and successful launch, process 3033. No uninstall or app-data reset was performed.
- Physical touch, video playback and performance were not independently reviewed in this delivery. Existing scoped Simulator QA is recorded in the build 39 report.

The preceding Release archive succeeded but measured 7,457,048,306 uncompressed bytes. Apple currently limits iOS/iPadOS builds to 4 GB, so that archive was not submitted. Media compression work was stopped when Tony changed the request; no media was removed or recompressed. Source assets and archive remain on SSD.

Evidence: device39/installed-app.json and device39/delivery-receipt.json. Build cache: /Volumes/TONY SSD/ASCENDED_MEDIA/builds/Ascended-0.14.0-Device. Mac free space was 39 GiB, below the 40 GiB storage-policy threshold; SSD had 347 GiB available. No cleanup was performed.
