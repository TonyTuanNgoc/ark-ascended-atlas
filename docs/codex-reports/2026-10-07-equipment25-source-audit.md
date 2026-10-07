# Equipment 25 source audit

```json
{
  "items": 728,
  "primaryPages": {
    "cached-primary": 727,
    "source-parent-mismatch": 1
  },
  "recipes": {
    "asa-cache-wiki-crosschecked": 462,
    "no-infobox-recipe": 137,
    "wiki-reference-edition-review": 75,
    "asa-cache-reference": 7,
    "asa-cache-wiki-difference": 43,
    "wiki-multiple-variants-review": 3,
    "wiki-asa-explicit": 1
  },
  "stats": {
    "wiki-reference-edition-review": 720,
    "unresolved": 8
  },
  "withIngredients": 591,
  "withStats": 720,
  "statFacts": 4743,
  "withExplicitOutput": 30,
  "primaryRetrievedOnAuditDate": 728,
  "comparisonKinds": {
    "matching-ingredient-options-and-amounts": 462,
    "not-compared": 210,
    "secondary-wrong-frontier-item": 1,
    "selected-primary-chemistry-bench-batch": 3,
    "no-primary-ingredient-candidate": 6,
    "quantity-or-resource-difference": 43,
    "secondary-default-blueprint-not-player-engram": 1,
    "secondary-generic-hoversail-not-thalassian": 1,
    "parent-page-is-tek-bow": 1
  }
}
```

All 728 catalogue source URLs were acquired on 2026-10-07. This parser pass reuses that acquisition cache and records `primaryRetrievedAt`; page retrieval is not ASA game verification. Mixed Wiki numeric facts retain edition-review status. No absent recipe is automatically called uncraftable.

## Source identity and batch corrections

- Standard Water Reservoir now uses 30 Stone and 5 Cementing Paste in Inventory. Rejected secondary data points to Frontier `/Game/Packs/Frontier/.../WaterTank_Large` and Frontier image; its 500 Wood / 100 Ingot / 50 Paste formula belonged to the other reservoir. Current normal reservoir artwork is correct.
- Bee Hive is obtained by taming and converting a Giant Queen Bee. Raw blueprint-default resource costs are suppressed; `recipeKind=acquisition`, `acquisitionRequirements={Giant Bee:1}`.
- Absorbent Substrate uses the actual Chemistry Bench batch: 8 Black Pearl + 8 Sap + 8 Oil → 6.
- Mutagen uses 800 Mutagel → 6; Mutagel uses 4 Mutagen → 408. These are Chemistry Bench batches with `outputStatus=primary-batch-reference`; raw class defaults must not be displayed as a one-item primitive recipe.
- Tek Thalassian Hoversail uses 450 Hardened Steel Ingot, not the generic Genesis2 Hoversail's 450 Metal Ingot. Other primary reference ingredients are 20 Element / 100 Polymer / 200 Crystal / 50 Electronics.
- Cryofridge selected recipe matches explicit ASA section: 12 Crystal / 7 Electronics / 115 Metal Ingot / 30 Polymer.
- Cryopod uses explicit ASA 4 Polymer ingredients; station list remains mixed-edition review.
- Chemistry Bench electricity-only ASA catalogue claim is unverified: main Wiki page and Charge Battery page list gasoline plus power without explicit ASA scope. Purpose now says to confirm current-game fuel/power. Fabricator and Tek Replicator notes use explicitly ASA-scoped primary Generator/Tek Generator passages.
- Explosive Arrow Wiki URL redirects to Tek Bow: parent stats and recipe excluded; secondary arrow recipe remains unconfirmed.
- Numeric field lists preserve separators and edition labels, e.g. `Electricity; Charge Battery`. Alternative ingredients are compared by overlap plus equal quantity, removing first-option bias.

43 secondary/Wiki differences remain explicitly unconfirmed. Combined ASA structure variants were not overwritten with individual ASE structure prices. Per-item rejected formulas, source identities and remaining differences are recorded in the JSON audit.

PASS: 728 unique catalogue IDs; positive ingredient quantities; primary source hashes and dates; wrong Frontier reservoir excluded; Bee Hive acquisition has no fictional crafting costs; correct Chemistry Bench batch input/output pairs; Thalassian Hardened Steel material; no Tek Bow stats on arrow; Cryofridge ASA amounts; stat separators and edition markers.

No numeric stats invented for: Companion Bed, Fossil Pile, Linked Storage Box, Medical Stand, Spotlight, Stone Tree Platform, Plant Species Y, Explosive Arrow.

Schema: `items` keyed by `id`; ingredient dictionaries, stations, optional output/outputStatus, `stats` key/label/value/sourceURL/status, recipe/status/edition notes and source SHA/date. `secondaryIdentity` and `rejectedSecondaryRecipe` preserve identity evidence. `comparisonKind` distinguishes batch scales, item mismatch and unresolved quantity/resource differences. No Wiki article prose is packaged.
