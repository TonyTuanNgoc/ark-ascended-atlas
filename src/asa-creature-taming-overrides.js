export const ASA_CREATURE_TAMING_OVERRIDE_VERSION = "2026-04-20-methods";

const foodEntries = (...entries) =>
  entries
    .flat()
    .filter(Boolean)
    .map((entry) => {
      if (typeof entry === "string") {
        return {
          label: entry,
          itemId: "",
        };
      }

      return {
        label: String(entry.label || "").trim(),
        itemId: String(entry.itemId || "").trim(),
      };
    })
    .filter((entry) => entry.label || entry.itemId);

const knockout = (extras = {}) => ({
  tameMethod: "Knockout",
  tameMethodType: "simple",
  tameMethodDetail: "",
  ...extras,
});

const passive = (extras = {}) => ({
  tameMethod: "Passive",
  tameMethodType: "simple",
  tameMethodDetail: "",
  ...extras,
});

const special = (detail, extras = {}) => ({
  tameMethod: "Special Method",
  tameMethodType: "special",
  tameMethodDetail: detail,
  ...extras,
});

export const ASA_IMPORTED_CREATURE_TAMING_OVERRIDES = {
  araneo: passive(),
  arthropluera: passive(),
  archelon: passive({
    sourceLabel: "ARK Official Community Wiki",
    sourceUrl: "https://ark.wiki.gg/wiki/Archelon",
    tameFood: "Superior Kibble / Bio Toxin",
    tameFoodEntries: foodEntries(
      { label: "Superior Kibble", itemId: "superior-kibble" },
      { label: "Bio Toxin", itemId: "bio-toxin" }
    ),
  }),
  basilosaurus: passive(),
  bulbdog: passive({
    sourceLabel: "ARK Official Community Wiki",
    sourceUrl: "https://ark.wiki.gg/wiki/Taming",
    tameFood:
      "Plant Species Z Seed / Aquatic Mushroom / Cooked Lamb Chop / Cooked Prime Meat / Prime Meat Jerky",
    tameFoodEntries: foodEntries(
      { label: "Plant Species Z Seed", itemId: "plant-species-z-seed" },
      { label: "Aquatic Mushroom", itemId: "aquatic-mushroom" },
      { label: "Cooked Lamb Chop", itemId: "cooked-lamb-chop" },
      { label: "Cooked Prime Meat", itemId: "cooked-prime-meat" },
      { label: "Prime Meat Jerky", itemId: "prime-meat-jerky" }
    ),
  }),
  chalicotherium: passive({
    sourceLabel: "ARK Official Community Wiki",
    sourceUrl: "https://ark.wiki.gg/wiki/Taming",
    tameFood: "Beer Jar / Stimberry",
    tameFoodEntries: foodEntries(
      { label: "Beer Jar", itemId: "beer-jar" },
      { label: "Stimberry", itemId: "stimberry" }
    ),
  }),
  deinosuchus: passive({
    sourceLabel: "ARK Official Community Wiki",
    sourceUrl: "https://ark.wiki.gg/wiki/Deinosuchus",
    tameFood:
      "Superior Kibble / Raw Mutton / Cooked Lamb Chop / Raw Prime Meat / Cooked Prime Meat",
    tameFoodEntries: foodEntries(
      { label: "Superior Kibble", itemId: "superior-kibble" },
      { label: "Raw Mutton", itemId: "raw-mutton" },
      { label: "Cooked Lamb Chop", itemId: "cooked-lamb-chop" },
      { label: "Raw Prime Meat", itemId: "raw-prime-meat" },
      { label: "Cooked Prime Meat", itemId: "cooked-prime-meat" }
    ),
  }),
  deinotherium: passive({
    sourceLabel: "ARK Official Community Wiki",
    sourceUrl: "https://ark.wiki.gg/wiki/Deinotherium",
    tameFood: "Beer Jar",
    tameFoodEntries: foodEntries({ label: "Beer Jar", itemId: "beer-jar" }),
  }),
  "dung-beetle": passive({
    sourceLabel: "ARK Official Community Wiki",
    sourceUrl: "https://ark.wiki.gg/wiki/Dung_Beetle",
    tameFood:
      "Large Animal Feces / Medium Animal Feces / Small Animal Feces / Human Feces / Spoiled Meat",
    tameFoodEntries: foodEntries(
      { label: "Large Animal Feces", itemId: "large-animal-feces" },
      { label: "Medium Animal Feces", itemId: "medium-animal-feces" },
      { label: "Small Animal Feces", itemId: "small-animal-feces" },
      { label: "Human Feces", itemId: "human-feces" },
      { label: "Spoiled Meat", itemId: "spoiled-meat" }
    ),
  }),
  featherlight: passive({
    sourceLabel: "ARK Official Community Wiki",
    sourceUrl: "https://ark.wiki.gg/wiki/Taming",
    tameFood: "Plant Species Z Seed / Auric Mushroom",
    tameFoodEntries: foodEntries(
      { label: "Plant Species Z Seed", itemId: "plant-species-z-seed" },
      { label: "Auric Mushroom", itemId: "auric-mushroom" }
    ),
  }),
  gigantopithecus: passive(),
  glowtail: passive({
    sourceLabel: "ARK Official Community Wiki",
    sourceUrl: "https://ark.wiki.gg/wiki/Taming",
    tameFood: "Plant Species Z Seed / Ascerbic Mushroom",
    tameFoodEntries: foodEntries(
      { label: "Plant Species Z Seed", itemId: "plant-species-z-seed" },
      { label: "Ascerbic Mushroom", itemId: "ascerbic-mushroom" }
    ),
  }),
  ichthyosaurus: passive(),
  lystrosaurus: passive(),
  manta: passive({
    sourceLabel: "ARK Status",
    sourceUrl: "https://arkstatus.com/taming/manta",
    tameFood: "AnglerGel",
    tameFoodEntries: foodEntries({ label: "AnglerGel", itemId: "anglergel" }),
  }),
  mantis: passive({
    sourceLabel: "ARK Status",
    sourceUrl: "https://arkstatus.com/taming/mantis",
    tameFood: "Deathworm Horn",
    tameFoodEntries: foodEntries({ label: "Deathworm Horn", itemId: "deathworm-horn" }),
  }),
  moschops: passive(),
  onyc: passive({
    sourceLabel: "ARK Official Community Wiki",
    sourceUrl: "https://ark.wiki.gg/wiki/Taming",
    tameFood: "Raw Meat / Raw Fish Meat",
    tameFoodEntries: foodEntries(
      { label: "Raw Meat", itemId: "raw-meat" },
      { label: "Raw Fish Meat", itemId: "raw-fish-meat" }
    ),
  }),
  ovis: passive({
    sourceLabel: "ARK Status",
    sourceUrl: "https://arkstatus.com/taming/ovis",
    tameFood: "Sweet Vegetable Cake",
    tameFoodEntries: foodEntries({
      label: "Sweet Vegetable Cake",
      itemId: "item-veggie-cake",
    }),
  }),
  shinehorn: passive({
    sourceLabel: "ARK Official Community Wiki",
    sourceUrl: "https://ark.wiki.gg/wiki/Taming",
    tameFood: "Plant Species Z Seed / Aggeravic Mushroom / Sweet Vegetable Cake",
    tameFoodEntries: foodEntries(
      { label: "Plant Species Z Seed", itemId: "plant-species-z-seed" },
      { label: "Aggeravic Mushroom", itemId: "aggeravic-mushroom" },
      { label: "Sweet Vegetable Cake", itemId: "item-veggie-cake" }
    ),
  }),
  vulture: passive({
    sourceLabel: "ARK Official Community Wiki",
    sourceUrl: "https://ark.wiki.gg/wiki/Taming",
    tameFood: "Spoiled Meat / Raw Meat",
    tameFoodEntries: foodEntries(
      { label: "Spoiled Meat", itemId: "spoiled-meat" },
      { label: "Raw Meat", itemId: "raw-meat" }
    ),
  }),
  andrewsarchus: special(
    "Distract it with Giant Bee Honey, mount it, and keep your momentum during the rodeo phase.",
    {
      sourceLabel: "ARK Official Community Wiki",
      sourceUrl: "https://ark.wiki.gg/wiki/Taming",
      tameFood: "Giant Bee Honey",
      tameFoodEntries: foodEntries({ label: "Giant Bee Honey", itemId: "giant-bee-honey" }),
    }
  ),
  aureliax: special(
    "Trigger the egg-defense event, defend the egg through the waves, then claim it when the defense ends.",
    {
      sourceLabel: "ARK Official Community Wiki",
      sourceUrl: "https://ark.wiki.gg/wiki/Taming",
    }
  ),
  basilisk: special(
    "Drop fertilized eggs on the ground for it to eat until the tame completes.",
    {
      sourceLabel: "ARK Official Community Wiki",
      sourceUrl: "https://ark.wiki.gg/wiki/Taming",
      tameFood:
        "Fertilized Rock Drake Egg / Wyvern Egg / Voidwyrm Egg / Fertilized Magmasaur Egg",
      tameFoodEntries: foodEntries(
        { label: "Fertilized Rock Drake Egg", itemId: "rock-drake-egg" },
        "Wyvern Egg",
        "Voidwyrm Egg",
        "Fertilized Magmasaur Egg"
      ),
    }
  ),
  bloodstalker: special(
    "Let it latch onto a survivor or tame carrying Blood Packs; the Blood Packs are consumed from the latched victim's inventory.",
    {
      sourceLabel: "ARK Official Community Wiki",
      sourceUrl: "https://ark.wiki.gg/wiki/Taming",
      tameFood: "Blood Pack",
      tameFoodEntries: foodEntries({ label: "Blood Pack", itemId: "blood-pack" }),
    }
  ),
  carcharodontosaurus: special(
    "Drag fresh kills to it to build trust, then ride it and secure kills without letting it take return damage.",
    {
      sourceLabel: "ARK Official Community Wiki",
      sourceUrl: "https://ark.wiki.gg/wiki/Carcharodontosaurus",
    }
  ),
  ceratosaurus: special(
    "Use Hemogoblin Cocktail on one of your own tames so the Ceratosaurus becomes blood drunk, then feed it after the setup window opens.",
    {
      sourceLabel: "ARK Official Community Wiki",
      sourceUrl: "https://ark.wiki.gg/wiki/Ceratosaurus",
      tameFood: "Extraordinary Kibble",
      tameFoodEntries: foodEntries({
        label: "Extraordinary Kibble",
        itemId: "extraordinary-kibble",
      }),
    }
  ),
  cosmo: special(
    "Carry Chitin so it notices you, then feed it while it is willing to approach.",
    {
      sourceLabel: "ARK Official Community Wiki",
      sourceUrl: "https://ark.wiki.gg/wiki/Taming",
      tameFood: "Plant Species Z Seed / Chitin",
      tameFoodEntries: foodEntries(
        { label: "Plant Species Z Seed", itemId: "plant-species-z-seed" },
        { label: "Chitin", itemId: "chitin" }
      ),
    }
  ),
  desmodus: special(
    "Let it grab a survivor or tame carrying Blood Packs so the Blood Packs can be drained during the latch.",
    {
      sourceLabel: "ARK Official Community Wiki",
      sourceUrl: "https://ark.wiki.gg/wiki/Desmodus",
      tameFood: "Blood Pack",
      tameFoodEntries: foodEntries({ label: "Blood Pack", itemId: "blood-pack" }),
    }
  ),
  equus: special(
    "Hand-feed it, mount it, then feed again each time it tries to buck you off.",
    {
      sourceLabel: "ARK Official Community Wiki",
      sourceUrl: "https://ark.wiki.gg/wiki/Equus",
      tameFood: "Simple Kibble / Rockarrot / Crops / Sweet Vegetable Cake",
      tameFoodEntries: foodEntries(
        { label: "Simple Kibble", itemId: "simple-kibble" },
        { label: "Rockarrot", itemId: "rockarrot" },
        { label: "Crops", itemId: "crops" },
        { label: "Sweet Vegetable Cake", itemId: "item-veggie-cake" }
      ),
    }
  ),
  gacha: special(
    "Drop items for it to eat; structure stacks are the preferred offering for efficient taming.",
    {
      sourceLabel: "ARK Official Community Wiki",
      sourceUrl: "https://ark.wiki.gg/wiki/Taming",
      tameFood: "Snow Owl Pellet / Element / Other Items / Element Ore / Ammunition",
      tameFoodEntries: foodEntries(
        { label: "Snow Owl Pellet", itemId: "snow-owl-pellet" },
        { label: "Element", itemId: "element" },
        "Other Items",
        { label: "Element Ore", itemId: "element-ore" },
        "Ammunition"
      ),
    }
  ),
  gigantoraptor: special(
    "Distract the adult at the nest, then complete the baby interaction correctly until it accepts you.",
    {
      sourceLabel: "ARK Official Community Wiki",
      sourceUrl: "https://ark.wiki.gg/wiki/Taming",
    }
  ),
  hesperornis: special(
    "Drag Dead Fish to it and feed by hand; it will not tame from standard inventory feeding.",
    {
      sourceLabel: "ARK Official Community Wiki",
      sourceUrl: "https://ark.wiki.gg/wiki/Taming",
      tameFood: "Dead Fish",
      tameFoodEntries: foodEntries({ label: "Dead Fish", itemId: "dead-fish" }),
    }
  ),
  hyaenodon: special(
    "Crouch-walk behind it and pet it without letting it detect or aggro on you.",
    {
      sourceLabel: "ARK Official Community Wiki",
      sourceUrl: "https://ark.wiki.gg/wiki/Taming",
    }
  ),
  liopleurodon: special(
    "Hand-feed Giant Bee Honey; the tame is temporary even after it succeeds.",
    {
      sourceLabel: "ARK Official Community Wiki",
      sourceUrl: "https://ark.wiki.gg/wiki/Taming",
      tameFood: "Giant Bee Honey",
      tameFoodEntries: foodEntries({ label: "Giant Bee Honey", itemId: "giant-bee-honey" }),
    }
  ),
  magmasaur: special(
    "Steal an egg from a Magmasaur nest and raise it from birth.",
    {
      sourceLabel: "ARK Official Community Wiki",
      sourceUrl: "https://ark.wiki.gg/wiki/Taming",
    }
  ),
  malwyn: special(
    "Feed a follower Veilwyn with 100% adventure effect using a Corrupted Vulpite.",
    {
      sourceLabel: "ARK Official Community Wiki",
      sourceUrl: "https://ark.wiki.gg/wiki/Taming",
    }
  ),
  oasisaur: special(
    "Place a Death Essence in its oasis and finish the defense mini-game without letting the baby clone die.",
    {
      sourceLabel: "ARK Official Community Wiki",
      sourceUrl: "https://ark.wiki.gg/wiki/Oasisaur",
    }
  ),
  otter: special(
    "Drag Dead Fish to it and feed by hand.",
    {
      sourceLabel: "ARK Official Community Wiki",
      sourceUrl: "https://ark.wiki.gg/wiki/Taming",
      tameFood: "Dead Fish",
      tameFoodEntries: foodEntries({ label: "Dead Fish", itemId: "dead-fish" }),
    }
  ),
  pegomastax: special(
    "Keep Berries in the far-right hotbar slot and let it steal them repeatedly.",
    {
      sourceLabel: "ARK Official Community Wiki",
      sourceUrl: "https://ark.wiki.gg/wiki/Taming",
      tameFood: "Berries",
      tameFoodEntries: foodEntries({ label: "Berries", itemId: "berries" }),
    }
  ),
  phoenix: special(
    "It can only be tamed during a Heat Wave by keeping it on fire with a Fire Wyvern or Flamethrower.",
    {
      sourceLabel: "ARK Official Community Wiki",
      sourceUrl: "https://ark.wiki.gg/wiki/Taming",
    }
  ),
  pyromane: special(
    "Douse it in water, weaken it below half health, mount it, then absorb flames from nearby burning targets until the tame fills.",
    {
      sourceLabel: "ARK Official Community Wiki",
      sourceUrl: "https://ark.wiki.gg/wiki/Pyromane",
    }
  ),
  rhyniognatha: special(
    "Use male pheromone and a prepared host tame for impregnation, then raise the resulting baby.",
    {
      sourceLabel: "ARK Official Community Wiki",
      sourceUrl: "https://ark.wiki.gg/wiki/Taming",
    }
  ),
  "rock-drake": special(
    "Steal a Rock Drake egg and raise it from birth.",
    {
      sourceLabel: "ARK Official Community Wiki",
      sourceUrl: "https://ark.wiki.gg/wiki/Taming",
    }
  ),
  "roll-rat": special(
    "Throw Giant Bee Honey while it is buried so it comes up to eat the offering.",
    {
      sourceLabel: "ARK Official Community Wiki",
      sourceUrl: "https://ark.wiki.gg/wiki/Taming",
      tameFood: "Giant Bee Honey",
      tameFoodEntries: foodEntries({ label: "Giant Bee Honey", itemId: "giant-bee-honey" }),
    }
  ),
  shastasaurus: special(
    "Lead it to the surface with tame Ichthyosaurus, clear the leeches with a sickle, then feed it at the mouth before the next cycle.",
    {
      sourceLabel: "ARK Official Community Wiki",
      sourceUrl: "https://ark.wiki.gg/wiki/Shastasaurus",
      tameFood:
        "Extraordinary Kibble / Raw Prime Fish Meat / Cooked Prime Fish Meat / Raw Fish Meat / Cooked Fish Meat",
      tameFoodEntries: foodEntries(
        { label: "Extraordinary Kibble", itemId: "extraordinary-kibble" },
        { label: "Raw Prime Fish Meat", itemId: "raw-prime-fish-meat" },
        { label: "Cooked Prime Fish Meat", itemId: "cooked-prime-fish-meat" },
        { label: "Raw Fish Meat", itemId: "raw-fish-meat" },
        { label: "Cooked Fish Meat", itemId: "cooked-fish-meat" }
      ),
    }
  ),
  solwyn: special(
    "Feed a follower Veilwyn with 100% adventure effect using a Pristine Vulpite.",
    {
      sourceLabel: "ARK Official Community Wiki",
      sourceUrl: "https://ark.wiki.gg/wiki/Taming",
    }
  ),
  titanoboa: special(
    "Drop fertilized eggs on the ground for it to eat; it will not eat from inventory.",
    {
      sourceLabel: "ARK Official Community Wiki",
      sourceUrl: "https://ark.wiki.gg/wiki/Taming",
      tameFood: "Fertilized Egg",
      tameFoodEntries: foodEntries("Fertilized Egg"),
    }
  ),
  unicorn: special(
    "Same process as Equus: hand-feed, mount it, then calm it with food whenever it bucks.",
    {
      sourceLabel: "ARK Official Community Wiki",
      sourceUrl: "https://ark.wiki.gg/wiki/Equus",
      tameFood: "Simple Kibble / Rockarrot / Crops / Sweet Vegetable Cake",
      tameFoodEntries: foodEntries(
        { label: "Simple Kibble", itemId: "simple-kibble" },
        { label: "Rockarrot", itemId: "rockarrot" },
        { label: "Crops", itemId: "crops" },
        { label: "Sweet Vegetable Cake", itemId: "item-veggie-cake" }
      ),
    }
  ),
  wyvern: special(
    "Steal a Wyvern egg from a trench or nest and raise it from birth.",
    {
      sourceLabel: "ARK Official Community Wiki",
      sourceUrl: "https://ark.wiki.gg/wiki/Taming",
    }
  ),
  "yi-ling": special(
    "Disorient it during a dive with Plant Species Z Fruit, feed narcotic-related items until it drops, then continue like a knockout tame.",
    {
      sourceLabel: "ARK Official Community Wiki",
      sourceUrl: "https://ark.wiki.gg/wiki/Taming",
    }
  ),
  bison: knockout({
    sourceLabel: "ARK Official Community Wiki",
    sourceUrl: "https://ark.wiki.gg/wiki/Bison",
    tameFood: "Superior Kibble / Crops / Mejoberry / Berries",
    tameFoodEntries: foodEntries(
      { label: "Superior Kibble", itemId: "superior-kibble" },
      { label: "Crops", itemId: "crops" },
      { label: "Mejoberry", itemId: "mejoberry" },
      { label: "Berries", itemId: "berries" }
    ),
  }),
  compy: knockout({
    sourceLabel: "ARK Official Community Wiki",
    sourceUrl: "https://ark.wiki.gg/wiki/Compy",
    tameFood: "Raw Mutton / Raw Prime Meat / Raw Prime Fish Meat",
    tameFoodEntries: foodEntries(
      { label: "Raw Mutton", itemId: "raw-mutton" },
      { label: "Raw Prime Meat", itemId: "raw-prime-meat" },
      { label: "Raw Prime Fish Meat", itemId: "raw-prime-fish-meat" }
    ),
  }),
  cryolophosaurus: knockout({
    sourceLabel: "ARK Official Community Wiki",
    sourceUrl: "https://ark.wiki.gg/wiki/Cryolophosaurus",
    tameFood:
      "Exceptional Kibble / Raw Mutton / Cooked Lamb Chop / Raw Prime Meat / Cooked Prime Meat",
    tameFoodEntries: foodEntries(
      { label: "Exceptional Kibble", itemId: "exceptional-kibble" },
      { label: "Raw Mutton", itemId: "raw-mutton" },
      { label: "Cooked Lamb Chop", itemId: "cooked-lamb-chop" },
      { label: "Raw Prime Meat", itemId: "raw-prime-meat" },
      { label: "Cooked Prime Meat", itemId: "cooked-prime-meat" }
    ),
  }),
  dilophosaur: knockout({
    sourceLabel: "ARK Official Community Wiki",
    sourceUrl: "https://ark.wiki.gg/wiki/Dilophosaur",
    tameFood:
      "Basic Kibble / Raw Mutton / Raw Prime Meat / Cooked Lamb Chop / Cooked Prime Meat",
    tameFoodEntries: foodEntries(
      { label: "Basic Kibble", itemId: "basic-kibble" },
      { label: "Raw Mutton", itemId: "raw-mutton" },
      { label: "Raw Prime Meat", itemId: "raw-prime-meat" },
      { label: "Cooked Lamb Chop", itemId: "cooked-lamb-chop" },
      { label: "Cooked Prime Meat", itemId: "cooked-prime-meat" }
    ),
  }),
  "dire-bear": knockout(),
  gasbags: knockout({
    sourceLabel: "ARK Official Community Wiki",
    sourceUrl: "https://ark.wiki.gg/wiki/Gasbags",
    tameFood: "Superior Kibble / Crops / Mejoberry / Berries",
    tameFoodEntries: foodEntries(
      { label: "Superior Kibble", itemId: "superior-kibble" },
      { label: "Crops", itemId: "crops" },
      { label: "Mejoberry", itemId: "mejoberry" },
      { label: "Berries", itemId: "berries" }
    ),
  }),
  griffin: knockout(),
  maeguana: knockout({
    sourceLabel: "ARK Official Community Wiki",
    sourceUrl: "https://ark.wiki.gg/wiki/Maeguana",
    tameFood: "Basic Kibble",
    tameFoodEntries: foodEntries({ label: "Basic Kibble", itemId: "basic-kibble" }),
  }),
  pachy: knockout({
    sourceLabel: "ARK Official Community Wiki",
    sourceUrl: "https://ark.wiki.gg/wiki/Pachy",
    tameFood: "Simple Kibble / Crops / Mejoberry / Berries",
    tameFoodEntries: foodEntries(
      { label: "Simple Kibble", itemId: "simple-kibble" },
      { label: "Crops", itemId: "crops" },
      { label: "Mejoberry", itemId: "mejoberry" },
      { label: "Berries", itemId: "berries" }
    ),
  }),
  parasaur: knockout({
    sourceLabel: "ARK Official Community Wiki",
    sourceUrl: "https://ark.wiki.gg/wiki/Parasaur",
    tameFood: "Basic Kibble / Crops / Mejoberry / Berries",
    tameFoodEntries: foodEntries(
      { label: "Basic Kibble", itemId: "basic-kibble" },
      { label: "Crops", itemId: "crops" },
      { label: "Mejoberry", itemId: "mejoberry" },
      { label: "Berries", itemId: "berries" }
    ),
  }),
  plesiosaur: knockout(),
  quetzal: knockout({
    sourceLabel: "ARK Official Community Wiki",
    sourceUrl: "https://ark.wiki.gg/wiki/Quetzal",
    tameFood:
      "Exceptional Kibble / Raw Mutton / Raw Prime Meat / Cooked Lamb Chop / Cooked Prime Meat",
    tameFoodEntries: foodEntries(
      { label: "Exceptional Kibble", itemId: "exceptional-kibble" },
      { label: "Raw Mutton", itemId: "raw-mutton" },
      { label: "Raw Prime Meat", itemId: "raw-prime-meat" },
      { label: "Cooked Lamb Chop", itemId: "cooked-lamb-chop" },
      { label: "Cooked Prime Meat", itemId: "cooked-prime-meat" }
    ),
  }),
  sarco: knockout({
    sourceLabel: "ARK Official Community Wiki",
    sourceUrl: "https://ark.wiki.gg/wiki/Sarco",
    tameFood:
      "Regular Kibble / Raw Prime Fish Meat / Raw Mutton / Raw Prime Meat / Cooked Lamb Chop",
    tameFoodEntries: foodEntries(
      { label: "Regular Kibble", itemId: "regular-kibble" },
      { label: "Raw Prime Fish Meat", itemId: "raw-prime-fish-meat" },
      { label: "Raw Mutton", itemId: "raw-mutton" },
      { label: "Raw Prime Meat", itemId: "raw-prime-meat" },
      { label: "Cooked Lamb Chop", itemId: "cooked-lamb-chop" }
    ),
  }),
  spino: knockout(),
  theri: knockout({
    sourceLabel: "ARK Official Community Wiki",
    sourceUrl: "https://ark.wiki.gg/wiki/Therizinosaur",
    tameFood: "Exceptional Kibble / Crops / Mejoberry / Berries",
    tameFoodEntries: foodEntries(
      { label: "Exceptional Kibble", itemId: "exceptional-kibble" },
      { label: "Crops", itemId: "crops" },
      { label: "Mejoberry", itemId: "mejoberry" },
      { label: "Berries", itemId: "berries" }
    ),
  }),
  xiphactinus: knockout({
    sourceLabel: "ARK Official Community Wiki",
    sourceUrl: "https://ark.wiki.gg/wiki/Xiphactinus",
    tameFood:
      "Superior Kibble / Raw Mutton / Cooked Lamb Chop / Raw Prime Meat / Cooked Prime Meat",
    tameFoodEntries: foodEntries(
      { label: "Superior Kibble", itemId: "superior-kibble" },
      { label: "Raw Mutton", itemId: "raw-mutton" },
      { label: "Cooked Lamb Chop", itemId: "cooked-lamb-chop" },
      { label: "Raw Prime Meat", itemId: "raw-prime-meat" },
      { label: "Cooked Prime Meat", itemId: "cooked-prime-meat" }
    ),
  }),
};
