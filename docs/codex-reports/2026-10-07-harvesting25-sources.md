# Harvesting reference source review — 2026-10-07

The companion now has 41 curated resource entries in `native/Ascended/Resources/harvesting-guide.json`. Each entry carries its own source URLs, review date, tool roles, creature roles, source targets and limitations. Selected confirmed cargo reductions have a separate numeric `weightReductions` list. They apply while the resource is in the named creature inventory, not as a global harvest multiplier.

Public browsing used indexed ARK Official Community Wiki page text. Direct URL opens returned HTTP 403; therefore the review date records the current research session, not a successful real-time retrieval of every canonical page. Search results reported crawl ages from days to approximately one month. This work does not claim fresh gameplay measurements, fixed yields or exhaustive map availability. The JSON source report lists all referenced URLs and catalogue node types still lacking a curated entry.

## Practical corrections

- [Raw Meat](https://ark.wiki.gg/wiki/Raw_Meat), [Metal Pick](https://ark.wiki.gg/wiki/Metal_Pick) and [Metal Hatchet](https://ark.wiki.gg/wiki/Metal_Hatchet): pick favors meat, hatchet favors hide. Carnivores are practical bulk harvesters. A creature's harvesting rating is not a ranking of meat dropped by prey.
- [Hide](https://ark.wiki.gg/wiki/Hide): Phiomia is explicitly identified as useful for meat and hide; early Dodo/Lystrosaurus/Parasaur sources are different from a claim that one species always yields the most. [Ovis](https://ark.wiki.gg/wiki/Ovis) provides a confirmed health-dependent mutton/hide source.
- [Raw Prime Meat](https://ark.wiki.gg/wiki/Raw_Prime_Meat): larger eligible creatures and alphas are source targets. ASA also has wild babies yielding prime meat. No universal yield ranking is fabricated.
- [Raw Prime Fish Meat](https://ark.wiki.gg/wiki/Raw_Prime_Fish_Meat): Metal Sickle is a practical primary tool, while dead Dunkleosteus/Megalodon have the page's hatchet exception. Chainsaw cannot work underwater. This prevents the ordinary meat/pick shortcut from becoming a false universal rule.
- [Ankylosaurus](https://ark.wiki.gg/wiki/Ankylosaurus) and [Doedicurus](https://ark.wiki.gg/wiki/Doedicurus): current ASA Harvest Only selection is retained; older ASE auto-harvest weight thresholds are not copied into ASA advice.
- [Therizinosaur](https://ark.wiki.gg/wiki/Therizinosaur): power, delicate and bite context differ. [Anglerfish](https://ark.wiki.gg/wiki/Anglerfish): bite harvests pearl clams. [Beelzebufo](https://ark.wiki.gg/wiki/Beelzebufo): eligible small insects yield paste; that is not every chitin corpse.
- [Gathering and Weight Reduction](https://ark.wiki.gg/wiki/Gathering_and_Weight_Reduction): qualitative table entries are useful source options, not measured per-minute production. Gacha production is explicitly conditional on that individual's production selection, rather than a guaranteed result implied by a star rating.

## Coverage and limits

Covered: meat/fish/prime/mutton, hide/chitin/keratin/pelt/wool/polymer, wood/thatch/stone/flint/metal/crystal/obsidian/fiber/berries, oil/pearls/sap/cactus sap, rare flowers/mushrooms/Aberration mushrooms, fungal wood/silk/sulfur/salt/sand/paste/honey, three gems, element ore and Extinction crystallized saps.

Element Ore only has a verified node source; no optimal hand tool or tame is claimed. Rich Metal, Rich Oil, Cactus, Sandpile and gem node names have aliases where their relationship is supported. Generic decorative nodes, expansion-specific blood sap, some element variants and crop production remain outside this curated reference. The `Polymer` alias refers to harvestable organic polymer node contexts, not a claim that crafted polymer is harvested from all such sources.

Cross-edition text is used cautiously: explicit ASA wild babies, cactus consumption hydration, automatic Dung Beetle feces collection, red-gem Aberrant Ankylo radiation immunity and creature Harvest Only modes are preserved. Presence in a shared wiki gathering table does not guarantee the creature can be tamed on every current ASA map or without expansion access.

## Validation

The generator completed with 41 entries and 58 unique source URLs. JSON parsing, unique resource identifiers, collision-free normalized aliases, required fields, source domains, review dates and weight reduction bounds were checked. No UI/source files, build output, commit or deployment were performed in this delegated data task.
