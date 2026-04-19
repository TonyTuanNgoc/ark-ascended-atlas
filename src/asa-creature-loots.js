import { ASA_IMPORTED_CREATURES } from "./asa-creature-roster.js";

export const ASA_CREATURE_LOOT_IMPORT_VERSION = "2026-04-20-v1";

const itemEntry = (label, itemId) => ({
  label,
  itemId,
});

const appendUnique = (entries, nextEntry) => {
  if (!nextEntry?.label) return;
  const key = nextEntry.itemId || nextEntry.label.toLowerCase();
  if (entries.some((entry) => (entry.itemId || entry.label.toLowerCase()) === key)) return;
  entries.push(nextEntry);
};

const addItemsFromSet = (entries, creatureId, creatureSet, lootEntry) => {
  if (creatureSet.has(creatureId)) {
    appendUnique(entries, lootEntry);
  }
};

const NO_DEFAULT_GENERIC_LOOT_IDS = new Set([
  "attack-drone",
  "broodmother-lysrix",
  "defense-unit",
  "desert-titan",
  "dodo-wyvern",
  "dodorex",
  "dragon",
  "enforcer",
  "forest-titan",
  "hydra",
  "ice-titan",
  "king-titan",
  "lost-king",
  "lost-queen",
  "manticore",
  "mega-mek",
  "mek",
  "megapithecus",
  "minotaur",
  "natrix",
  "overseer",
  "rock-elemental",
  "rockwell",
  "scout",
  "seeker",
  "thanatos",
  "thodes",
]);

const RAW_FISH_MEAT_IDS = new Set([
  "anglerfish",
  "coelacanth",
  "dunkleosteus",
  "electrophorus",
  "helicoprion",
  "leedsichthys",
  "manta",
  "megalodon",
  "piranha",
  "sabertooth-salmon",
  "tusoteuthis",
  "xiphactinus",
]);

const CHITIN_IDS = new Set([
  "achatina",
  "ammonite",
  "araneo",
  "arthropluera",
  "cosmo",
  "dung-beetle",
  "eurypterid",
  "giant-bee",
  "glowbug",
  "jug-bug",
  "karkinos",
  "mantis",
  "meganeura",
  "pulmonoscorpius",
  "rhyniognatha",
  "titanomyrma",
  "trilobite",
]);

const KERATIN_IDS = new Set([
  "allosaurus",
  "ankylosaurus",
  "carbonemys",
  "carnotaurus",
  "deathworm",
  "doedicurus",
  "kentrosaurus",
  "mammoth",
  "managarmr",
  "pachyrhinosaurus",
  "sabertooth",
  "stegosaurus",
  "theri",
  "thorny-dragon",
  "thylacoleo",
  "titanoboa",
  "triceratops",
  "tusoteuthis",
  "woolly-rhino",
  "yutyrannus",
]);

const PELT_IDS = new Set([
  "castoroides",
  "dire-bear",
  "direwolf",
  "equus",
  "mammoth",
  "megaloceros",
  "megatherium",
  "otter",
  "ovis",
  "procoptodon",
  "woolly-rhino",
  "yutyrannus",
]);

const BLACK_PEARL_IDS = new Set([
  "ammonite",
  "deathworm",
  "eurypterid",
  "trilobite",
  "tusoteuthis",
]);

const ORGANIC_POLYMER_IDS = new Set([
  "hesperornis",
  "kairuku",
  "karkinos",
  "mantis",
]);

const UNIQUE_LOOT_BY_CREATURE_ID = {
  achatina: [itemEntry("Achatina Paste", "achatina-paste")],
  ammonite: [itemEntry("Ammonite Bile", "ammonite-bile")],
  anglerfish: [itemEntry("AnglerGel", "anglergel")],
  argentavis: [itemEntry("Argentavis Talon", "argentavis-talon")],
  basilisk: [itemEntry("Basilisk Scale", "basilisk-scale")],
  basilosaurus: [itemEntry("Basilosaurus Blubber", "basilosaurus-blubber")],
  carcharodontosaurus: [itemEntry("Giganotosaurus Heart", "giganotosaurus-heart")],
  ceratosaurus: [itemEntry("Cerato Venom Spine", "cerato-venom-spine")],
  cnidaria: [itemEntry("Bio Toxin", "bio-toxin")],
  deathworm: [
    itemEntry("Deathworm Horn", "deathworm-horn"),
    itemEntry("Leech Blood", "leech-blood"),
    itemEntry("AnglerGel", "anglergel"),
  ],
  gasbags: [itemEntry("Gasbags bladder", "gasbags-bladder")],
  giganotosaurus: [itemEntry("Giganotosaurus Heart", "giganotosaurus-heart")],
  lamprey: [itemEntry("Leech Blood", "leech-blood")],
  leech: [itemEntry("Leech Blood", "leech-blood")],
  megalania: [itemEntry("Megalania Toxin", "megalania-toxin")],
  megalodon: [itemEntry("Megalodon Tooth", "megalodon-tooth")],
  nameless: [itemEntry("Nameless Venom", "nameless-venom")],
  "rock-drake": [itemEntry("Rock Drake Feather", "rock-drake-feather")],
  "rock-elemental": [
    itemEntry("Hide", "hide"),
    itemEntry("Keratin", "keratin"),
    itemEntry("Oil", "oil"),
    itemEntry("Raw Meat", "raw-meat"),
    itemEntry("Stone", "stone"),
  ],
  sarco: [itemEntry("Sarcosuchus Skin", "sarcosuchus-skin")],
  seeker: [
    itemEntry("Berries", "berries"),
    itemEntry("Hide", "hide"),
    itemEntry("Oil", "oil"),
    itemEntry("Raw Meat", "raw-meat"),
  ],
  spino: [itemEntry("Spinosaurus Sail", "spinosaurus-sail")],
  thylacoleo: [itemEntry("Thylacoleo Hook-Claw", "thylacoleo-hook-claw")],
  titanoboa: [itemEntry("Titanoboa Venom", "titanoboa-venom")],
  tusoteuthis: [itemEntry("Tusoteuthis Tentacle", "tusoteuthis-tentacle")],
  "woolly-rhino": [itemEntry("Woolly Rhino Horn", "woolly-rhino-horn")],
  yutyrannus: [itemEntry("Yutyrannus Lungs", "yutyrannus-lungs")],
};

const SAUROPOD_IDS = new Set([
  "brontosaurus",
  "diplodocus",
  "dreadnoughtus",
  "titanosaur",
]);

const buildImportedLootEntries = (creatureId) => {
  const entries = [];

  (UNIQUE_LOOT_BY_CREATURE_ID[creatureId] || []).forEach((entry) => appendUnique(entries, entry));

  addItemsFromSet(entries, creatureId, SAUROPOD_IDS, itemEntry("Sauropod Vertebra", "sauropod-vertebra"));
  addItemsFromSet(entries, creatureId, ORGANIC_POLYMER_IDS, itemEntry("Organic Polymer", "organic-polymer"));
  addItemsFromSet(entries, creatureId, BLACK_PEARL_IDS, itemEntry("Black Pearl", "black-pearl"));
  addItemsFromSet(entries, creatureId, PELT_IDS, itemEntry("Pelt", "pelt"));
  addItemsFromSet(entries, creatureId, KERATIN_IDS, itemEntry("Keratin", "keratin"));
  addItemsFromSet(entries, creatureId, CHITIN_IDS, itemEntry("Chitin", "chitin"));
  addItemsFromSet(entries, creatureId, RAW_FISH_MEAT_IDS, itemEntry("Raw Fish Meat", "raw-fish-meat"));

  if (
    !NO_DEFAULT_GENERIC_LOOT_IDS.has(creatureId) &&
    !RAW_FISH_MEAT_IDS.has(creatureId) &&
    !CHITIN_IDS.has(creatureId) &&
    creatureId !== "cnidaria" &&
    creatureId !== "leech" &&
    creatureId !== "lamprey" &&
    creatureId !== "nameless"
  ) {
    appendUnique(entries, itemEntry("Hide", "hide"));
    appendUnique(entries, itemEntry("Raw Meat", "raw-meat"));
  }

  return entries;
};

export const ASA_IMPORTED_CREATURE_LOOTS = ASA_IMPORTED_CREATURES.reduce((output, creature) => {
  const lootEntries = buildImportedLootEntries(creature.id);
  if (!lootEntries.length) return output;

  output[creature.id] = {
    sourceLabel: "ARK Official Community Wiki",
    sourceUrl: "https://ark.wiki.gg/wiki/ARK_Wiki",
    loot: lootEntries.map((entry) => entry.label).join(" / "),
    lootEntries,
  };

  return output;
}, {});
