# Ascended cave media

The user confirmed licensed reuse in this chat on 4 October 2026. Originals stay outside Git under `/Volumes/TONY SSD/ASCENDED_MEDIA/cave-sources`.

Use an isolated Python environment with `cave-media-requirements.txt`, ffmpeg and Deno. `acquire_cave_source.py` uses ordinary public yt-dlp access and explicit `--apply --approval RECORD --rights licensed --source-root PATH --url URL`. No cookies, account tokens, forced clients, paywall/age/geo/DRM/CAPTCHA bypasses. A failed or restricted download is a limitation, not permission to bypass it. Verify actual final packet timestamps, not only container duration. Shared Tony OS tools are untouched.

Tony prefers Cốc Cốc for watching and ordinary manual downloading when needed. Use the browser's normal permitted download flow; this release's recovered sources used the isolated downloader, not manual Cốc Cốc capture.

Review actual footage, entrance, branch landmarks and artifact in order before setting `visuallyReviewed`. `build_cave_gifs.py --source-root PATH --recipe docs/codex-reports/...-gif-recipe.json --resources native/Ascended/Resources/CaveGIFs` renders only curated ranges. Provenance stays in recipes; app manifests contain player-facing content only. Run `python3 tools/validate_cave_gifs.py` after rendering. GIFs are 512×288, 8 fps, 64 colours, normally 14 seconds; originals are retained for future higher-resolution re-renders.
