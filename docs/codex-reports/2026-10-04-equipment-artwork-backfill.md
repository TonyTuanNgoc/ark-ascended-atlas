# Equipment artwork backfill — 2026-10-04

The inventory library now contains 728 actual item references, all with source-accountable local artwork.

| Category | Items | Pictured |
| --- | ---: | ---: |
| Resources | 78 | 78 |
| Machines and utilities | 79 | 79 |
| Tools, weapons, armor and ammunition | 184 | 184 |
| Structures | 299 | 299 |
| Supplies and food | 88 | 88 |
| **Total** | **728** | **728** |

520 missing Equipment imagesets were added. The library uses 570 Equipment imagesets in total plus 158 existing exact-match item assets. Every Equipment PNG matches its recorded SHA-256 and every referenced image decodes successfully.

Public ARK Official Community Wiki catalog tables supply the exact item-to-image mapping. Downloads use an honest custom user agent and pacing, resolving the anonymous curl rate limit without inventing item matches. Original image URLs, hashes, dimensions and source pages are retained in `2026-10-04-equipment-sources.json`.

Airplane has no published table icon. Its exact Wiki infobox game-model screenshot (`Airplane.jpg`) was inspected and encoded as PNG without cropping, recoloring or changing pixels; both source JPEG and stored PNG hashes are recorded. Other added assets are original source PNGs.

Four egg-size classifications were removed from inventory: Exceptional Dinosaur Egg, Extraordinary Dinosaur Egg, Regular Dinosaur Egg and Superior Dinosaur Egg. These are classification labels rather than actual named inventory items. Visual Facts and recipe-guide data remain intact. The acquisition generator excludes these labels from future inventory rebuilds.

Validation: 728 unique IDs; 728 nonempty asset references; all images decode; 570 Equipment PNG hashes match; category and manifest counts agree. Against baseline a6a9c30, catalog text and availability are unchanged apart from the four explicitly authorized classification removals and new artwork references. The artwork-only acquisition mode preserves reviewed catalog text and checkpoints each acquired icon.

Native rendering, Simulator, device build and release verification are handled separately by the parent task. This report does not claim device installation or publication.
