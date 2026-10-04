# Ascended 0.5.1 (6) — white creature avatars

## Change
User reported black and red creature avatars unreadable on dark backgrounds. Added shared CreatureAvatar view with explicit white template rendering for all Dino-* and Boss-* icon assets. Used in Dino cards/detail portraits, both boss profile types, campaign rows and army options across all three maps. Nunatak photographic art remains original. Source image files, map art and logo are unchanged. No AI image edits or asset downloads: this is native display tinting.

## Verification
Active clean branch was fetched first: codex/ascended-ipad-dev-20261003 in /Users/admin/Ascended-iPad-Dev; local and remote baseline c488b3e matched. Simulator build/test succeeded: two existing relevant UI tests passed with zero failures in 73.231 seconds. Receipt: /Users/admin/Ascended-QA-051.xcresult. Exported screenshots in /Users/admin/Ascended-QA051-Screenshots; visually inspected Dino DLC grid and Cerberax detail: white icon detail visible on dark backgrounds. Boss army and map/profile round trips passed. No new tests added for this display-only change. Signed device build succeeded (/tmp/ascended-051-device-build.log).

Cable installation succeeded on connected iPad (3), bundle com.tonytuanngoc.ascended. Device inventory confirms version 0.5.1, bundle version 6, builtByDeveloper=true (/tmp/ascended-051-device-apps.json). Automatic launch denied due to locked device (/tmp/ascended-051-launch.log); no physical visual QA claimed. Native cable installation is deployment; no TestFlight, Tony OS or website change, and no new official web domain.

Bounded brainstorming design: white shared tint everywhere creature icons appear, preserve unrelated photographic assets; direct user instruction authorizes implementation without another approval stage. Verification-before-completion applied using fresh results above.
