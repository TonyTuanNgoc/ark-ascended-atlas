# Ascended 0.22.0 (23) — horizontal navigation preview

User requested Simulator review on October7. Standalone Ascended only. No Tony OS, TestFlight, web hosting or physical-device installation in this task.

## Layout and behavior

The left module sidebar is replaced by a horizontal rail containing all nine existing modules. The centered ARK logo is larger and has no backing rectangle or outline. Current-map artwork uses its original image aspect ratio, rounded corners and no surrounding black frame. One persistent Maps control opens a unified popover with Story Maps and Exploration Maps groups, selected-map checks, scrollable choices and nested Genesis Ocean biome.

Equipment Library has five permanently visible horizontal categories matching the existing catalogue: Resources, Tools & Equipment, Machines & Utilities, Building Structures, Consumables & Food. Tapping a category displays only that category. Search is always visible and applies within the selected group; the query remains when switching groups. Seven landscape item columns remain, with adaptive widths and complete item names. Category controls and search stay above the results scroll view. Search submission dismisses the keyboard; results also support interactive keyboard dismissal. Module/category labels use full two-line names.

15 original transparent raster avatar images were generated separately with imagegen: nine modules, Maps, five equipment categories. They are new navigation illustrations, not claims of exact game-item artwork. Existing item photos/icons and white creature silhouettes remain. Generated alpha channels and original pixel files are preserved in Assets.xcassets; manifest records source paths, pixels and SHA256.

Module/map switching resets the detail navigation stack to its new root. Existing user save keys, designs, GPS pins, notes and progress storage remain. No content JSON, recipes or source-coordinate data changed.

## Verification

First draft Swift layout compiled. Independent read-only review found no actionable P1/P2 in the scoped navigation/search/persistence changes. Initial runs exposed outdated vertical-scroll test selectors and a parent accessibility identifier overriding Search. Both were corrected. A search keyboard obstruction was addressed with submit dismissal. One Simulator rotation precondition failed in a repeated run; the Ascended-only Simulator was freshly booted before the final verification. Final evidence is recorded below.

Source baseline3dc0947; branchcodex/ascended-ipad-dev-20261003; fetched origin before edits. This preview does not replace the previously installed physical-iPad build22 without a separate native installation.

Final verification: xcodebuild test succeeded with17unit tests and12scoped UI tests, zero failures/skips. Includes actual portrait frame/screenshot verification, all9modules and5categories on one landscape row, seven item columns, selected-category search, keyboard submission, equipment details and switching out of details, unified map sections/selection, saved GPS points, field information, army and cave walkthrough regressions.

Final result bundle: `/Volumes/TONY SSD/ASCENDED_MEDIA/builds/Ascended-0.14.0-Simulator/Logs/Test/Test-Ascended-2026.10.07_15-58-44-+0700.xcresult`. Exported evidence in `ascended-0.22.0-23/`. Reviewed actual screenshots for full labels, generated avatars, centered unframed logo and current-map artwork.

Installed and launched0.22.0(23) on Ascended iPad QA Simulator20C9346D-B0E6-4239-8152-1D85ADD57BA6; installed Info.plist confirms bundle/version/build; launchPID8145. Foreground Simulator is in landscape with Ragnarok Equipment Library/Resources selected and search visible, verified through UI accessibility and screenshot. No physical install or performance claim. There is no official web domain for this standalone native preview.
