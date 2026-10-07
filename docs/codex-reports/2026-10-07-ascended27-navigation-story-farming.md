# Ascended 0.26.0 (27) — navigation, Story and focused Farming

## Requested behavior

A centered, visually coherent current-map button with a full-card hit target; larger centered screen headings; horizontal Story topics with larger artwork; Farming restricted to Black Pearls, Cementing Paste, Chitin, Crystal, Giant Bee Honey, Metal, Obsidian, Oil, Organic Polymer, Rare Flowers, Rare Mushrooms, Rich Metal, Sap and Silica Pearls.

## Changes

The map artwork and map-name/chevron row are centered inside one 124 × 80 point card. Chevron no longer sits in a separate circular control. The full rectangle is the button hit target; tapping opens the picker explicitly. Module artwork grows from 28 to 38 points and labels from 11 to 12. Screen titles use a centered 24-point rounded bold style.

Story has seven horizontal illustrated topic cards with one selected reading panel below. Full story exposes a horizontal chapter picker with preserved map illustrations and complete chapter text; Characters uses a horizontal name selector. Shorter topic labels preserve the original paragraphs and spoiler gating. Existing native raster artwork is reused at larger sizes with consistent spacing, gradient cards and selected outlines; no synthetic game screenshots or changed gameplay claims.

Farming uses an exact 14-resource focus list on every map; the broader equipment/resource catalogue remains intact. Three equal columns occupy a fixed-height viewport: zoomable map, horizontal small location/clip cards, and pictured creature/tool harvesting guidance. Swipe the middle column horizontally to browse locations; the right column scrolls internally when advice is longer. No outer vertical Farming page or production/acquisition grid. Existing verified pins, GPS caveats, source-video links and native source loops are retained; absent verified points stay empty. Rich Metal uses the existing Metal harvesting reference alias, while its verified pin filter remains distinct.

## Verification

Pre-change test confirmed all three map-card tap positions opened on a single tap in Simulator; the user's intermittent multi-tap symptom was not reproduced there. The same test failed on absent horizontal Story controls and title sizing before implementation, documenting the previous layout. Post-change results and Simulator deployment receipt follow below.

Standalone Ascended only. No Tony OS, web hosting, TestFlight or physical iPad changes; user requested Simulator review. Native application has no official web domain.

Final run passed 23 unit tests and all 4 scoped UI cases. Covers repeated one-tap map opening at 3 card positions, Story topic selection, chapter and character selection, centered title/Equipment handoff, one-row map navigation, 3-column Farming geometry, Rich Metal selection, search/filter and source-link accessibility. The new lazy location card initially merged descendant accessibility identifiers; explicit containment restores separate source-link identity. A rapid portrait/landscape test transition also produced a transient popover miss; final tests use the requested stable landscape orientation. Screenshots were exported and visually reviewed. Genuine Dino silhouettes now resolve directly (including Gacha, Magmasaur and Giant Queen Bee) instead of item-box fallback.

Simulator bundle plist confirms 0.26.0/build27; initial fresh launch PID59002. No hardware installation or web domain. Final screenshots and test receipt: ascended-0.26.0-27/.

Final visual refinement keeps the map fitted when the resource selector or location carousel changes. Explicit pin taps still focus/zoom. This avoids an automatic first-card zoom and keeps the whole map readable. One follow-up search test exposed keyboard-focus timing; it now waits for the onscreen keyboard before typing. Final affected-case verification is recorded in the delivery receipt.

Both affected Farming UI cases passed after the map-fit refinement and keyboard wait. Final source-link test, resource search and 3-column screenshot verify the delivered code.

Final fresh launch PID61905. Independently observed Ascended iPad QA window on The Island Atlas with the new header. User can select Farming / ASA Story. A later native coordinate-click attempt returned windowNotFoundAtPosition; no claim of leaving Farming active is made. UI test screenshots provide the verified Farming/Story rendering evidence.
