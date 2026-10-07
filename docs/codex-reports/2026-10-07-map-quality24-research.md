# Source imagery and coordinate-label research — 7 October 2026

## Changes and provenance

`tools/acquire_map_quality24.py` assembles original Wikily zoom-5 tiles for all eight expansion coordinate planes. Each canvas contains 1,024 individually validated 256×256 source tiles in original x/y order, producing 8192×8192. Original source hashes, output hashes and map templates are recorded in `2026-10-07-map-quality24-sources.json`. No image is enlarged during acquisition; JPEG encoding uses quality94 with normal chroma subsampling. All eight output files total192,905,818 bytes. Tile cache stays outside the repository at `/Volumes/TONY SSD/ASCENDED_MEDIA/map-quality24`.

The Island and The Center already contain8192×8192 tile canvases and remain unchanged. Ragnarok keeps the existing2048×2048 ASA Wiki raster because no genuinely better terrain source was verified. Source zoom5 was available and zoom6 returned404 at tile0/0 for all11 supported coordinate planes. This proves the highest level tested at that source, not the highest possible image anywhere. No DevKit download, AI terrain or synthetic sharpening was used.

The original0–100 atlas bounds and tile positions are unchanged: longitude maps to horizontal x; latitude to vertical y. No crop, padding, rotation or map transformation is introduced. This preserves current atlas geometry, not independent physical in-game GPS calibration.

## Actual visual assessment

The side-by-side artifact `2026-10-07-map-quality24-comparison.png` compares baseline2048 crops enlarged to the same viewing size against source-native zoom5 crops at the identical atlas area. All eight full-map thumbnails were inspected for completeness and correct biome/plane layout.

| Map plane | Observed benefit and limitation |
|---|---|
| Scorched Earth | Clearly sharper fine rock/vegetation boundaries and small terrain texture than previous z3 raster. |
| Aberration | Clearly sharper trees, rock edges and fine biome texture. |
| Extinction | Sharper individual structures, street/building outlines and foliage edges. |
| Genesis Part1 | Large real improvement in small terrain lines and biome island edges; existing empty gaps between biomes remain intentional. |
| Genesis Ocean | Fine water/reef texture improves; ocean plane is separate from main biomes. |
| Lost Colony | Source still contains obvious coarse pixel blocks. Avoid claiming8K effective terrain detail. |
| Valguero | Source still contains coarse pixel blocks; less improvement than the high-detail maps. |
| Astraeos | Source is a stylized illustrated atlas, including fine repeated water texture and labels, not aerial photography. Higher tile level preserves existing linework; it cannot become game satellite detail. |
| Ragnarok | Zoom5 tile and current Wiki raster show the same coarse terrain information. No meaningful additional terrain detail verified. |

## Ragnarok alternatives checked

- [Official Community Wiki map file](https://ark.wiki.gg/wiki/File:Ragnarok_map_ASA.jpg): existing2048 raster retained.
- [ARK Unity map](https://ark-unity.com/ark-survival-ascended/maps/ragnarok/) responds301 to [Wikily](https://wikily.gg/ark-survival-ascended/maps/ragnarok/), which exposes the same `ragnarok_tiles/{z}/{x}/{y}.png` source.
- [ARK Commands map](https://arkcommands.com/maps/ragnarok) publishes `/img/maps/ragnarok.webp` with declared map size1024; not a better native-resolution candidate.
- [ARK France](https://ark-france.fr/ragnarok-ark-ascended/) publishes `/assets/maps/ragnarok/topographic-asa.webp`, confirmed2048×2048. Matched crop has the same low-detail terrain as the current Wiki image, with additional WebP encoding differences. Not substituted.
- A DinoIndex candidate URL could not be retrieved. No source or quality claim made for it.

## Coordinate terminology evidence

[Official Community Wiki GPS](https://ark.wiki.gg/wiki/GPS) describes latitude and longitude, and explicitly notes that dye can obscure their labels. [Coordinate transformation](https://ark.wiki.gg/wiki/Coordinates) states latitude corresponds to UE Y and longitude to X. The [French Wiki GPS gallery](https://ark.wiki.gg/fr/wiki/GPS) links [an actual handheld GPS screenshot](https://ark.wiki.gg/images/Ragnarok_Metal_Cave_entry.jpg), visually inspected: LAT is below the left35.5 value and LON below the right24.1 value. These are coordinate labels; the compass above is a different display.

That screenshot is Survival Evolved. The current English Wiki specifically notes the handheld GPS is not normally attainable in Survival Ascended, so this is not physical ASA handheld-device proof. ASA coordinate references explicitly use `lat_ASA` / `lon_ASA` in the [Wiki cave template](https://ark.wiki.gg/wiki/Template:Infobox_caveruins). LAT/LON therefore accurately name the axes in this companion, while ↑↓/←→ alone are only axis hints. Integration also inspected the approved native ASA source [Ragnarok resource guide at98s](https://www.youtube.com/watch?v=5IhlD3yzqjU&t=98s): the game map prints **Latitude** and **Longitude** as words beneath the map. The companion uses their compact LAT/LON labels, not arrow-only symbols. Saved source frame: `ascended-0.23.0-24/ASA-coordinate-label-reference.jpg` (research evidence only; excluded from app assets).

## Renderer recommendations for integration

The baseline uses a full-size UIImageView with a trilinear minification filter and linear magnification. It does not explicitly resize/downsample the source before presentation. Increase the zoom range to make coordinate placement practical; this is magnification, not additional terrain information. A source-crop/tiled backing can draw source regions at each zoom and keep visible layer textures bounded. It does not guarantee that the image decoder avoids a full8192² RGBA decode (roughly256MiB); physical memory/performance must be measured separately. Keep marker coordinates in the existing atlas image-local plane so changing renderer does not alter geography.

Asset validation: all eight JPEGs decode at8192×8192; all eight manifests contain1,024 tile hashes; acquisition finished without missing tiles. Simulator/device/rendering QA is owned by the integrating parent task and is not claimed by this research note.
