# Ascended GIF walkthrough acquisition and captions

The user approved licensed reuse of all selected cave walkthrough videos and requested natural Vietnamese directions below GIFs when useful. This approval resolves the previous rights gate. It does not establish route accuracy.

## Acquisition verification

Used the official `tony-youtube` licensed download flow with all three approval gates. Ragnarok, Center and Island Hunter each returned HTTP 403; a normal Ragnarok retry also failed. No authentication, PO-token or access restriction bypass was attempted.

The resulting DASH video prefixes are incomplete. Scanning actual packet timestamps, rather than trusting container metadata, found:

| Source video | Last available packet | Metadata duration |
| --- | ---: | ---: |
| dB3V_7-s92s | 54.65 s | 1388.05 s |
| vD4U9Hyi1WY | 75.60 s | 1148.67 s |
| 0f1o5yfh27M | 52.30 s | 1296.55 s |

The prefixes cannot establish complete entrance-to-artifact continuity. No completed GIFs or turn instructions have been shipped. Source files remain outside the Git repository.

## Caption acceptance criteria

Each useful instruction goes directly below its corresponding GIF, in short conversational Vietnamese. It identifies a visible landmark, the next movement/turn, and a hazard or required interaction when relevant. The full route must be visually checked in order, with exact entrance/GPS and artifact matched to the selected map. All branches must be explicit. Do not invent turns from metadata, produce placeholders, or represent a chapter link as a GIF.

The remaining required input is a complete licensed local MP4/MOV export of the selected walkthroughs, or restored normal source download access. The existing native 0.6.0 (7) UI and chapter links remain available. No new web domain, TestFlight release, or Tony OS deployment is involved.

## Delivery receipt

JSON validation and `git diff --check` passed. Documentation-only update; native source and media assets unchanged. Reinstalled signed 0.6.0 (7) on the paired physical iPad via cable at 09:33; CoreDevice installation and process launch both succeeded. Logs: `/tmp/ascended-gif-caption-device-install.log`, `/tmp/ascended-gif-caption-device-launch.log`. This verifies deployment/launch, not physical touch QA or GIF playback.

## Acquisition restored and curated release

The earlier HTTP 403/prefix receipt above is historical. An isolated yt-dlp 2026.08.19 runtime restored ordinary public downloads without changing shared Tony OS tools. No cookies, PO tokens, forced player clients, account sign-in or access-control bypass was used. Complete used originals are verified against actual final video packets and SHA-256 in `2026-10-04-cave-source-integrity.json`. The optional failed Devourer short was replaced with the complete original.

Rendered 467 licensed GIFs from 25 complete used sources, covering all 25 artifact-bearing cave/approach routes on Ragnarok, The Island and The Center. Tek Cave has no artifact and retains full-video chapters rather than an invented artifact route. Natural Vietnamese instructions accompany relevant steps. Internal recipes retain exact source IDs/time ranges and visual-review status. User-facing screens omit research metadata.

Route qualifications: the Island Snow GIF route requires unlocked Tek gear and Element; the full Yutyrannus video remains available for players without Tek. Frozen Dungeon's final Pack placement demonstration uses Creative footage and is explicitly identified in its instruction, separately from the survival entrance/Queen route. Paid Pyromane usage is identified. Life's Labyrinth preserves both branches, button/SCUBA/parkour/sacrifice sequences and convergence; no exact button combination is claimed where the source itself is ambiguous. Stationary fighting/preparation/ads/return trips can be omitted with the relevant next-step prerequisite; recorded fall/recovery and meaningful movement are retained.

Future acquisition preference: watch and use ordinary permitted manual downloading in Cốc Cốc when needed. This release was downloaded through the isolated runtime; no manual Cốc Cốc capture is claimed.
