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
