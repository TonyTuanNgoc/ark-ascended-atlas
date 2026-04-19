import {
  buildImportedCreatureMedia,
  DINO_IMPORT_NAME_ALIASES,
  DINO_PRACTICAL_DEFAULTS,
  ENTITY_TYPES,
  ITEM_FIELD_DEFAULTS,
  ITEM_IMPORT_NAME_ALIASES,
} from "./data.js";
import {
  ASA_CREATURE_IMPORT_VERSION,
  ASA_IMPORTED_CREATURES,
  ASA_IMPORTED_MAP_CREATURE_IDS,
} from "./asa-creature-roster.js";
import {
  ASA_IMPORTED_ITEMS,
  ASA_ITEM_IMPORT_VERSION,
} from "./asa-items-roster.js";
import {
  loadCloudAtlasData,
  removeAtlasEntityMediaFromCloud,
  saveAtlasEntityMediaToCloud,
  saveAtlasMetaToCloud,
  saveAtlasEntityToCloud,
} from "./cloud-atlas.js";
import { getFirebaseServices } from "./firebase-client.js";
import {
  findEntity,
  normalizeAtlasState as normalizeAtlasStateFromStore,
  loadState,
  resetState,
  saveState,
  STORAGE_KEY,
  updateEntity,
  updateSetting,
  upsertEntity,
} from "./store.js";

const appRoot = document.querySelector("#app");
const adminDrawer = document.querySelector("#adminDrawer");
const modalRoot = document.querySelector("#modalRoot");
const adminToggleButton = document.querySelector("#adminToggle");
const filePicker = document.querySelector("#imageFilePicker");
const stateFilePicker = document.querySelector("#atlasStateFilePicker");
let lastSectionRouteScrollKey = "";

const MAP_LINK_FIELDS = {
  bosses: "bossIds",
  dinos: "tameIds",
  resources: "resourceIds",
  artifacts: "artifactIds",
  tributeItems: "tributeIds",
  baseSpots: "baseSpotIds",
  galleryMedia: "galleryIds",
  references: "sourceIds",
  knowledgeArticles: "knowledgeArticleIds",
};

const MAP_SECTION_DEFS = {
  bosses: {
    key: "bosses",
    title: "Bosses",
    subtitle: "Map-critical battle and prep entries.",
    description: "Open map-linked bosses with dedicated planning tools and direct actions.",
    collectionKey: "bosses",
    linkField: "bossIds",
    supportsFilters: false,
    supportsSearch: false,
    previewLabel: "Bosses",
  },
  dinos: {
    key: "dinos",
    title: "Key Creatures",
    subtitle: "Library-style creature matrix tied to this map.",
    description: "Review, link, and tune the creature stack used for this map.",
    collectionKey: "dinos",
    linkField: "tameIds",
    supportsFilters: true,
    supportsSearch: true,
    supportsLibrary: true,
    previewLabel: "Creatures",
  },
  resources: {
    key: "resources",
    title: "Resources",
    subtitle: "Efficient movement routes and utility resources.",
    description: "Operational route notes and risk markers for map logistics.",
    collectionKey: "resources",
    linkField: "resourceIds",
    supportsFilters: false,
    supportsSearch: true,
    previewLabel: "Resources",
  },
  artifacts: {
    key: "artifacts",
    title: "Artifacts & Caves",
    subtitle: "Artifact routing and cave pressure map.",
    description: "Track cave complexity, artifact pull, and boss relevance.",
    collectionKey: "artifacts",
    linkField: "artifactIds",
    supportsFilters: false,
    supportsSearch: true,
    previewLabel: "Artifacts",
  },
  tributeItems: {
    key: "tributeItems",
    title: "Tribute Items",
    subtitle: "Tribute capture targets for map fights.",
    description: "Source and quantity expectations for tribute execution.",
    collectionKey: "tributeItems",
    linkField: "tributeIds",
    supportsFilters: false,
    supportsSearch: true,
    previewLabel: "Tributes",
  },
  baseSpots: {
    key: "baseSpots",
    title: "Base Spots",
    subtitle: "Operational base nodes and stationing options.",
    description: "Manage strong and safe base positions across this map.",
    collectionKey: "baseSpots",
    linkField: "baseSpotIds",
    supportsFilters: false,
    supportsSearch: true,
    previewLabel: "Base spots",
  },
  progression: {
    key: "progression",
    title: "Progression",
    subtitle: "Phase board for map sequencing and readiness gates.",
    description: "Map-driven progression timeline and transition checkpoints.",
    supportsFilters: false,
    supportsSearch: false,
    previewLabel: "Phases",
  },
  galleryMedia: {
    key: "galleryMedia",
    title: "Gallery",
    subtitle: "Visual references and terrain capture for planning.",
    description: "Open a focused media board without leaving map workflow.",
    collectionKey: "galleryMedia",
    linkField: "galleryIds",
    supportsFilters: false,
    supportsSearch: false,
    previewLabel: "Gallery assets",
  },
  references: {
    key: "references",
    title: "Sources",
    subtitle: "Validated external references and notes.",
    description: "Source list for route logic, timing, and lore confirmations.",
    collectionKey: "references",
    linkField: "sourceIds",
    supportsFilters: false,
    supportsSearch: true,
    previewLabel: "Sources",
  },
};

const MAP_SECTION_ORDER = [
  "bosses",
  "dinos",
  "resources",
  "artifacts",
  "tributeItems",
  "baseSpots",
  "progression",
  "galleryMedia",
  "references",
];

const MAP_PROGRESS_PHASES = [
  "Early Game",
  "Mid Game",
  "Industrial / Tech Transition",
  "Boss Prep",
  "Endgame / Ascension",
];

const CREATURE_STAGE_FILTERS = ["early", "mid", "endgame"];
const CREATURE_ROLE_FILTERS = ["utility", "boss", "cave", "flyer", "transport", "breeder"];
const CREATURE_DIFFICULTY_FILTERS = ["low", "medium", "high"];
const DINO_TAME_METHOD_TYPES = ["empty", "simple", "special"];
const ITEM_LIBRARY_SORT_OPTIONS = [
  { value: "name", label: "Name" },
  { value: "group", label: "Official Group" },
  { value: "category", label: "Official Category" },
  { value: "subcategory", label: "Official Subcategory" },
  { value: "dlc", label: "DLC" },
];
const HOME_SECTION_LINKS = [
  { id: "home", label: "Home", href: "#/" },
  { id: "maps", label: "Maps", href: "#/maps" },
  { id: "creatures", label: "Creatures", href: "#/creatures" },
  { id: "resources", label: "Items", href: "#/resources" },
  { id: "bosses", label: "Bosses", href: "#/bosses" },
  { id: "tames", label: "Tames", href: "#/tames" },
];
const LIBRARY_SECTION_LINKS = [
  { id: "home", label: "Back Home", href: "#/" },
  { id: "creatures", label: "Creatures", href: "#/creatures" },
  { id: "resources", label: "Items", href: "#/resources" },
];

const toArray = (value) => (Array.isArray(value) ? value : []);
const toArrayByObject = (value) =>
  toArray(value).filter((entry) => entry && typeof entry === "object");

const toTextArray = (value) => {
  if (Array.isArray(value)) {
    return value
      .map((entry) =>
        entry == null ? "" :
          typeof entry === "string"
            ? entry
            : typeof entry === "number" || typeof entry === "boolean"
            ? String(entry)
            : typeof entry === "object" && entry.label
            ? String(entry.label)
            : String(entry).trim()
      )
      .map((entry) => entry.trim())
      .filter(Boolean);
  }

  if (typeof value === "string") {
    return value
      .split(",")
      .map((entry) => entry.trim())
      .filter(Boolean);
  }

  return [];
};

const toTextList = (value, separator = ", ", fallback = "") => {
  const items = toTextArray(value);
  return items.length ? items.join(separator) : fallback;
};

function normalizeDinoPracticalFields(dino = {}) {
  const tameFood = String(dino.tameFood || "");
  const tameMethod = String(dino.tameMethod || "").trim();
  const tameMethodDetail = String(dino.tameMethodDetail || "").trim();
  const loot = String(dino.loot || "").trim();
  const explicitType = String(dino.tameMethodType || "").trim().toLowerCase();

  let tameMethodType = DINO_TAME_METHOD_TYPES.includes(explicitType)
    ? explicitType
    : "";

  if (!tameMethodType) {
    if (tameMethodDetail) {
      tameMethodType = "special";
    } else if (tameMethod) {
      tameMethodType = "simple";
    } else {
      tameMethodType = DINO_PRACTICAL_DEFAULTS.tameMethodType;
    }
  }

  return {
    tameFood,
    tameMethod,
    tameMethodType,
    tameMethodDetail,
    loot,
  };
}

function normalizeItemFields(item = {}) {
  const officialListGroup = String(
    item.officialListGroup || ITEM_FIELD_DEFAULTS.officialListGroup || ""
  ).trim();
  const officialIdCategory = String(
    item.officialIdCategory || officialListGroup || ITEM_FIELD_DEFAULTS.officialIdCategory || ""
  ).trim();
  const officialSubcategory = String(
    item.officialSubcategory || ITEM_FIELD_DEFAULTS.officialSubcategory || ""
  ).trim();
  const dlc = String(item.dlc || ITEM_FIELD_DEFAULTS.dlc || "").trim();
  const notes = String(item.notes || ITEM_FIELD_DEFAULTS.notes || "").trim();
  const practicalNote = String(
    item.practicalNote || item.shortDescription || ITEM_FIELD_DEFAULTS.practicalNote || ""
  ).trim();

  return {
    officialListGroup,
    officialIdCategory,
    officialSubcategory,
    dlc,
    isLiveASA:
      item.isLiveASA === true ||
      String(item.isLiveASA || ITEM_FIELD_DEFAULTS.isLiveASA || "").toLowerCase() === "true",
    isObtainable:
      item.isObtainable === true ||
      String(item.isObtainable ?? ITEM_FIELD_DEFAULTS.isObtainable).toLowerCase() === "true",
    notes,
    practicalNote,
    relatedCreatureIds: toTextArray(
      item.relatedCreatureIds ?? ITEM_FIELD_DEFAULTS.relatedCreatureIds
    ),
    relatedBossIds: toTextArray(item.relatedBossIds ?? ITEM_FIELD_DEFAULTS.relatedBossIds),
    relatedMapIds: toTextArray(item.relatedMapIds ?? ITEM_FIELD_DEFAULTS.relatedMapIds),
  };
}

function getImportedCreatureLegacyEntry(importEntry, existingById, existingByName) {
  const legacyName = DINO_IMPORT_NAME_ALIASES[importEntry.name];
  return (
    existingById.get(importEntry.id) ||
    existingByName.get(importEntry.name) ||
    (legacyName ? existingByName.get(legacyName) : null) ||
    null
  );
}

function getImportedItemLegacyEntry(importEntry, existingById, existingByName) {
  const legacyName = ITEM_IMPORT_NAME_ALIASES[importEntry.name];
  return (
    existingById.get(importEntry.id) ||
    existingByName.get(importEntry.name) ||
    (legacyName ? existingByName.get(legacyName) : null) ||
    null
  );
}

function syncImportedCreatureRoster(targetState) {
  const existingDinos = Array.isArray(targetState.dinos) ? targetState.dinos : [];
  const existingById = new Map(existingDinos.map((entry) => [entry.id, entry]));
  const existingByName = new Map(existingDinos.map((entry) => [entry.name, entry]));

  targetState.dinos = ASA_IMPORTED_CREATURES.map((entry) => {
    const existing = getImportedCreatureLegacyEntry(entry, existingById, existingByName) || {};
    const practical = normalizeDinoPracticalFields(existing);

    return {
      ...existing,
      id: entry.id,
      name: entry.name,
      mapIds: Array.isArray(entry.mapIds) ? [...entry.mapIds] : [],
      media:
        existing.media &&
        typeof existing.media === "object" &&
        typeof existing.media.src === "string" &&
        existing.media.src.trim()
          ? existing.media
          : buildImportedCreatureMedia(entry, "amber"),
      tameFood: practical.tameFood,
      tameMethod: practical.tameMethod,
      tameMethodType: practical.tameMethodType,
      tameMethodDetail: practical.tameMethodDetail,
      loot: practical.loot,
    };
  });

  targetState.maps = (Array.isArray(targetState.maps) ? targetState.maps : []).map((map) => {
    const importedIds = ASA_IMPORTED_MAP_CREATURE_IDS[map.id];
    if (!importedIds) return map;
    return {
      ...map,
      tameIds: [...importedIds],
    };
  });

  targetState.meta = {
    ...(targetState.meta || {}),
    creatureImportVersion: ASA_CREATURE_IMPORT_VERSION,
  };
}

function syncImportedItemRoster(targetState) {
  const existingItems = Array.isArray(targetState.items) ? targetState.items : [];
  const existingById = new Map(existingItems.map((entry) => [entry.id, entry]));
  const existingByName = new Map(existingItems.map((entry) => [entry.name, entry]));

  targetState.items = ASA_IMPORTED_ITEMS.map((entry) => {
    const existing = getImportedItemLegacyEntry(entry, existingById, existingByName) || {};
    const normalized = normalizeItemFields(existing);

    return {
      ...existing,
      ...entry,
      officialListGroup: entry.officialListGroup || normalized.officialListGroup,
      officialIdCategory: entry.officialIdCategory || normalized.officialIdCategory,
      officialSubcategory: entry.officialSubcategory || normalized.officialSubcategory,
      dlc: entry.dlc || normalized.dlc,
      isLiveASA: entry.isLiveASA ?? normalized.isLiveASA,
      isObtainable: entry.isObtainable ?? normalized.isObtainable,
      media:
        existing.media && typeof existing.media === "object"
          ? existing.media
          : entry.media || {
              src: "",
              type: "empty",
              alt: `${entry.name} icon`,
              tone: "bronze",
            },
      notes: normalized.notes,
      practicalNote: normalized.practicalNote,
      relatedCreatureIds: normalized.relatedCreatureIds,
      relatedBossIds: normalized.relatedBossIds,
      relatedMapIds: normalized.relatedMapIds,
    };
  });

  targetState.meta = {
    ...(targetState.meta || {}),
    itemImportVersion: ASA_ITEM_IMPORT_VERSION,
  };
}

function hasImportedItemRosterGap(items = []) {
  const knownItems = toArray(items);
  if (knownItems.length !== ASA_IMPORTED_ITEMS.length) return true;

  const knownIds = new Set(
    knownItems
      .map((entry) => String(entry?.id || "").trim())
      .filter(Boolean)
  );

  if (!knownIds.size) return true;

  return ASA_IMPORTED_ITEMS.some((entry) => !knownIds.has(entry.id));
}

function ensureItemRosterForRender() {
  if (!hasImportedItemRosterGap(state.items)) {
    return false;
  }

  syncImportedItemRoster(state);
  saveState(state);
  void syncCollectionToCloud(
    "items",
    state.items,
    "Repairing item roster",
    "Item roster repaired"
  );

  return true;
}

function getCreatureMethodSummary(dino = {}) {
  const practical = normalizeDinoPracticalFields(dino);

  if (practical.tameMethodType === "simple" && practical.tameMethod) {
    return practical.tameMethod;
  }

  if (practical.tameMethodType === "special") {
    return practical.tameMethod || "Method note";
  }

  return "—";
}

const CREATURE_META = {
  "argy":          { role: "flyer",      stage: "early",   taming: "Kibble / Raw Meat",          note: "Primary transport across all maps. First tame priority on any map." },
  "anky":          { role: "harvester",  stage: "early",   taming: "Kibble / Mejoberries",        note: "Metal and flint backbone. Pair with Argy for ore runs." },
  "doedic":        { role: "harvester",  stage: "early",   taming: "Kibble / Mejoberries",        note: "Stone harvesting. Roll ability clears rock nodes fast." },
  "rex":           { role: "boss",       stage: "mid",     taming: "Kibble / Raw Meat",           note: "Core boss fighter. Breed and saddle before every major arena." },
  "theri":         { role: "boss",       stage: "mid",     taming: "Kibble / Crops",              note: "Versatile boss pick. High DPS, better sustain than Rex in most fights." },
  "yuty":          { role: "boss",       stage: "mid",     taming: "Kibble / Prime Meat",         note: "Boss support. Courage roar buff is mandatory for serious arena runs." },
  "baryonyx":      { role: "cave",       stage: "early",   taming: "Kibble / Raw Fish Meat",      note: "Best cave mount for water sections. Tail spin stuns swarm enemies." },
  "otter":         { role: "utility",    stage: "early",   taming: "Raw Fish (passive)",          note: "Insulation and silica pearl carry. Essential in hot and cold biomes." },
  "thorny-dragon": { role: "harvester",  stage: "early",   taming: "Kibble / Raw Meat",           note: "Scorched Earth specialist. Harvests cactus sap and wood efficiently." },
  "wyvern":        { role: "flyer",      stage: "endgame", taming: "Wyvern Egg (steal + milk)",   note: "Powerful elemental breath flyer. Requires egg theft and milk feeding." },
  "ravager":       { role: "transport",  stage: "early",   taming: "Raw Meat / Kibble",           note: "Aberration main mount. No fall damage and syncs with zip line network." },
  "spino":         { role: "utility",    stage: "mid",     taming: "Kibble / Raw Fish Meat",      note: "Semi-aquatic high DPS fighter. Outperforms Rex in water zones." },
  "rock-drake":    { role: "flyer",      stage: "mid",     taming: "Rock Drake Egg (steal)",      note: "Aberration endgame mount. Climbs walls, glides, camouflages." },
  "megalo":        { role: "cave",       stage: "mid",     taming: "Kibble / Raw Meat",           note: "Aberration underground brawler. Attacks sleeping players silently." },
  "megatherium":   { role: "boss",       stage: "mid",     taming: "Kibble / Crops",              note: "Broodmother specialist. Massive insect kill buff makes it the top pick." },
  "giga":          { role: "boss",       stage: "endgame", taming: "Kibble / Raw Meat",           note: "Highest base DPS in the game. Hard to control but devastating in arenas." },
  "managarmr":     { role: "flyer",      stage: "endgame", taming: "Kibble / Raw Fish Meat",      note: "Extinction signature mount. Dash and ice breath for speed and crowd control." },
  "shadowmane":    { role: "utility",    stage: "mid",     taming: "Cosmo fish (passive sleep)",  note: "Stealth and pack buff. Strong area fighter with built-in invisibility." },
  "basilo":        { role: "utility",    stage: "mid",     taming: "Kibble / Blubber (passive)",  note: "Ocean staple. Immune to jellyfish damage; clears sea threats safely." },
  "daeodon":       { role: "utility",    stage: "mid",     taming: "Kibble / Prime Meat",         note: "Passive healing aura in boss arena. Essential to sustain Rex/Theri stacks." },
  "achatina":      { role: "utility",    stage: "early",   taming: "Rare Mushroom (passive)",     note: "Generates organic polymer passively. Tame a few and pen them at base." },
  "allosaurus":    { role: "boss",       stage: "mid",     taming: "Kibble / Raw Meat",           note: "Pack bonus increases DPS. Mid-tier boss alternative to Rex." },
  "dung-beetle":   { role: "utility",    stage: "early",   taming: "Feces (passive)",             note: "Generates fertilizer and oil passively. Keep penned in base." },
  "dire-bear":     { role: "cave",       stage: "mid",     taming: "Kibble / Berries",            note: "Strong cave and forest fighter. Immune to bees; good for honey farms." },
  "equus":         { role: "transport",  stage: "early",   taming: "Rockarrot (passive)",         note: "Fast land scout. Produces Rare Mushrooms via its lasso mechanic." },
  "carnotaurus":   { role: "utility",    stage: "early",   taming: "Kibble / Raw Meat",           note: "Fast scout and early hunter. Good DPS for its taming cost." },
  "mantis":        { role: "harvester",  stage: "mid",     taming: "Deathworm Horn (passive)",    note: "Scorched Earth tool mount. Equip pickaxe or hatchet for efficient farming." },
  "basilisk":      { role: "utility",    stage: "mid",     taming: "Fertile Rock Drake Egg",      note: "Ambush predator that buries underground. Strong force multiplier." },
  "bulbdog":       { role: "utility",    stage: "early",   taming: "Aquatic Mushroom (passive)",  note: "Charge light pet for Aberration. Essential for surface and red zone traversal." },
  "featherlight":  { role: "utility",    stage: "early",   taming: "Aggeravic Mushroom (passive)","note": "Aerial charge light pet. Wider light radius than Bulbdog." },
  "karkinos":      { role: "transport",  stage: "mid",     taming: "Kibble / Raw Meat",           note: "Aberration heavy carrier. Grabs creatures and climbs rock faces easily." },
  "gacha":         { role: "utility",    stage: "mid",     taming: "Stone / Berries (passive)",   note: "Passive loot generator. Produces diverse resources including element dust." },
  "gasbags":       { role: "transport",  stage: "early",   taming: "Kibble / Crops",              note: "Extinction balloon mount. Inflates to float slowly or deflates to sprint." },
  "velonasaur":    { role: "utility",    stage: "early",   taming: "Kibble / Raw Meat",           note: "Extinction ranged fighter. Spine volley for crowd control at distance." },
  "snow-owl":      { role: "utility",    stage: "mid",     taming: "Kibble / Raw Meat",           note: "Freeze dive and heal ability. Valuable for taming and boss sustain." },
  "enforcer":      { role: "utility",    stage: "mid",     taming: "Crafted from Extinction City", note: "Craftable Tek mount. Fast and deals bonus damage vs Corrupted creatures." },
  "desmodus":      { role: "flyer",      stage: "mid",     taming: "Blood Pack (passive)",        note: "Stealthy bat flyer. Stealth flight, blood drain for healing." },
  "deinonychus":   { role: "cave",       stage: "early",   taming: "Deinonychus Egg (nest)",      note: "Valguero pack raptor. Jump-latch attack; devastating in packs." },
  "mammoth":       { role: "harvester",  stage: "early",   taming: "Kibble / Crops",              note: "Wood and thatch harvester. Strong knockback for crowd control." },
  "andrewsarchus": { role: "transport",  stage: "early",   taming: "Honey (passive)",             note: "Rideable turret platform. Player can fire weapons while mounted." },
  "astrocetus":    { role: "boss",       stage: "endgame", taming: "Kibble / Element Dust",       note: "Lost Colony space whale. Tek platform saddle serves as a mobile base." },
  "astrodelphis":  { role: "flyer",      stage: "mid",     taming: "Element Dust (passive)",      note: "Space dolphin with extreme speed and Tek boost abilities in space." },
  "direwolf":      { role: "cave",       stage: "early",   taming: "Kibble / Raw Meat",           note: "Pack debuff and strong early cave mount. Excellent cold biome scout." },
  "glowtail":      { role: "utility",    stage: "early",   taming: "Plant Species Z (passive)",   note: "Passive charge light pet. Smallest light pet, easiest to carry." },
  "megalania":     { role: "cave",       stage: "mid",     taming: "Kibble / Raw Meat",           note: "Wall-climbing cave mount. Provides poison bite debuff on targets." },
  "raptor":        { role: "utility",    stage: "early",   taming: "Kibble / Raw Meat",           note: "Fast early predator. Pack bonus procs jaw-lock bleed on targets." },
  "pteranodon":    { role: "flyer",      stage: "early",   taming: "Kibble / Raw Meat",           note: "First flyer on most maps. Low carry weight but fast and easy to tame." },
  "parasaur":      { role: "utility",    stage: "early",   taming: "Kibble / Berries",            note: "Alarm system and early berry farmer. Detects nearby enemies." },
  "stegosaurus":   { role: "harvester",  stage: "early",   taming: "Kibble / Mejoberries",        note: "Berry and fiber harvester. Spike mode reduces incoming damage." },
  "triceratops":   { role: "utility",    stage: "early",   taming: "Kibble / Mejoberries",        note: "Berry farmer and early tank. Charge knockback clears swarms." },
  "quetzal":       { role: "transport",  stage: "mid",     taming: "Kibble / Raw Meat",           note: "Flying platform saddle. Best bulk transport and mobile base mount." },
  "moschops":      { role: "harvester",  stage: "early",   taming: "Crops / Berries (passive)",   note: "Versatile early harvester. Tames passively with its preferred food." },
  "castoroides":   { role: "harvester",  stage: "early",   taming: "Kibble / Vegetables",         note: "Wood and thatch specialist. Giant Beaver Dam yields cementing paste." },
  "diplodocus":    { role: "transport",  stage: "early",   taming: "Kibble / Crops",              note: "Passive and non-aggressive platform for ferrying items and survivors." },
  "brontosaurus":  { role: "transport",  stage: "mid",     taming: "Kibble / Crops",              note: "Massive platform saddle. Mobile berry farm and walking caravan." },
  "thylacoleo":    { role: "cave",       stage: "mid",     taming: "Kibble / Raw Meat",           note: "Wall-jumping ambush predator. Excellent redwood and cave fighter." },
  "megalodon":     { role: "utility",    stage: "mid",     taming: "Kibble / Raw Fish Meat",      note: "Ocean combat mount. Pack bonus applies underwater for boss fights." },
  "mosasaurus":    { role: "utility",    stage: "endgame", taming: "Kibble / Raw Fish Meat",      note: "Deep ocean apex predator. Platform saddle for underwater exploration." },
  "plesiosaur":    { role: "utility",    stage: "mid",     taming: "Kibble / Raw Fish Meat",      note: "Versatile ocean mount. Long neck reach lets it attack from distance." },
  "morellatops":   { role: "utility",    stage: "early",   taming: "Kibble / Mejoberries",        note: "Scorched Earth water source. Carries water in its humps." },
  "jerboa":        { role: "utility",    stage: "early",   taming: "Kibble / Mejoberries",        note: "Scorched Earth weather detector. Warns of sandstorms and heatwaves." },
  "vulture":       { role: "utility",    stage: "early",   taming: "Spoiled Meat (passive)",      note: "Scorched Earth scavenger. Reduces enemy aggression radius when riding." },
  "phoenix":       { role: "utility",    stage: "endgame", taming: "Sulfur during Heat Wave",     note: "Scorched Earth event mount. Cooks food passively and provides warmth." },
  "rock-elemental":{ role: "utility",    stage: "endgame", taming: "Kibble / Sulfur",             note: "Living stone colossus. Near-invulnerable to bullets; use catapults." },
  "roll-rat":      { role: "harvester",  stage: "early",   taming: "Mushrooms / Berries (pass)",  note: "Aberration crystal and stone harvester. Ball form for fast traversal." },
  "shinehorn":     { role: "utility",    stage: "early",   taming: "Plant Species Z (passive)",   note: "Aberration charge pet. Horn flash blinds and repels Nameless." },
  "reaper":        { role: "cave",       stage: "endgame", taming: "Impregnation (Queen)",        note: "Aberration horror mount. Queen impregnates survivor; raise the young." },
  "procoptodon":   { role: "transport",  stage: "early",   taming: "Kibble / Crops",              note: "Kangaroo mount. Leap ability and pouch for carrying baby dinos/players." },
  "sinomacrops":   { role: "flyer",      stage: "early",   taming: "Chitin (passive)",            note: "Shoulder mount glider. Opens as parachute for fall damage prevention." },
  "tropeognathus": { role: "flyer",      stage: "mid",     taming: "Kibble / Propellant",         note: "Jet-powered flyer. Fast aerial dogfighter with forward-firing cannon." },
  "tapejara":      { role: "flyer",      stage: "mid",     taming: "Kibble / Raw Meat",           note: "Versatile flyer with multi-seat saddle. Side-mounted passengers can fight." },
  "dinopithecus":  { role: "utility",    stage: "mid",     taming: "Kibble / Raw Meat",           note: "Feces-throwing alpha pack primate. Can ride and fight on tree canopies." },
  "dimetrodon":    { role: "utility",    stage: "early",   taming: "Kibble / Raw Meat",           note: "Living AC unit. Provides insulation from heat and cold for eggs." },
};

const KNOWLEDGE_SECTIONS = [
  { id: "summary", title: "Summary" },
  { id: "features", title: "Features" },
  {
    id: "gameplay-changes",
    title: "Gameplay Changes from Survival Evolved",
    subSections: [
      "General",
      "Inventory / UI",
      "Structures",
      "Items",
      "Creatures",
      "TLC",
    ],
  },
  {
    id: "new-additions",
    title: "New Additions",
    subSections: [
      "Creatures",
      "Resources",
      "Consumables",
      "Trophies and Tributes",
      "Weapons, Armor, and Tools",
      "Structures",
      "Saddles",
      "Cosmetics",
      "Other",
    ],
  },
  {
    id: "roadmap",
    title: "Roadmap",
    subSections: ["Released", "Upcoming", "TBA"],
  },
  {
    id: "dlc",
    title: "DLC",
    subSections: [
      "Expansion Pack",
      "Expansion Maps",
      "Bob's Tall Tales",
      "Bob's True Tales",
      "Legacy of Santiago",
      "Skin Packs",
      "Collaborations",
      "Total Conversions",
    ],
  },
  { id: "history", title: "History" },
  { id: "gallery", title: "Gallery" },
  { id: "external-links", title: "External Links" },
  { id: "references", title: "References" },
  { id: "data-maps", title: "Data Maps" },
  { id: "ptr", title: "Public Test Realm" },
  { id: "spotlight", title: "Spotlight" },
  { id: "notes", title: "Notes" },
];

const MAP_GROUP_DEFINITIONS = [
  { title: "Core Story Route", badge: "Story", ids: ["the-island", "scorched-earth", "aberration", "extinction"] },
  { title: "Canon Expansion", badge: "Canon Expansion", ids: ["lost-colony"] },
  { title: "Non-Canon / Explore Maps", badge: "Non-Canon", ids: ["the-center", "ragnarok", "valguero", "astraeos"] },
];

const collectionLabels = Object.fromEntries(
  ENTITY_TYPES.map((entry) => [entry.key, entry.label])
);
const CLOUD_SYNC_COLLECTION_KEYS = [
  ...ENTITY_TYPES.map((entry) => entry.key),
  "rankings",
  "serverSettings",
];

let state = loadState();
state = normalizeRuntimeAtlasState(state);
const cloudUi = {
  available: null,
  phase: "checking",
  message: "Connecting cloud",
  activeJobs: 0,
  lastSyncedAt: "",
};

function getCloudEntityId(entry) {
  if (!entry || typeof entry !== "object") return null;
  return entry.id || entry.key || null;
}

function mergeCloudCollection(localCollection = [], remoteCollection = []) {
  const remoteById = new Map(
    remoteCollection
      .map((entry) => [getCloudEntityId(entry), entry])
      .filter(([id]) => Boolean(id))
  );

  const merged = localCollection.map((entry) => {
    const entityId = getCloudEntityId(entry);
    if (!entityId || !remoteById.has(entityId)) {
      return entry;
    }

    const remoteEntry = remoteById.get(entityId);
    remoteById.delete(entityId);
    return { ...entry, ...remoteEntry };
  });

  remoteById.forEach((entry) => {
    merged.push(entry);
  });

  return merged;
}

function mergeCloudPayloadIntoState(localState, remotePayload) {
  const next = { ...localState };

  Object.entries(remotePayload || {}).forEach(([key, value]) => {
    if (Array.isArray(value) && Array.isArray(next[key])) {
      next[key] = mergeCloudCollection(next[key], value);
      return;
    }

    if (
      value &&
      typeof value === "object" &&
      !Array.isArray(value) &&
      next[key] &&
      typeof next[key] === "object" &&
      !Array.isArray(next[key])
    ) {
      next[key] = { ...next[key], ...value };
      return;
    }

    next[key] = value;
  });

  return next;
}

async function hydrateCloudState() {
  const remotePayload = await loadCloudAtlasData();
  if (!remotePayload) return false;

  const remoteItemsNeedRepair = hasImportedItemRosterGap(remotePayload.items);
  const mergedState = mergeCloudPayloadIntoState(state, remotePayload);
  state = normalizeRuntimeAtlasState(
    normalizeAtlasStateFromStore(mergedState)
  );
  saveState(state);
  render();
  if (remoteItemsNeedRepair) {
    updateCloudUi("ready", "Items library repaired locally");
    render();
    void syncCollectionToCloud(
      "items",
      state.items,
      "Repairing item cloud",
      "Items cloud repaired"
    );
  }
  return true;
}

function getStateEntity(collectionKey, entityId) {
  if (!collectionKey || !entityId) return null;
  return findEntity(state, collectionKey, entityId);
}

function formatCloudTime(timestamp) {
  if (!timestamp) return "";
  try {
    const date = new Date(timestamp);
    return date.toLocaleTimeString("en-GB", {
      hour: "2-digit",
      minute: "2-digit",
    });
  } catch {
    return "";
  }
}

function updateCloudUi(phase, message) {
  cloudUi.phase = phase;
  cloudUi.message = message;
}

function beginCloudWork(message) {
  cloudUi.activeJobs += 1;
  updateCloudUi("syncing", message || "Syncing cloud");
  render();
}

function finishCloudWork(ok, message) {
  cloudUi.activeJobs = Math.max(0, cloudUi.activeJobs - 1);
  if (ok) {
    cloudUi.lastSyncedAt = new Date().toISOString();
    updateCloudUi("synced", message || "Cloud synced");
  } else {
    updateCloudUi("error", message || "Cloud sync failed");
  }
  render();
}

async function runCloudTask(startMessage, successMessage, task) {
  if (cloudUi.available === false) {
    updateCloudUi("offline", "Cloud unavailable");
    render();
    return null;
  }

  beginCloudWork(startMessage);
  try {
    const result = await task();
    finishCloudWork(Boolean(result), Boolean(result) ? successMessage : "Cloud sync failed");
    return result;
  } catch (error) {
    console.warn("Cloud task failed.", error);
    finishCloudWork(false, "Cloud sync failed");
    return null;
  }
}

async function syncEntityToCloud(collectionKey, entityId) {
  const entity = getStateEntity(collectionKey, entityId);
  if (!entity) return false;
  return runCloudTask(
    "Saving to cloud",
    "Saved to cloud",
    () => saveAtlasEntityToCloud(collectionKey, entity)
  );
}

async function syncMapToCloud(mapId) {
  if (!mapId) return false;
  return syncEntityToCloud("maps", mapId);
}

async function syncServerSettingToCloud(settingKey) {
  if (!settingKey) return false;
  const setting = (state.serverSettings || []).find(
    (entry) => (entry.id || entry.key) === settingKey
  );
  if (!setting) return false;
  return runCloudTask(
    "Syncing settings",
    "Settings synced",
    () => saveAtlasEntityToCloud("serverSettings", setting)
  );
}

async function syncCollectionToCloud(
  collectionKey,
  collection = state[collectionKey],
  startMessage = "Syncing collection",
  successMessage = "Collection synced"
) {
  if (!collectionKey) return false;

  return runCloudTask(startMessage, successMessage, async () => {
    let failures = 0;
    const entries = Array.isArray(collection) ? collection : [];

    for (const entity of entries) {
      const entityId = getCloudEntityId(entity);
      if (!entityId) continue;

      const ok = await saveAtlasEntityToCloud(collectionKey, entity);
      if (!ok) {
        failures += 1;
      }
    }

    return failures === 0;
  });
}

async function syncAllStateToCloud() {
  return runCloudTask("Syncing atlas", "Atlas synced", async () => {
    let failures = 0;

    const metaSaved = await saveAtlasMetaToCloud(state.meta || {});
    if (!metaSaved) {
      failures += 1;
    }

    for (const collectionKey of CLOUD_SYNC_COLLECTION_KEYS) {
      const collection = Array.isArray(state[collectionKey]) ? state[collectionKey] : [];
      for (const entity of collection) {
        if (!entity || (!entity.id && !entity.key)) continue;

        const mediaSrc = entity.media?.src || "";
        const isLocalImage =
          entity.media?.type === "local" ||
          (typeof mediaSrc === "string" && mediaSrc.startsWith("data:image/"));

        let savedEntity = null;
        if (isLocalImage) {
          savedEntity = await saveAtlasEntityMediaToCloud(
            collectionKey,
            entity,
            mediaSrc,
            "local"
          );
        } else {
          const ok = await saveAtlasEntityToCloud(collectionKey, entity);
          savedEntity = ok ? entity : null;
        }

        if (!savedEntity) {
          failures += 1;
          continue;
        }

        upsertEntity(state, collectionKey, savedEntity);
      }
    }

    saveState(state);
    render();
    return failures === 0;
  });
}

function entityHasPendingLocalMedia(entity) {
  const mediaSrc = entity?.media?.src || "";
  return (
    entity?.media?.type === "local" ||
    (typeof mediaSrc === "string" && mediaSrc.startsWith("data:image/"))
  );
}

async function normalizePendingLocalMedia() {
  const collectionsToNormalize = CLOUD_SYNC_COLLECTION_KEYS.filter((collectionKey) => {
    const collection = Array.isArray(state[collectionKey]) ? state[collectionKey] : [];
    return collection.some((entity) => entityHasPendingLocalMedia(entity));
  });

  if (!collectionsToNormalize.length) {
    return true;
  }

  return runCloudTask("Normalizing media", "Media normalized", async () => {
    let failures = 0;

    for (const collectionKey of collectionsToNormalize) {
      const collection = Array.isArray(state[collectionKey]) ? state[collectionKey] : [];
      for (const entity of collection) {
        if (!entityHasPendingLocalMedia(entity)) continue;

        const savedEntity = await saveAtlasEntityMediaToCloud(
          collectionKey,
          entity,
          entity.media?.src || "",
          "local"
        );
        if (!savedEntity) {
          failures += 1;
          continue;
        }
        upsertEntity(state, collectionKey, savedEntity);
      }
    }

    saveState(state);
    render();
    return failures === 0;
  });
}

async function initializeCloudAtlas() {
  const services = await getFirebaseServices();
  cloudUi.available = Boolean(services);

  if (!services) {
    updateCloudUi("offline", "Cloud unavailable");
    render();
    return;
  }

  updateCloudUi("ready", "Cloud ready");
  render();

  const hydrated = await hydrateCloudState();
  if (hydrated) {
    cloudUi.lastSyncedAt = new Date().toISOString();
    updateCloudUi("synced", "Cloud synced");
  } else {
    updateCloudUi("ready", "Cloud ready");
  }
  render();

  if (!hydrated) {
    void syncAllStateToCloud();
  }
  void normalizePendingLocalMedia();
}

const ui = {
  editMode: false,
  editMapCards: false,
  activeBossId: null,
  activeCreatureEditorId: null,
  creatureEditorFocus: "",
  creatureLibrarySearch: "",
  itemsLibrarySearch: "",
  itemsLibrarySort: "name",
  route: parseRoute(),
  activeMapSection: null,
  activeMapEntity: null,
  mapSectionState: {},
  activeMapLinkPicker: null,
  mapLinkPending: null,
  admin: {
    collectionKey: "maps",
    entityId: "the-island",
  },
  imageModal: null,
};

function parseRoute() {
  const hash = window.location.hash.replace(/^#\/?/, "");
  if (!hash) return { type: "home", section: "home" };

  const [routeSegment, rawAnchor] = hash.split("#");
  const anchor = rawAnchor ? decodeURIComponent(rawAnchor) : "";
  const [segment, id] = routeSegment.split("/");
  if (segment === "map" && id) {
    return { type: "map", id, anchor: anchor || null };
  }

  const sections = [
    "story",
    "maps",
    "route",
    "bosses",
    "tames",
    "creatures",
    "resources",
    "settings",
    "knowledge",
    "lore",
    "rankings",
  ];

  if (sections.includes(segment)) {
    return { type: "home", section: segment, anchor: anchor || null };
  }

  return { type: "home", section: "home", anchor: anchor || null };
}

function render() {
  try {
    ui.route = parseRoute();
    const routeScrollKey = `${ui.route.type}::${ui.route.section || ""}::${ui.route.anchor || ""}::${ui.route.id || ""}`;
    const pageMarkup =
      ui.route.type === "map"
        ? renderMapPage(ui.route.id)
        : renderHomePage(ui.route.section);
    appRoot.innerHTML = `${pageMarkup}${renderCloudDock()}`;
    adminDrawer.innerHTML = renderAdminDrawer();
    if (adminDrawer) {
      adminDrawer.classList.toggle("is-open", ui.editMode);
      adminDrawer.setAttribute("aria-hidden", String(!ui.editMode));
    }
    modalRoot.innerHTML = renderModal();
    if (adminToggleButton) {
      adminToggleButton.classList.toggle("is-active", ui.editMode);
    }

    requestAnimationFrame(() => {
      if (
        ui.route.type === "home" &&
        ui.route.section === "home" &&
        ui.route.anchor &&
        routeScrollKey !== lastSectionRouteScrollKey
      ) {
        const anchor = document.querySelector(`#${CSS.escape(ui.route.anchor)}`);
        anchor?.scrollIntoView({ behavior: "auto", block: "start" });
        lastSectionRouteScrollKey = routeScrollKey;
      }

      if (ui.creatureEditorFocus) {
        const target = document.querySelector(
          `[data-editor-focus-target="${CSS.escape(ui.creatureEditorFocus)}"]`
        );
        if (target instanceof HTMLElement) {
          target.focus();
          if (typeof target.select === "function") {
            target.select();
          }
        }
        ui.creatureEditorFocus = "";
      }
    });
  } catch (error) {
    console.error("Atlas render failed:", error);
    if (appRoot) {
      appRoot.innerHTML = `
        <div class="empty-state">
          <h2>Render error</h2>
          <p>Ứng dụng gặp lỗi runtime khi dựng giao diện. Vui lòng mở console để xem chi tiết.</p>
          <p class="inline">${escapeHtml(error?.message || "Unknown error")}</p>
        </div>
      `;
    }
    if (adminDrawer) {
      adminDrawer.innerHTML = "";
      adminDrawer.classList.remove("is-open");
      adminDrawer.setAttribute("aria-hidden", "true");
    }
    if (modalRoot) {
      modalRoot.innerHTML = "";
    }
  }
}

function renderCloudDock() {
  const phaseText = {
    checking: "Connecting",
    ready: "Cloud Ready",
    syncing: "Syncing",
    synced: "Cloud Synced",
    error: "Sync Error",
    offline: "Cloud Offline",
  };
  const statusLabel = phaseText[cloudUi.phase] || "Cloud";
  const buttonLabel = cloudUi.phase === "syncing" ? "Syncing" : "Sync";
  const note =
    cloudUi.phase === "synced" && cloudUi.lastSyncedAt
      ? `Updated ${formatCloudTime(cloudUi.lastSyncedAt)}`
      : cloudUi.message;

  return `
    <div class="cloud-dock cloud-dock--${escapeHtml(cloudUi.phase)}">
      <div class="cloud-dock__status">
        <span class="cloud-dock__dot" aria-hidden="true"></span>
        <div class="cloud-dock__copy">
          <strong>${escapeHtml(statusLabel)}</strong>
          <span>${escapeHtml(note || "")}</span>
        </div>
      </div>
      <button
        class="ghost-button ghost-button--small cloud-dock__button"
        type="button"
        data-action="force-cloud-sync"
        ${cloudUi.phase === "syncing" ? "disabled" : ""}
      >
        ${escapeHtml(buttonLabel)}
      </button>
    </div>
  `;
}

function renderHomePage(section) {
  const isHome = section === "home" || !section;
  if (isHome) {
    return `
      <div class="page-shell page-shell--hero-only page-shell--home-immersive">
        ${renderHero()}
      </div>
    `;
  }

  return `
    <div class="page-shell">
      ${renderSectionRail(section)}
      ${renderHomeSection(section)}
    </div>
  `;
}

function renderSectionRail(activeSection) {
  const links =
    activeSection === "creatures" || activeSection === "resources"
      ? LIBRARY_SECTION_LINKS
      : HOME_SECTION_LINKS;

  return `
    <nav class="section-rail" aria-label="Atlas navigation">
      ${links.map(
        (link) => `
          <a
            class="section-rail__link ${
              link.id === activeSection ? "is-active" : ""
            } ${
              (activeSection === "creatures" || activeSection === "resources") &&
              link.id === "home"
                ? "section-rail__link--back"
                : ""
            }"
            href="${escapeAttribute(link.href)}"
          >
            ${escapeHtml(link.label)}
          </a>
        `
      ).join("")}
    </nav>
  `;
}

function renderHero() {
  const groupedMaps = getAtlasMapGroups();
  const modules = [
    { key: "creatures", label: "Creatures", href: "#/creatures", state: "active" },
    { key: "resources", label: "Items", href: "#/resources", state: "active" },
  ];

  return `
    <section class="hero-panel hero-panel--maps-only">
      <div class="hero-panel__veil"></div>
      <div class="hero-panel__content hero-panel__content--maps-only">
        <div class="hero-dashboard">
          <div class="hero-dashboard__modules">
            ${modules
              .map(
                (module) => `
                  <a
                    class="hero-dashboard__module hero-dashboard__module--${escapeHtml(
                      module.state
                    )}"
                    href="${escapeHtml(module.href || "#")}"
                    aria-label="${escapeHtml(module.label)}"
                  >
                    <span>${escapeHtml(module.label)}</span>
                  </a>
                `
              )
              .join("")}
          </div>
          <div class="hero-dashboard__panel">
            <div class="hero-dashboard__panel-body">
              <div class="hero-map-groups">
                ${groupedMaps
                  .map(
                    (group) => `
                      <div class="hero-map-group">
                        <div class="hero-map-group__title">${escapeHtml(
                          group.title
                        )}</div>
                        <div class="hero-map-grid">
                          ${renderHeroMapCards(group.maps, group.badge)}
                        </div>
                      </div>
                    `
                  )
                  .join("")}
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  `;
}

function renderHeroMapCards(maps, badgeLabel = "") {
  return (maps || [])
    .map(
      (map) => `
        <a class="hero-map-tile" href="#/map/${escapeHtml(map.id)}">
          ${renderHeroMapCardMedia(map)}
          ${
            badgeLabel
              ? `<span class="hero-map-tile__badge">${escapeHtml(
                  badgeLabel
                )}</span>`
              : ""
          }
          <span class="hero-map-tile__name">${escapeHtml(map.name)}</span>
        </a>
      `
    )
    .join("");
}

function renderHeroMapCardMedia(map) {
  const shortName = (map.name || "M").slice(0, 2);
  return renderMediaSlot("maps", map, {
    className: "hero-map-tile__media",
    label: String(map.name || "Map"),
    placeholderLabel: shortName,
    emptyLabel: "",
    showActions: false,
  });
}

function renderHomeSection(section) {
  const sectionRenderers = {
    story: renderStoryRoute,
    maps: renderExploreMaps,
    route: renderFastestRoute,
    bosses: renderBossPlanner,
    tames: renderGlobalTamePlanner,
    creatures: renderCreatureGallery,
    resources: renderResourcesHub,
    settings: renderServerSettings,
    lore: renderKnowledgeArchives,
    knowledge: renderKnowledgeArchives,
    rankings: renderRankings,
  };

  const hasRenderer = Object.prototype.hasOwnProperty.call(
    sectionRenderers,
    section
  );

  const content = hasRenderer
    ? sectionRenderers[section]()
    : renderLoreRecords();

  const titles = {
    story: { title: "Story Route", description: "Core progression checkpoints and continuity checks." },
    maps: { title: "Explore Maps", description: "Atlas cards for every map profile." },
    route: { title: "Fastest Clear Route", description: "Phased progression from economy to boss execution." },
    bosses: { title: "Boss Planner", description: "Boss capsules that stay execution-ready." },
    tames: { title: "Tame Planner", description: "Dino lineup by role and planning stage." },
    creatures: { title: "Creatures", description: "Practical creature library with tame food, tame method, loot, and note-ready editing." },
    resources: {
      title: "Items Library",
      description: "Unified official ASA items table with preserved group, category, subcategory and DLC metadata.",
    },
    settings: { title: "Server Settings", description: "Route modifiers and server strategy defaults." },
    knowledge: {
      title: "Ancient Records",
      description: "Structured ARK encyclopedia: gameplay changes, additions, roadmap and lore notes.",
    },
    lore: {
      title: "Ancient Records",
      description: "Structured ARK encyclopedia: gameplay changes, additions, roadmap and lore notes.",
    },
    rankings: { title: "Rankings", description: "Map ranking and progression suitability." },
  };

  const { title, description } = titles[section] || {
    title: "Atlas Module",
    description: "",
  };

  return renderSectionShell(section, title, description, content);
}

function getAtlasMapGroups() {
  const maps = toArray(state.maps).filter(Boolean);
  const lookup = new Map(maps.map((map) => [map.id, map]));
  const grouped = MAP_GROUP_DEFINITIONS.map((group) => ({
    ...group,
    maps: group.ids
      .map((id) => lookup.get(id))
      .filter(Boolean),
  }));

  const orderedIds = new Set(MAP_GROUP_DEFINITIONS.flatMap((group) => group.ids));
  const extras = maps.filter((entry) => !orderedIds.has(entry.id));
  if (extras.length) {
    grouped.push({
      title: "Non-Canon / Explore Maps",
      badge: "Non-Canon",
      maps: extras,
    });
  }

  return grouped.filter((group) => group.maps.length > 0);
}

function renderKnowledgeArchives() {
  const sections = getKnowledgeSectionDefs();
  const hasKnowledgeEntries = sections.some(
    (section) => getKnowledgeBySection(section.id).length > 0
  );
  if (!hasKnowledgeEntries) {
    return `
      <div class="inline-empty">
        No knowledge entries yet. Add them from edit mode under
        <strong>Knowledge Articles</strong>.
      </div>
    `;
  }

  return `
      <div class="knowledge-archive">
      ${sections
        .map((section) => {
          const plainEntries = section.subSections?.length
            ? []
            : getKnowledgeBySection(section.id);
          const groupedSubSections = section.subSections?.length
            ? section.subSections
                .map((subSection) => ({
                  id: subSection,
                  entries: getKnowledgeBySection(section.id, subSection),
                }))
                .filter((entry) => entry.entries.length > 0)
            : [];

          const hasContent =
            plainEntries.length > 0 || groupedSubSections.length > 0;
          if (!hasContent) return "";

          return `
            <article class="detail-card">
              <h3>${escapeHtml(section.title)}</h3>
              ${section.subtitle ? `<p>${escapeHtml(section.subtitle)}</p>` : ""}
              ${plainEntries.length
                ? `
                  <div class="mini-card-grid knowledge-archive__cards">
                    ${plainEntries.map(renderKnowledgeArticleCard).join("")}
                  </div>
                `
                : ""}
              ${groupedSubSections.length
                ? `
                  <div class="knowledge-subsection-grid">
                    ${groupedSubSections
                      .map(
                        (block) => `
                          <div class="knowledge-archive__group">
                            <h4>${escapeHtml(block.id)}</h4>
                            <div class="mini-card-grid knowledge-archive__cards">
                              ${block.entries.map(renderKnowledgeArticleCard).join("")}
                            </div>
                          </div>
                        `
                      )
                      .join("")}
                  </div>
                `
                : ""}
            </article>
          `;
        })
        .join("")}
      </div>
  `;
}

function getKnowledgeSectionDefs() {
  return KNOWLEDGE_SECTIONS;
}

function getKnowledgeBySection(sectionId, subSection) {
  const sectionArticles = toArray(state.knowledgeArticles).filter(
    (article) => article.section === sectionId
  );

  if (!subSection) {
    return sectionArticles
      .filter((article) => !article.subSection)
      .sort((a, b) => (a.order ?? 0) - (b.order ?? 0));
  }

  return sectionArticles
    .filter((article) => article.subSection === subSection)
    .sort((a, b) => (a.order ?? 0) - (b.order ?? 0));
}

function renderKnowledgeArticleCard(article) {
  const linkedMaps = toTextArray(article.mapIds).map((id) => getMap(id)).filter(Boolean);
  const linkedReferences = toTextArray(article.referenceIds)
    .map((id) => getReference(id))
    .filter(Boolean);
  const linkedCreatures = toTextArray(article.creatureIds)
    .map((id) => getDino(id))
    .filter(Boolean);
  const linkedItems = toTextArray(article.itemIds)
    .map((id) => getItem(id))
    .filter(Boolean);
  const linkedPatches = toTextArray(article.patchIds)
    .map((id) => getPatchHistory(id))
    .filter(Boolean);
  const linkedDlcs = toTextArray(article.dlcIds)
    .map((id) => getDlc(id))
    .filter(Boolean);
  const linkedGallery = toTextArray(article.galleryIds)
    .map((id) => getGalleryMedia(id))
    .filter(Boolean);

  return `
    <article class="detail-card">
      <div class="knowledge-article__heading">
        <p class="eyebrow">${escapeHtml(article.section || "Knowledge")}</p>
        <h3>${escapeHtml(article.title || "Knowledge Item")}</h3>
      </div>
      <p>${escapeHtml(article.summary || article.content || "")}</p>
      ${article.subSection ? `<span class="chip-row__label">${escapeHtml(article.subSection)}</span>` : ""}
      ${toTextArray(article.bullets)
        .map((entry) => `<p>• ${escapeHtml(entry)}</p>`)
        .join("")}
      ${linkedMaps.length ? `<div class="knowledge-article__links">${linkedMaps.map((entry) => `<a class="chip chip--button" href="#/map/${escapeHtml(entry.id)}">Map: ${escapeHtml(entry.name)}</a>`).join("")}</div>` : ""}
      ${linkedCreatures.length ? `<div class="knowledge-article__links"><span class="knowledge-article__link-label">Creatures:</span>${linkedCreatures.map((creature) => `<a class="chip chip--button" href="#/maps">${escapeHtml(creature.name)}</a>`).join("")}</div>` : ""}
      ${linkedItems.length ? `<div class="knowledge-article__links"><span class="knowledge-article__link-label">Items:</span>${linkedItems.map((item) => `<a class="chip chip--button" href="#/resources">${escapeHtml(item.name || item.title)}</a>`).join("")}</div>` : ""}
      ${linkedPatches.length ? `<div class="knowledge-article__links"><span class="knowledge-article__link-label">Patch:</span>${linkedPatches.map((patch) => `<span class="chip">${escapeHtml(patch.version || patch.title || "Patch")}</span>`).join("")}</div>` : ""}
      ${linkedDlcs.length ? `<div class="knowledge-article__links"><span class="knowledge-article__link-label">DLC:</span>${linkedDlcs.map((entry) => `<span class="chip">${escapeHtml(entry.title || entry.name)}</span>`).join("")}</div>` : ""}
      ${linkedGallery.length ? `<div class="knowledge-article__links"><span class="knowledge-article__link-label">Gallery:</span>${linkedGallery.map((mediaItem) => `<span class="chip">${escapeHtml(mediaItem.name || mediaItem.title || mediaItem.type)}</span>`).join("")}</div>` : ""}
      ${linkedReferences.length ? `<div class="knowledge-article__links"><span class="knowledge-article__link-label">References:</span>${linkedReferences.map((ref) => `<a class="chip chip--button" href="${escapeAttribute(ref.url || "#")}" target="${ref.url ? "_blank" : ""}" rel="noopener noreferrer">${escapeHtml(ref.title || ref.url || "Reference")}</a>`).join("")}</div>` : ""}
      <div class="knowledge-article__actions">
        ${ui.editMode ? `<button class="ghost-button ghost-button--small" type="button" data-action="quick-edit" data-collection="knowledgeArticles" data-entity-id="${escapeHtml(article.id)}">Quick Edit</button>` : ""}
      </div>
    </article>
  `;
}

function renderSectionShell(id, title, description, content) {
  return `
    <section id="section-${id}" class="content-section">
      <div class="section-heading">
        <div>
          <h2>${escapeHtml(title)}</h2>
        </div>
      </div>
      ${content}
    </section>
  `;
}

function getTopTameFoodItems(rawValue, limit = 3) {
  const text = String(rawValue || "").trim();
  if (!text) return [];

  const splitItems = text
    .split("/")
    .flatMap((entry) => entry.split(";"))
    .flatMap((entry) => entry.split(","))
    .map((entry) => entry.trim())
    .filter(Boolean)
    .map((entry) => entry.replace(/\s+/g, " "));

  const seen = new Set();
  const items = [];

  for (const item of splitItems) {
    const key = item.toLowerCase();
    if (seen.has(key)) continue;
    seen.add(key);
    items.push(item);
    if (items.length >= limit) break;
  }

  return items;
}

function formatTopTameFood(rawValue, limit = 3) {
  const foods = getTopTameFoodItems(rawValue, limit);
  return foods.length ? foods.join(" / ") : "—";
}

function getResourceRowsFromState(maps) {
  const resources = Array.isArray(state.resources) ? state.resources : [];
  const rows = [];
  const seen = new Set();
  const normalizedMaps = toArray(maps);

  if (!normalizedMaps.length) return rows;

  const resourceById = new Map(resources.map((resource) => [resource.id, resource]));

  normalizedMaps.forEach((map) => {
    const routeResources = toArray(map.resourceRoutes).map(
      (route) =>
        route?.id || `${map.id}-${slugify(route?.resource || route?.name || "resource")}`
    );
    const resourceIds =
      toArray(map.resourceIds).length ? toArray(map.resourceIds) : routeResources;

    resourceIds.forEach((resourceId) => {
      const sourceResource = resourceById.get(resourceId);
      if (!sourceResource) {
        return;
      }

      const rowKey = `${sourceResource.id}|${map.id}`;
      if (seen.has(rowKey)) return;
      seen.add(rowKey);

      rows.push({
        type: "Resource Route",
        name: sourceResource.name || sourceResource.title || "Resource Route",
        note: sourceResource.shortDescription || sourceResource.route || "",
        tool: sourceResource.tool || sourceResource.resource || "",
        risk: sourceResource.risk || "",
        mapName: map.name || "Unknown map",
        mapId: map.id,
      });
    });
  });

  return rows;
}

function getFoodRowsFromDinos() {
  const foodRows = [];
  const mapById = new Map(toArray(state.maps).map((map) => [map.id, map]));

  toArray(state.dinos).forEach((dino) => {
    const foods = getTopTameFoodItems(dino.tameFood, 3);
    if (!foods.length) return;

    const linkedMapNames = toArray(dino.linkedMaps).length
      ? toArray(dino.linkedMaps)
      : toArray(state.maps)
          .filter((map) => toArray(map.tameIds).includes(dino.id))
          .map((map) => map.name)
          .filter(Boolean);

    const dinoMapName =
      linkedMapNames.length > 0
        ? linkedMapNames.join(", ")
        : (dino.mapId && mapById.get(dino.mapId)?.name) || "—";

    foodRows.push({
      type: "Food",
      name: "Food",
      note: formatTopTameFood(dino.tameFood, 3),
      tool: dino.name,
      risk: "—",
      mapName: dinoMapName,
      mapId: dino.mapId || "",
      actionHref: "#/creatures#tame-food",
    });
  });

  return foodRows;
}

function renderStoryRoute() {
  const canonicalOrder = [
    "the-island",
    "scorched-earth",
    "aberration",
    "extinction",
    "lost-colony",
  ];

  return `
    <div class="timeline-grid">
      ${canonicalOrder
        .map((mapId, index) => {
          const map = getMap(mapId);
          if (!map) {
            return `
              <article class="timeline-card timeline-card--missing">
                <span class="timeline-card__step">0${index + 1}</span>
                <h3>${escapeHtml(mapId)}</h3>
                <p>Missing map record in current data.</p>
                <div class="timeline-card__micro">
                  <span>Reset data or import an atlas backup to restore.</span>
                </div>
              </article>
            `;
          }
          const mapStory = map.story || {};
          return `
            <article class="timeline-card">
              <span class="timeline-card__step">0${index + 1}</span>
              <h3>${escapeHtml(map.name)}</h3>
              <p>${escapeHtml(mapStory.place || "Story location pending.")}</p>
              <div class="timeline-card__micro">
                <span>${escapeHtml(mapStory.objective || "Objective pending.")}</span>
                <span>${escapeHtml(mapStory.next || "Next step pending.")}</span>
              </div>
              <a class="text-link" href="#/map/${map.id}">Open map dossier</a>
            </article>
          `;
        })
        .join("")}
    </div>
  `;
}

function renderExploreMaps() {
  const mapGroups = getAtlasMapGroups();

  return `
    <div class="map-group-stack">
      ${mapGroups
        .map(
          (group) => `
              <section class="map-group-shell">
              <div class="section-heading section-heading--compact">
                <div>
                  <p class="eyebrow">Map Path</p>
                  <h3>${escapeHtml(group.title)}</h3>
                </div>
              </div>
              <div class="poster-grid">
                ${group.maps.map((map) => renderMapPosterCard(map)).join("")}
              </div>
            </section>
          `
        )
        .join("")}
    </div>
  `;
}

function renderMapPosterCard(map) {
  return `
    <article class="poster-card">
      ${renderMediaSlot("maps", map, {
        className: "poster-card__media",
        label: "Map Poster",
        aspect: "poster",
        showActions: ui.editMapCards,
      })}
      <div class="poster-card__body">
        <div class="chip-row">${renderTagList(map.tags)}</div>
        <h3>${escapeHtml(map.name)}</h3>
        <p>${escapeHtml(map.vibe)}</p>
        <div class="poster-card__meta">
          <span>${escapeHtml(map.classification?.type || "Unknown")}</span>
          <span>${escapeHtml(map.classification?.access || "Unknown")}</span>
          <span>${escapeHtml(map.role)}</span>
        </div>
        <a class="text-link" href="#/map/${map.id}">Open map dossier</a>
      </div>
    </article>
  `;
}

function renderFastestRoute() {
  return `
    <div class="phase-grid">
      ${state.fastestRoute
        .map(
          (phase) => `
            <article class="phase-card">
              <p class="eyebrow">${escapeHtml(phase.phase)}</p>
              <h3>${escapeHtml(phase.title)}</h3>
              <p>${escapeHtml(phase.focus)}</p>
              <div class="chip-row">${renderTagList(phase.priorities)}</div>
            </article>
          `
        )
        .join("")}
    </div>
  `;
}

function renderBossPlanner() {
  const featured = state.bosses.slice(0, 8);
  return `
    <div class="boss-grid">
      ${featured.map((boss) => renderBossCard(boss)).join("")}
    </div>
  `;
}

function renderBossCard(boss, compact = false) {
  const map = getMap(boss.mapId);
  return `
    <article class="boss-card ${compact ? "boss-card--compact" : ""}">
      ${renderMediaSlot("bosses", boss, {
        className: "boss-card__media",
        label: "Boss Image",
        aspect: "poster",
      })}
      <div class="boss-card__body">
        <div class="chip-row">${renderTagList(toTextArray(boss.tags))}</div>
        <h3>${escapeHtml(boss.name)}</h3>
        <p>${escapeHtml(boss.shortDescription || boss.difficultyFeel || "")}</p>
        <div class="stat-inline">
          <span>${escapeHtml(map?.name || "Unknown Map")}</span>
          <span>${escapeHtml(boss.mainDanger || "Threat notes pending")}</span>
        </div>
        <button
          class="text-link button-reset"
          type="button"
          data-action="open-boss"
          data-boss-id="${boss.id}"
        >
          Open boss dossier
        </button>
      </div>
    </article>
  `;
}

function renderGlobalTamePlanner() {
  const creatures = [...toArray(state.dinos)].sort((a, b) =>
    (a.name || "").localeCompare(b.name || "")
  );

  if (!creatures.length) {
    return renderEmptyState(
      "No creatures yet",
      "Add creature entries and upload images in edit mode."
    );
  }

  return `
    <div class="dino-gallery-shell">
      <div class="section-heading section-heading--compact">
        <div>
          <h3>Creature Gallery</h3>
          <p>${creatures.length} registered creatures.</p>
        </div>
      </div>
      <div class="dino-gallery-grid">
        ${creatures.map((dino) => renderDinoCard(dino, true)).join("")}
      </div>
    </div>
  `;
}

function renderCreatureGallery() {
  const creatures = [...toArray(state.dinos)]
    .filter(Boolean)
    .sort((a, b) => (a.name || "").localeCompare(b.name || ""));

  if (!creatures.length) {
    return renderEmptyState("No creatures yet", "Add creature entries to begin the library.");
  }

  const query = String(ui.creatureLibrarySearch || "").trim().toLowerCase();
  const filtered = creatures.filter((dino) => {
    if (!query) return true;

    const practical = normalizeDinoPracticalFields(dino);
    const searchable = [
      dino.name,
      practical.tameFood,
      practical.tameMethod,
      practical.tameMethodDetail,
      practical.loot,
      dino.notes,
      dino.shortDescription,
    ]
      .filter(Boolean)
      .join(" ")
      .toLowerCase();

    return searchable.includes(query);
  });

  return `
    <div class="creature-library-shell">
      <div class="section-heading section-heading--compact creature-library-shell__header">
        <div>
          <h3>Creature Library</h3>
          <p>${filtered.length} of ${creatures.length} creatures.</p>
        </div>
        <label class="creature-library-toolbar__field">
          <span>Search</span>
          <input
            type="search"
            value="${escapeHtml(ui.creatureLibrarySearch || "")}"
            placeholder="Search creature, food, method, loot"
            data-action="creature-library-search"
          />
        </label>
      </div>
      <div class="map-data-table-wrap">
        <table class="map-data-table creature-library-table">
          <thead>
            <tr>
              <th style="width:64px">Avatar</th>
              <th>Name</th>
              <th id="tame-food">Tame Food</th>
              <th>Tame Method</th>
              <th>Loot</th>
            </tr>
          </thead>
          <tbody>
            ${
              filtered.length
                ? filtered
                    .map((dino) => {
                      const practical = normalizeDinoPracticalFields(dino);
                      const hasImage = Boolean(dino.media?.src);
                      const isEditorOpen = ui.activeCreatureEditorId === dino.id;
                      const methodCell =
                        practical.tameMethodType === "special"
                          ? `
                            <button
                              class="ghost-button ghost-button--small creature-library-table__note-button"
                              type="button"
                              data-action="open-creature-editor"
                              data-entity-id="${escapeHtml(dino.id)}"
                              data-focus="tameMethodDetail"
                            >
                              ${escapeHtml(
                                practical.tameMethodDetail ? "Open note" : "Method note"
                              )}
                            </button>
                          `
                          : practical.tameMethodType === "simple" && practical.tameMethod
                          ? escapeHtml(practical.tameMethod)
                          : "—";

                      return `
                        <tr>
                          <td>
                            <div class="creature-table__avatar">
                              ${
                                hasImage
                                  ? `<img src="${escapeAttribute(dino.media.src)}" alt="${escapeHtml(
                                      dino.name
                                    )}" loading="lazy" />`
                                  : `<span class="creature-table__avatar-placeholder">${escapeHtml(
                                      String(dino.name || "??").slice(0, 2)
                                    )}</span>`
                              }
                            </div>
                          </td>
                          <td class="creature-library-table__name-cell">
                            <div class="creature-library-table__name-stack">
                              <span class="creature-table__name">${escapeHtml(dino.name)}</span>
                              <button
                                class="ghost-button ghost-button--small creature-library-table__edit-button"
                                type="button"
                                data-action="open-creature-editor"
                                data-entity-id="${escapeHtml(dino.id)}"
                                data-focus="tameFood"
                              >
                                Edit
                              </button>
                            </div>
                          </td>
                          <td class="creature-table__taming">${escapeHtml(
                            formatTopTameFood(practical.tameFood, 3)
                          )}</td>
                          <td class="creature-table__taming">${methodCell}</td>
                          <td class="creature-table__loot">${
                            practical.loot ? escapeHtml(practical.loot) : "—"
                          }</td>
                        </tr>
                        ${
                          isEditorOpen
                            ? renderCreatureLibraryEditorRow(dino, practical)
                            : ""
                        }
                      `;
                    })
                    .join("")
                : `
                  <tr>
                    <td colspan="5">
                      <div class="inline-empty">No creatures matched your search.</div>
                    </td>
                  </tr>
                `
            }
          </tbody>
        </table>
      </div>
    </div>
  `;
}

function renderCreatureLibraryEditorRow(dino, practical) {
  const safePractical = practical || normalizeDinoPracticalFields(dino);
  const detailHidden = safePractical.tameMethodType !== "special";

  return `
    <tr class="creature-library-editor-row">
      <td colspan="5">
        <form class="creature-inline-editor" data-editor-for="${escapeHtml(dino.id)}">
          <input type="hidden" name="entityId" value="${escapeHtml(dino.id)}" />
          <div class="creature-inline-editor__grid">
            <label>
              <span>Tame Food</span>
              <textarea
                name="tameFood"
                rows="2"
                placeholder="Kibble / Mutton / Prime Meat"
                data-editor-focus-target="tameFood"
              >${escapeHtml(safePractical.tameFood)}</textarea>
            </label>
            <label>
              <span>Method Type</span>
              <select name="tameMethodType" data-action="creature-method-type">
                ${DINO_TAME_METHOD_TYPES.map(
                  (type) => `
                    <option value="${type}" ${
                      safePractical.tameMethodType === type ? "selected" : ""
                    }>
                      ${escapeHtml(capitalize(type))}
                    </option>
                  `
                ).join("")}
              </select>
            </label>
            <label>
              <span>Tame Method</span>
              <input
                name="tameMethod"
                type="text"
                value="${escapeHtml(safePractical.tameMethod)}"
                placeholder="Knockout, Passive"
              />
            </label>
            <label>
              <span>Loot</span>
              <input
                name="loot"
                type="text"
                value="${escapeHtml(safePractical.loot)}"
                placeholder="Argentavis Talon"
              />
            </label>
            <label class="creature-inline-editor__detail" ${detailHidden ? "hidden" : ""}>
              <span>Method Detail</span>
              <textarea
                name="tameMethodDetail"
                rows="4"
                placeholder="Special taming note"
                data-editor-focus-target="tameMethodDetail"
                ${detailHidden ? "disabled" : ""}
              >${escapeHtml(safePractical.tameMethodDetail)}</textarea>
            </label>
          </div>
          <div class="creature-inline-editor__actions">
            <button
              class="ghost-button ghost-button--small"
              type="button"
              data-action="close-creature-editor"
            >
              Close
            </button>
            <button
              class="hero-button hero-button--primary hero-button--small"
              type="submit"
              data-action="save-creature-editor"
            >
              Save
            </button>
          </div>
        </form>
      </td>
    </tr>
  `;
}

function compareLibraryText(a, b) {
  return String(a || "").localeCompare(String(b || ""), undefined, {
    sensitivity: "base",
    numeric: true,
  });
}

function renderResourcesHub() {
  ensureItemRosterForRender();

  const items = toArray(state.items)
    .filter(Boolean)
    .map((item) => ({
      ...item,
      ...normalizeItemFields(item),
    }));

  if (!items.length) {
    return renderEmptyState("No items yet", "Import the unified ASA items collection to populate the library.");
  }

  const query = String(ui.itemsLibrarySearch || "").trim().toLowerCase();
  const sort = ITEM_LIBRARY_SORT_OPTIONS.some((entry) => entry.value === ui.itemsLibrarySort)
    ? ui.itemsLibrarySort
    : "name";

  const filtered = items.filter((item) => {
    if (!query) return true;

    const searchable = [
      item.name,
      item.officialListGroup,
      item.officialIdCategory,
      item.officialSubcategory,
      item.dlc,
      item.practicalNote,
      item.notes,
    ]
      .filter(Boolean)
      .join(" ")
      .toLowerCase();

    return searchable.includes(query);
  });

  filtered.sort((left, right) => {
    switch (sort) {
      case "group":
        return (
          compareLibraryText(left.officialListGroup, right.officialListGroup) ||
          compareLibraryText(left.name, right.name)
        );
      case "category":
        return (
          compareLibraryText(left.officialIdCategory, right.officialIdCategory) ||
          compareLibraryText(left.name, right.name)
        );
      case "subcategory":
        return (
          compareLibraryText(left.officialSubcategory, right.officialSubcategory) ||
          compareLibraryText(left.name, right.name)
        );
      case "dlc":
        return compareLibraryText(left.dlc, right.dlc) || compareLibraryText(left.name, right.name);
      default:
        return compareLibraryText(left.name, right.name);
    }
  });

  return `
    <div class="items-library-shell">
      <div class="section-heading section-heading--compact creature-library-shell__header">
        <div>
          <h3>Items Library</h3>
          <p>${filtered.length} of ${items.length} items.</p>
        </div>
        <div class="items-library-toolbar">
          <label class="creature-library-toolbar__field">
            <span>Search</span>
            <input
              type="search"
              value="${escapeHtml(ui.itemsLibrarySearch || "")}"
              placeholder="Search item, category, DLC, note"
              data-action="items-library-search"
            />
          </label>
          <label class="creature-library-toolbar__field items-library-toolbar__sort">
            <span>Sort</span>
            <select data-action="items-library-sort">
              ${ITEM_LIBRARY_SORT_OPTIONS.map(
                (option) => `
                  <option value="${escapeAttribute(option.value)}" ${
                    sort === option.value ? "selected" : ""
                  }>
                    ${escapeHtml(option.label)}
                  </option>
                `
              ).join("")}
            </select>
          </label>
        </div>
      </div>
      <div class="map-data-table-wrap">
        <table class="map-data-table items-library-table">
          <thead>
            <tr>
              <th style="width:64px">Icon</th>
              <th>Name</th>
              <th>Official Group</th>
              <th>Official Category</th>
              <th>Official Subcategory</th>
              <th>DLC</th>
              <th>Practical Note</th>
            </tr>
          </thead>
          <tbody>
            ${
              filtered.length
                ? filtered
                    .map((item) => {
                      const hasImage = Boolean(item.media?.src);
                      return `
                        <tr>
                          <td>
                            <div class="creature-table__avatar items-library-table__thumb">
                              ${
                                hasImage
                                  ? `<img src="${escapeAttribute(item.media.src)}" alt="${escapeHtml(
                                      item.name
                                    )}" loading="lazy" />`
                                  : `<span class="creature-table__avatar-placeholder">${escapeHtml(
                                      String(item.name || "IT").slice(0, 2)
                                    )}</span>`
                              }
                            </div>
                          </td>
                          <td class="items-library-table__name-cell">
                            <span class="creature-table__name">${escapeHtml(item.name)}</span>
                          </td>
                          <td>${escapeHtml(item.officialListGroup || "—")}</td>
                          <td>${escapeHtml(item.officialIdCategory || "—")}</td>
                          <td>${escapeHtml(item.officialSubcategory || "—")}</td>
                          <td>${escapeHtml(item.dlc || "—")}</td>
                          <td class="creature-table__note">${escapeHtml(item.practicalNote || "—")}</td>
                        </tr>
                      `;
                    })
                    .join("")
                : `
                  <tr>
                    <td colspan="7">
                      <div class="inline-empty">No items matched your search.</div>
                    </td>
                  </tr>
                `
            }
          </tbody>
        </table>
      </div>
    </div>
  `;
}

function renderServerSettings() {
  return `
    <div class="setting-grid">
      ${state.serverSettings
        .map(
          (setting) => `
            <article class="setting-card">
              <span class="setting-card__label">${escapeHtml(setting.label)}</span>
              ${
                ui.editMode
                  ? `<input class="setting-card__input" data-setting-key="${setting.key}" value="${escapeHtml(
                      setting.value
                    )}" />`
                  : `<strong>${escapeHtml(setting.value)}</strong>`
              }
              <p>${escapeHtml(setting.target)}</p>
            </article>
          `
        )
        .join("")}
    </div>
  `;
}

function renderLoreRecords() {
  return `
    <div class="record-grid">
      ${state.loreRecords
        .map(
          (record) => `
            <article class="record-card">
              <h3>${escapeHtml(record.title)}</h3>
              <p>${escapeHtml(record.text)}</p>
            </article>
          `
        )
        .join("")}
    </div>
  `;
}

function renderRankings() {
  return `
    <div class="ranking-grid">
      ${state.rankings
        .map((entry) => {
          const map = getMap(entry.mapId);
          return `
            <article class="ranking-card">
              <div class="ranking-card__score">${entry.score}</div>
              <div class="ranking-card__body">
                <p class="eyebrow">${escapeHtml(entry.title)}</p>
                <h3>${escapeHtml(map?.name || entry.mapId)}</h3>
                <p>${escapeHtml(entry.summary)}</p>
                <div class="chip-row">${renderTagList(entry.badges)}</div>
              </div>
            </article>
          `;
        })
        .join("")}
    </div>
  `;
}

function renderMapPage(mapId) {
  const map = getMap(mapId);
  if (!map) {
    return `
      <div class="page-shell">
        <section class="content-section">
          <div class="empty-state">
            <h2>Map record not found</h2>
            <p>This dossier does not exist yet.</p>
            <a class="hero-button hero-button--primary" href="#/maps">Back to maps</a>
          </div>
        </section>
      </div>
  `;
  }

  return `
    <div class="page-shell page-shell--map">
      <section class="map-hero">
        <div class="map-hero__poster">
          ${renderMediaSlot("maps", map, {
            className: "map-hero__media",
            label: "Map Poster",
            aspect: "hero",
            emptyLabel: "",
          })}
        </div>
        <div class="map-hero__content">
          <h1>${escapeHtml(map.name)}</h1>
        </div>
      </section>

      <section class="content-section content-section--hub-only">
        <div class="map-section-grid">
          ${MAP_SECTION_ORDER
            .map((sectionKey) => renderMapSectionCard(map, sectionKey))
            .join("")}
        </div>
      </section>
    </div>
  `;
}

function renderMapSectionCard(map, sectionKey) {
  const section = MAP_SECTION_DEFS[sectionKey];
  if (!section) return "";

  const entries = resolveMapSectionEntities(map, section, false);
  const avatar = getMapSectionAvatar(section, entries, map);
  const shortName = (section.title || "S").slice(0, 2);

  return `
    <button
      class="map-section-card map-section-card--link"
      type="button"
      data-action="open-map-section"
      data-map-id="${escapeHtml(map.id)}"
      data-section="${escapeHtml(section.key)}"
      data-mode="open"
      aria-label="Open ${escapeHtml(section.title)}"
    >
      ${renderMediaSlot("", avatar, {
        className: "map-section-card__media",
        label: section.title,
        placeholderLabel: shortName,
        emptyLabel: "",
        aspect: "poster",
        showActions: false,
      })}
      <div class="map-section-card__header map-section-card__header--solo">
        <h3>${escapeHtml(section.title)}</h3>
      </div>
    </button>
  `;
}

function getMapSectionAvatar(sectionDef, entries, map) {
  const source =
    entries.find((entry) => entry?.media?.src) ||
    entries[0];
  const baseTitle = sectionDef.title || source?.name || source?.title || "Section";

  return {
    ...(source || {}),
    id: `${map.id}-${sectionDef.key}-hub`,
    name: baseTitle,
    title: baseTitle,
    media: {
      src: source?.media?.src || "",
      type: source?.media?.type || "empty",
      alt: baseTitle,
      tone: source?.media?.tone || "bronze",
    },
  };
}

function resolveMapSectionEntities(map, sectionDef, includeAll = false) {
  if (!sectionDef) return [];

  if (sectionDef.key === "progression") {
    return toArray(map.progression).map((entry, index) => ({
      ...entry,
      id: `${map.id}-phase-${index}`,
      __isLinked: true,
    }));
  }

  if (!sectionDef.collectionKey) return [];

  const collection = state[sectionDef.collectionKey] || [];
  const linkedIds = new Set(
    getMapLinkIds(map, sectionDef.collectionKey, sectionDef.linkField)
  );

  if (sectionDef.collectionKey === "dinos") {
    return collection
      .filter(Boolean)
      .map((entry) => ({
        ...entry,
        __isLinked: linkedIds.has(entry.id),
      }))
      .filter((entry) => (includeAll ? true : entry.__isLinked));
  }

  const list = includeAll
    ? collection.filter(Boolean)
    : collection.filter((entry) => linkedIds.has(entry.id));

  return list
    .filter(Boolean)
    .map((entry) => ({
      ...entry,
      __isLinked: true,
    }));
}

function getMapSectionState(sectionKey) {
  if (!ui.mapSectionState[sectionKey]) {
    ui.mapSectionState[sectionKey] = {
      search: "",
      filters: {},
    };
  }
  return ui.mapSectionState[sectionKey];
}

function getMapSectionEntryLabel(sectionDef, entry) {
  if (sectionDef.key === "progression") {
    return String(entry.stage || "Phase");
  }
  return (
    entry.name ||
    entry.title ||
    entry.route ||
    entry.stage ||
    entry.focus ||
    entry.cave ||
    entry.type ||
    entry.id ||
    "Entry"
  );
}

function getProgressionPreviewRows(phases = []) {
  return toArray(phases).slice(0, 2).map((entry) => ({
    ...entry,
    id: slugify(`${entry.stage || "phase"}-${entry.focus || ""}`),
    __isLinked: true,
  }));
}

function renderMapSectionModal() {
  const active = ui.activeMapSection;
  if (!active?.mapId || !active.section) return "";

  const map = getMap(active.mapId);
  const sectionDef = MAP_SECTION_DEFS[active.section];
  if (!map || !sectionDef) return "";

  const sectionState = getMapSectionState(active.section);
  const query = String(sectionState.search || "").trim().toLowerCase();

  const contentMap = {
    bosses: renderMapSectionBossesModal,
    dinos: renderMapSectionCreaturesModal,
    resources: renderMapSectionResourcesModal,
    artifacts: renderMapSectionArtifactsModal,
    tributeItems: renderMapSectionTributeModal,
    baseSpots: renderMapSectionBaseSpotsModal,
    progression: renderMapSectionProgressionModal,
    galleryMedia: renderMapSectionGalleryModal,
    references: renderMapSectionSourcesModal,
  };

  const contentRenderer = contentMap[active.section];
  if (!contentRenderer) return "";

  return `
    <div class="modal-backdrop" data-action="close-modal">
      <div class="modal-panel modal-panel--map-section" role="dialog" aria-modal="true">
        <div class="modal-panel__header map-section-modal__header">
          <div>
            <h2>${escapeHtml(sectionDef.title)}</h2>
          </div>
          <button class="ghost-button" type="button" data-action="close-modal">
            Close
          </button>
        </div>
        <div class="map-section-modal__toolbar">
          ${renderMapSectionToolbar(sectionDef, sectionState)}
        </div>
        <div class="modal-panel__body map-section-modal__body">
          ${contentRenderer(map, sectionDef, query, sectionState)}
        </div>
      </div>
    </div>
  `;
}

function renderMapSectionToolbar(sectionDef, sectionState) {
  const isCreatureModule = sectionDef.key === "dinos";
  const canSearch =
    sectionDef.supportsSearch || isCreatureModule || sectionDef.key === "references";

  return `
    <div class="map-section-toolbar__group">
      ${canSearch ? `
        <label class="map-section-toolbar__field">
          Search
          <input
            type="search"
            data-action="map-section-search"
            data-section="${escapeHtml(sectionDef.key)}"
            value="${escapeHtml(sectionState.search)}"
            placeholder="Search ${escapeHtml(sectionDef.previewLabel || sectionDef.title)}..."
          />
        </label>
      ` : ""}
      ${sectionDef.key === "dinos" ? `
        <label class="map-section-toolbar__field">
          Stage
          <select
            data-action="map-section-filter"
            data-section="${escapeHtml(sectionDef.key)}"
            data-filter="stage"
          >
            <option value="">All stages</option>
            ${CREATURE_STAGE_FILTERS
              .map(
                (stage) =>
                  `<option value="${stage}" ${
                    sectionState.filters.stage === stage ? "selected" : ""
                  }>${escapeHtml(capitalize(stage))}</option>`
              )
              .join("")}
          </select>
        </label>
        <label class="map-section-toolbar__field">
          Role
          <select
            data-action="map-section-filter"
            data-section="${escapeHtml(sectionDef.key)}"
            data-filter="role"
          >
            <option value="">All roles</option>
            ${CREATURE_ROLE_FILTERS
              .map(
                (role) =>
                  `<option value="${role}" ${
                    sectionState.filters.role === role ? "selected" : ""
                  }>${escapeHtml(capitalize(role))}</option>`
              )
              .join("")}
          </select>
        </label>
        <label class="map-section-toolbar__field">
          Difficulty
          <select
            data-action="map-section-filter"
            data-section="${escapeHtml(sectionDef.key)}"
            data-filter="difficulty"
          >
            <option value="">All difficulties</option>
            ${CREATURE_DIFFICULTY_FILTERS
              .map(
                (difficulty) =>
                  `<option value="${difficulty}" ${
                    sectionState.filters.difficulty === difficulty
                      ? "selected"
                      : ""
                  }>${escapeHtml(capitalize(difficulty))}</option>`
              )
              .join("")}
          </select>
        </label>
      ` : ""}
      ${sectionDef.linkField && ui.editMode ? `
        <div class="map-section-toolbar__actions">
          <button
            class="ghost-button ghost-button--small"
            type="button"
            data-action="open-map-link-picker"
            data-map-id="${escapeHtml(ui.activeMapSection.mapId)}"
            data-collection="${escapeHtml(sectionDef.collectionKey)}"
            data-link-field="${escapeHtml(sectionDef.linkField)}"
          >
            Add Existing
          </button>
          <button
            class="ghost-button ghost-button--small"
            type="button"
            data-action="create-map-link-entity"
            data-map-id="${escapeHtml(ui.activeMapSection.mapId)}"
            data-collection="${escapeHtml(sectionDef.collectionKey)}"
            data-link-field="${escapeHtml(sectionDef.linkField)}"
          >
            Create New
          </button>
        </div>
      ` : ""}
    </div>
  `;
}

function renderMapSectionEmptyState(title, text) {
  return `
    <div class="inline-empty">
      <strong>${escapeHtml(title)}</strong>
      <p>${escapeHtml(text)}</p>
    </div>
  `;
}

function renderMapSectionBossesModal(map, sectionDef) {
  const entries = resolveMapSectionEntities(map, sectionDef, false);
  if (!entries.length) {
    return renderMapSectionEmptyState(
      "No bosses linked",
      "Attach at least one boss in edit mode to start planning this map dossier."
    );
  }

  return `
    <div class="map-section-card-grid">
      ${entries
        .map((boss) =>
          renderMapSectionBossCard(map, boss, sectionDef.collectionKey, sectionDef.linkField)
        )
        .join("")}
    </div>
  `;
}

function renderMapSectionBossCard(map, boss, collectionKey, linkField) {
  const bossMap = getMap(boss.mapId);
  const linkedTags = renderTagList(toTextArray(boss.tags).slice(0, 4));
  const isLinked = boss.__isLinked;

  return `
    <article class="map-section-item-card">
      <div class="map-section-item-card__media">
        ${renderMediaSlot("bosses", boss, {
          className: "detail-card__media",
          label: "Boss image",
          aspect: "square",
        })}
      </div>
      <div class="map-section-item-card__body">
        <h3>${escapeHtml(boss.name)}</h3>
        <p>${escapeHtml(boss.mainDanger || boss.difficultyFeel || "")}</p>
        <p><strong>Arena:</strong> ${escapeHtml(boss.arena || "—")}</p>
        <p><strong>Map:</strong> ${escapeHtml(bossMap?.name || "Unassigned")}</p>
        <div class="chip-row">${linkedTags}</div>
        <div class="map-section-actions">
          <button
            class="ghost-button ghost-button--small"
            type="button"
            data-action="open-boss"
            data-boss-id="${escapeHtml(boss.id)}"
          >
            View
          </button>
          ${ui.editMode
            ? `<button
                class="ghost-button ghost-button--small"
                type="button"
                data-action="${isLinked ? "unlink-map-entity" : "confirm-map-link"}"
                data-map-id="${escapeHtml(map.id)}"
                data-collection="${escapeHtml(collectionKey)}"
                data-entity-id="${escapeHtml(boss.id)}"
                ${!isLinked ? `data-link-field="${escapeHtml(linkField)}"` : ""}
              >
                ${isLinked ? "Unlink" : "Link"}
              </button>
              <button
                class="ghost-button ghost-button--small"
                type="button"
                data-action="quick-edit"
                data-collection="${escapeHtml(collectionKey)}"
                data-entity-id="${escapeHtml(boss.id)}"
              >
                Edit
              </button>`
            : ""}
        </div>
      </div>
    </article>
  `;
}

function renderMapSectionCreaturesModal(map, sectionDef, searchQuery) {
  const allEntries = resolveMapSectionEntities(map, sectionDef, true);
  const sectionState = getMapSectionState(sectionDef.key);
  const query = searchQuery || "";

  const filteredEntries = allEntries.filter((entry) => {
    const searchable = [
      entry.name,
      entry.shortDescription,
      toArray(entry.roleTags),
      toTextArray(entry.stages),
      entry.tameDifficulty,
      entry.tameFood,
      entry.costPayoff,
      entry.transferValue,
      entry.bossRelevance,
      entry.timeToValue,
      entry.notes,
    ]
      .flat()
      .filter(Boolean)
      .join(" ")
      .toLowerCase();

    if (query && !searchable.includes(query)) return false;

    if (sectionState.filters.stage) {
      const stages = toTextArray(entry.stages).map((item) =>
        String(item || "").toLowerCase()
      );
      if (!stages.includes(sectionState.filters.stage.toLowerCase())) return false;
    }
    if (sectionState.filters.role) {
      const roles = toTextArray(entry.roleTags).map((item) =>
        String(item || "").toLowerCase()
      );
      if (!roles.includes(sectionState.filters.role.toLowerCase())) return false;
    }
    if (sectionState.filters.difficulty) {
      const value = String(entry.tameDifficulty || "").toLowerCase();
      if (!value.includes(sectionState.filters.difficulty.toLowerCase()))
        return false;
    }

    return true;
  });

  if (!filteredEntries.length) {
    return renderMapSectionEmptyState(
      "No creatures found",
      "Adjust filters or search terms, or add creatures and link them to this map."
    );
  }

  return `
    <div class="map-data-table-wrap">
      <table class="map-data-table">
        <thead>
          <tr>
            <th>Avatar</th>
            <th>Name</th>
            <th>Tame Food</th>
            <th>Tame Method</th>
          </tr>
        </thead>
        <tbody>
          ${filteredEntries
            .map((dino) => {
              return `
                <tr>
                  <td>${renderMediaSlot("dinos", dino, {
                    className: "map-data-table__thumb map-data-table__thumb--editable",
                    label: "Creature avatar",
                    aspect: "square",
                    emptyLabel: "Upload or Add URL",
                    showActions: true,
                  })}</td>
                  <td>${escapeHtml(dino.name)}</td>
                  <td>${formatTopTameFood(dino.tameFood, 3)}</td>
                  <td>${escapeHtml(getCreatureMethodSummary(dino))}</td>
                </tr>
              `;
            })
            .join("")}
        </tbody>
      </table>
    </div>
  `;
}

function renderMapSectionResourcesModal(map, sectionDef) {
  const entries = resolveMapSectionEntities(map, sectionDef, false);
  if (!entries.length) {
    return renderMapSectionEmptyState(
      "No resources linked",
      "Link resource routes to map operations and track route risk."
    );
  }

  return `
    <div class="map-section-card-grid">
      ${entries
        .map((resource) => renderMapSectionResourceCard(map, resource, sectionDef))
        .join("")}
    </div>
  `;
}

function renderMapSectionResourceCard(map, resource, sectionDef) {
  const mapName = getMap(resource.mapId)?.name || map.name || "Map";
  return `
    <article class="map-section-item-card">
      <h3>${escapeHtml(resource.name || resource.title || "Resource route")}</h3>
      <p><strong>Type:</strong> ${escapeHtml(resource.route || resource.resource || "Route")}</p>
      <p><strong>Tool:</strong> ${escapeHtml(resource.tool || "—")}</p>
      <p><strong>Risk:</strong> ${escapeHtml(resource.risk || "—")}</p>
      <p>${escapeHtml(resource.shortDescription || resource.route || "")}</p>
      <div class="chip-row">${renderTagList(resource.tags || [mapName])}</div>
      <div class="map-section-item-card__meta">${escapeHtml(mapName)}</div>
      <div class="map-section-actions">
        <button
          class="ghost-button ghost-button--small"
          type="button"
          data-action="open-map-entity"
          data-collection="resources"
          data-entity-id="${escapeHtml(resource.id)}"
        >
          View
        </button>
        ${ui.editMode
          ? `<button
              class="ghost-button ghost-button--small"
              type="button"
              data-action="quick-edit"
              data-collection="resources"
              data-entity-id="${escapeHtml(resource.id)}"
            >
              Edit
            </button>`
          : ""}
      </div>
    </article>
  `;
}

function renderMapSectionArtifactsModal(map, sectionDef) {
  const entries = resolveMapSectionEntities(map, sectionDef, false);
  if (!entries.length) {
    return renderMapSectionEmptyState(
      "No artifacts linked",
      "Link artifact routes and cave entries to keep this map's progression path efficient."
    );
  }

  return `
    <div class="map-data-table-wrap">
      <table class="map-data-table">
        <thead>
          <tr>
            <th>Artifact</th>
            <th>Cave</th>
            <th>Difficulty</th>
            <th>Boss Usage</th>
            <th>Hazard notes</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          ${entries
            .map((artifact) => {
              const bossUsages = getBossesForEntity("bosses", artifact.id, "bosses");
              return `
                <tr>
                  <td>${escapeHtml(artifact.name || artifact.id)}</td>
                  <td>${escapeHtml(artifact.cave || "—")}</td>
                  <td>${escapeHtml(artifact.difficulty || "—")}</td>
                  <td>${bossUsages.length ? bossUsages.map((boss) => renderBossChip(boss.id)).join("") : "—"}</td>
                  <td>${escapeHtml(artifact.quickRoute || artifact.danger || "—")}</td>
                  <td class="map-data-table__actions">
                    <button
                      class="ghost-button ghost-button--small"
                      type="button"
                      data-action="open-map-entity"
                      data-collection="artifacts"
                      data-entity-id="${escapeHtml(artifact.id)}"
                    >
                      View
                    </button>
                    ${ui.editMode
                      ? `<button
                          class="ghost-button ghost-button--small"
                          type="button"
                          data-action="quick-edit"
                          data-collection="artifacts"
                          data-entity-id="${escapeHtml(artifact.id)}"
                        >
                          Edit
                        </button>`
                      : ""}
                  </td>
                </tr>
              `;
            })
            .join("")}
        </tbody>
      </table>
    </div>
  `;
}

function renderMapSectionTributeModal(map, sectionDef) {
  const entries = resolveMapSectionEntities(map, sectionDef, false);
  if (!entries.length) {
    return renderMapSectionEmptyState(
      "No tribute items linked",
      "Attach tribute entities used by map bosses or your route plan."
    );
  }

  return `
    <div class="map-data-table-wrap">
      <table class="map-data-table">
        <thead>
          <tr>
            <th>Item</th>
            <th>Quantity</th>
            <th>Source</th>
            <th>Linked boss usage</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          ${entries
            .map((tribute) => {
              const bossUsages = getBossesForEntity("tributeItems", tribute.id, "tributeItems");
              return `
                <tr>
                  <td>${escapeHtml(tribute.name || tribute.id)}</td>
                  <td>${escapeHtml(tribute.estimate || tribute.quantity || "—")}</td>
                  <td>${escapeHtml(tribute.sourceCreature || tribute.sourceMethod || "—")}</td>
                  <td>${bossUsages.length ? bossUsages.map((boss) => renderBossChip(boss.id)).join("") : "—"}</td>
                  <td class="map-data-table__actions">
                    <button
                      class="ghost-button ghost-button--small"
                      type="button"
                      data-action="open-map-entity"
                      data-collection="tributeItems"
                      data-entity-id="${escapeHtml(tribute.id)}"
                    >
                      View
                    </button>
                    ${ui.editMode
                      ? `<button
                          class="ghost-button ghost-button--small"
                          type="button"
                          data-action="quick-edit"
                          data-collection="tributeItems"
                          data-entity-id="${escapeHtml(tribute.id)}"
                        >
                          Edit
                        </button>`
                      : ""}
                  </td>
                </tr>
              `;
            })
            .join("")}
        </tbody>
      </table>
    </div>
  `;
}

function renderMapSectionBaseSpotsModal(map, sectionDef) {
  const entries = resolveMapSectionEntities(map, sectionDef, false);
  if (!entries.length) {
    return renderMapSectionEmptyState(
      "No base spots linked",
      "Add base infrastructure positions as base spots and link them to this map."
    );
  }

  return `
    <div class="map-section-card-grid">
      ${entries
        .map((spot) => {
          const labels = [spot.type, ...toArray(spot.tags)].filter(Boolean);
          return `
            <article class="map-section-item-card">
              <h3>${escapeHtml(spot.title || spot.name || "Base spot")}</h3>
              <p><strong>Type:</strong> ${escapeHtml(spot.type || "—")}</p>
              <p><strong>Strengths:</strong> ${escapeHtml((spot.strengths || "").trim() || "—")}</p>
              <p><strong>Weaknesses:</strong> ${escapeHtml((spot.weaknesses || "").trim() || "—")}</p>
              <div class="chip-row">${renderTagList(labels)}</div>
              <div class="map-section-actions">
                <button
                  class="ghost-button ghost-button--small"
                  type="button"
                  data-action="open-map-entity"
                  data-collection="baseSpots"
                  data-entity-id="${escapeHtml(spot.id)}"
                >
                  View
                </button>
                ${ui.editMode
                  ? `<button
                      class="ghost-button ghost-button--small"
                      type="button"
                      data-action="quick-edit"
                      data-collection="baseSpots"
                      data-entity-id="${escapeHtml(spot.id)}"
                    >
                      Edit
                    </button>`
                  : ""}
              </div>
            </article>
          `;
        })
        .join("")}
    </div>
  `;
}

function renderMapSectionProgressionModal(map) {
  const entries = toArray(map.progression);
  const phaseLookup = new Map(
    entries.map((entry) => [entry.stage, entry])
  );

  if (!entries.length) {
    return renderMapSectionEmptyState(
      "No progression set",
      "Populate progression phases in edit mode through the map model."
    );
  }

  return `
    <div class="map-progression-board">
      ${MAP_PROGRESS_PHASES.map((phase) => {
        const phaseData = phaseLookup.get(phase) || {};
        return `
          <article class="map-phase-card">
            <p class="eyebrow">${escapeHtml(phase)}</p>
            <h3>${escapeHtml(phaseData.focus || "Unset focus")}</h3>
            <div class="chip-row">${renderTagList(phaseData.bullets || ["No action points yet"])}</div>
          </article>
        `;
      }).join("")}
    </div>
  `;
}

function renderMapSectionGalleryModal(map, sectionDef) {
  const entries = resolveMapSectionEntities(map, sectionDef, false);
  if (!entries.length) {
    return renderMapSectionEmptyState(
      "No gallery assets",
      "Attach gallery items to this map so composition and terrain notes stay visual."
    );
  }

  return `
    <div class="map-section-gallery-grid">
      ${entries
        .map((asset) => {
          return `
            <article class="map-section-item-card">
              ${renderMediaSlot("galleryMedia", asset, {
                className: "detail-card__media",
                label: "Gallery item",
                aspect: "poster",
              })}
              <h3>${escapeHtml(asset.name || asset.title || "Gallery asset")}</h3>
              <p>${escapeHtml(asset.caption || asset.shortDescription || "")}</p>
              <div class="map-section-item-card__meta">
                <span>${escapeHtml(asset.type || "Reference")}</span>
                <span>${escapeHtml(asset.location || map.name || "Map")}</span>
              </div>
              <div class="map-section-actions">
                <button
                  class="ghost-button ghost-button--small"
                  type="button"
                  data-action="open-map-entity"
                  data-collection="galleryMedia"
                  data-entity-id="${escapeHtml(asset.id)}"
                >
                  View
                </button>
                ${ui.editMode
                  ? `<button
                      class="ghost-button ghost-button--small"
                      type="button"
                      data-action="quick-edit"
                      data-collection="galleryMedia"
                      data-entity-id="${escapeHtml(asset.id)}"
                    >
                      Edit
                    </button>`
                  : ""}
              </div>
            </article>
          `;
        })
        .join("")}
    </div>
  `;
}

function renderMapSectionSourcesModal(map, sectionDef) {
  const entries = resolveMapSectionEntities(map, sectionDef, false);
  if (!entries.length) {
    return renderMapSectionEmptyState(
      "No source links",
      "Link references to validate this map route and progression logic."
    );
  }

  return `
    <div class="map-data-table-wrap">
      <table class="map-data-table">
        <thead>
          <tr>
            <th>Source</th>
            <th>Type</th>
            <th>URL</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          ${entries
            .map((source) => {
              const sourceUrl = source.url ? `<a class="text-link" href="${escapeAttribute(
                source.url
              )}" target="_blank" rel="noopener noreferrer">${escapeHtml(source.url)}</a>` : "";
              return `
                <tr>
                  <td>${escapeHtml(source.title || "Reference")}</td>
                  <td>${escapeHtml(source.type || "Reference")}</td>
                  <td>${sourceUrl || "—"}</td>
                  <td class="map-data-table__actions">
                    <button
                      class="ghost-button ghost-button--small"
                      type="button"
                      data-action="open-map-entity"
                      data-collection="references"
                      data-entity-id="${escapeHtml(source.id)}"
                    >
                      View
                    </button>
                    ${ui.editMode
                      ? `<button
                          class="ghost-button ghost-button--small"
                          type="button"
                          data-action="quick-edit"
                          data-collection="references"
                          data-entity-id="${escapeHtml(source.id)}"
                        >
                          Edit
                        </button>`
                      : ""}
                  </td>
                </tr>
              `;
            })
            .join("")}
        </tbody>
      </table>
    </div>
  `;
}

function getBossesForEntity(collection, entityId, arrayField = "bosses") {
  return (state.bosses || [])
    .filter((boss) => toTextArray(boss?.[arrayField]).includes(entityId))
    .slice(0, 3);
}

function renderMapEntityModal() {
  const active = ui.activeMapEntity;
  if (!active?.collection || !active.entityId) return "";

  const entity = findEntity(state, active.collection, active.entityId);
  if (!entity) {
    ui.activeMapEntity = null;
    return "";
  }

  const rows = Object.entries(entity)
    .filter(([key, value]) =>
      !["id", "media", "relatedIds", "tags"].includes(key) &&
      value !== "" &&
      value != null
    )
    .map(([key, value]) => `
      <tr>
        <td><strong>${escapeHtml(key)}</strong></td>
        <td>${escapeHtml(
          Array.isArray(value) ? value.map((entry) => String(entry)).join(", ") : toTextList(value)
        )}</td>
      </tr>
    `)
    .join("");

  return `
    <div class="modal-backdrop" data-action="close-modal">
      <div class="modal-panel modal-panel--map-section modal-panel--compact" role="dialog" aria-modal="true">
        <div class="modal-panel__header">
          <div>
            <p class="eyebrow">Map Section Entry</p>
            <h2>${escapeHtml(entity.name || entity.title || active.entityId)}</h2>
            <p>${escapeHtml(entity.shortDescription || entity.difficultyFeel || entity.citation || "")}</p>
          </div>
          <button class="ghost-button" type="button" data-action="close-modal">Close</button>
        </div>
        <div class="modal-panel__body">
          <div class="map-entity-meta">
            ${renderTagList(entity.tags || [])}
            ${entity.media?.src ? `<img class="map-entity-image" src="${escapeAttribute(entity.media.src)}" alt="${escapeHtml(entity.name || entity.title || "entity image")}" />` : ""}
          </div>
          <div class="map-data-table-wrap">
            <table class="map-data-table">
              <tbody>${rows || ""}</tbody>
            </table>
          </div>
          <div class="admin-form__actions">
            <button
              class="hero-button hero-button--primary"
              type="button"
              data-action="quick-edit"
              data-collection="${escapeHtml(active.collection)}"
              data-entity-id="${escapeHtml(active.entityId)}"
            >
              Edit
            </button>
          </div>
        </div>
      </div>
    </div>
  `;
}

function renderMapSummaryPanel(map) {
  return `
    <article class="stack-panel map-panel">
      <div class="section-heading section-heading--compact">
        <div>
          <h3>Summary</h3>
          <p>Operational summary tied to this map only.</p>
        </div>
      </div>
      <div class="focus-card-grid">
        <article class="focus-card">
          <p class="eyebrow">Map role</p>
          <h3>${escapeHtml(map.role || "Undefined")}</h3>
          <p>${escapeHtml(map.whyPlay || map.shortDescription || "")}</p>
        </article>
        <article class="focus-card">
          <p class="eyebrow">Story location</p>
          <h3>${escapeHtml(map.story?.place || "Operational progression map")}</h3>
          <p>${escapeHtml(map.story?.objective || "")}</p>
        </article>
        <article class="focus-card">
          <p class="eyebrow">Move forward to</p>
          <h3>${escapeHtml(map.story?.next || "Next map in progression")}</h3>
          <p>${escapeHtml(map.transferOut?.leaveWhen || "Follow your transfer signal.")}</p>
        </article>
      </div>
    </article>
  `;
}

function renderMapFeaturesPanel(map) {
  const features = [
    ...(map.features || []),
    `Access: ${escapeHtml(map.classification?.access || "Unknown")}`,
    `Type: ${escapeHtml(map.classification?.type || "Unknown")}`,
    ...(map.tags || []),
  ];

  return `
    <article class="stack-panel map-panel">
      <div class="section-heading section-heading--compact">
        <div>
          <h3>Features</h3>
          <p>Short operational notes. Keep concise and map-specific.</p>
        </div>
      </div>
      <div class="focus-card-grid">
        <article class="focus-card">
          <p class="eyebrow">Vibe</p>
          <h3>${escapeHtml(map.vibe || "")}</h3>
          <p>${escapeHtml(map.shortDescription || "")}</p>
        </article>
        <article class="focus-card">
          <p class="eyebrow">Feature flags</p>
          <div class="chip-row">${renderTagList(features.filter(Boolean))}</div>
        </article>
      </div>
    </article>
  `;
}

function renderMapKeyCreaturesPanel(map) {
  return renderLinkedEntityPanel({
    map,
    title: "Key Creatures",
    collectionKey: "dinos",
    linkField: "tameIds",
    emptyTitle: "No linked creatures yet",
    emptyText: "Link key dinos required for this map's tame stack and boss support.",
    cardClass: "dino-gallery-grid",
    renderCard: (dino) => renderDinoCard(dino, true),
  });
}

function renderMapResourcePanel(map) {
  return renderLinkedEntityPanel({
    map,
    title: "Resources",
    collectionKey: "resources",
    linkField: "resourceIds",
    emptyTitle: "No linked resources yet",
    emptyText:
      "Link resources and then keep route + risk + tool notes in the shared resource library.",
    renderCard: (resource) => renderResourceCard(resource),
  });
}

function renderMapArtifactsPanel(map) {
  return renderLinkedEntityPanel({
    map,
    title: "Artifacts & Caves",
    collectionKey: "artifacts",
    linkField: "artifactIds",
    emptyTitle: "No artifacts linked",
    emptyText:
      "Attach artifact library entries and update cave metadata from local operations notes.",
    renderCard: (artifact) => {
      const caveInfo = toArray(map.caveRuns).find((run) => run.artifactId === artifact.id) || {};
      const bossIds = [...toArray(caveInfo.bossIds), ...toArray(artifact.bosses)];
      return `
        <article class="detail-card detail-card--artifact">
          ${renderMediaSlot("artifacts", artifact, {
            className: "detail-card__media",
            label: "Artifact Image",
            aspect: "square",
          })}
          <span class="detail-card__label">${escapeHtml(
            caveInfo.cave || artifact.cave || ""
          )}</span>
          <h3>${escapeHtml(artifact.name)}</h3>
          <p>${escapeHtml(
            caveInfo.danger || artifact.quickRoute || artifact.difficulty || ""
          )}</p>
          <div class="chip-row">
            ${(bossIds || []).map(renderBossChip).join("")}
          </div>
        </article>
      `;
    },
  });
}

function renderMapTributePanel(map) {
  return renderLinkedEntityPanel({
    map,
    title: "Tribute Items",
    collectionKey: "tributeItems",
    linkField: "tributeIds",
    emptyTitle: "No tribute lines linked",
    emptyText:
      "Attach tribute items your bosses and transfer plan requires on this map.",
    renderCard: renderTributeCard,
    cardClass: "mini-card-grid",
  });
}

function renderMapProgressionPanel(map) {
  const stages = toArray(map.progression);
  if (!stages.length) {
    return `
      <article class="stack-panel map-panel">
        <div class="section-heading section-heading--compact">
          <div>
            <h3>Progression</h3>
            <p>No progression blocks yet.</p>
          </div>
        </div>
      </article>
    `;
  }

  return `
    <article class="stack-panel map-panel">
      <div class="section-heading section-heading--compact">
        <div>
          <h3>Progression</h3>
          <p>Phase-by-phase execution plan for this map.</p>
        </div>
      </div>
      <div class="phase-grid">
        ${stages
          .map(
            (phase) => `
              <article class="phase-card">
                <p class="eyebrow">${escapeHtml(phase.stage)}</p>
                <h3>${escapeHtml(phase.focus)}</h3>
                <div class="chip-row">${renderTagList(phase.bullets || [])}</div>
              </article>
            `
          )
          .join("")}
      </div>
    </article>
  `;
}

function renderMapGalleryPanel(map) {
  return renderLinkedEntityPanel({
    map,
    title: "Gallery",
    collectionKey: "galleryMedia",
    linkField: "galleryIds",
    emptyTitle: "No gallery media yet",
    emptyText: "Attach photos/screenshots to enrich the operational atlas for this map.",
    renderCard: renderGalleryCard,
  });
}

function renderMapSourcesPanel(map) {
  return renderLinkedEntityPanel({
    map,
    title: "Sources",
    collectionKey: "references",
    linkField: "sourceIds",
    emptyTitle: "No source references yet",
    emptyText: "Link references that validate route logic, lore details, or timing notes.",
    renderCard: renderReferenceCard,
  });
}

function renderMapBossPrepPanel(map) {
  const bosses = getMapLinkIds(map, "bosses")
    .map((id) => getBoss(id))
    .filter(Boolean);
  if (!bosses.length) {
    return renderMapEmptyLinkedPanel(
      "Bosses",
      "No bosses linked",
      "Attach bosses from the boss planner and keep each boss prep ready."
    );
  }

  return renderLinkedEntityPanel({
    map,
    title: "Bosses",
    collectionKey: "bosses",
    linkField: "bossIds",
    emptyTitle: "No bosses linked",
    emptyText: "Attach bosses from the boss planner and keep each boss prep ready.",
    renderCard: (boss) => {
      const map = getMap(boss.mapId);
      return `
        <article class="boss-prep-card">
          <div class="boss-prep-card__head">
            <div>
              <p class="eyebrow">${escapeHtml(map?.name || "Unknown map")}</p>
              <h3>${escapeHtml(boss.name)}</h3>
            </div>
            ${ui.editMode ? `<button class="ghost-button ghost-button--small" type="button" data-action="open-boss" data-boss-id="${boss.id}">Open</button>` : ""}
          </div>
          <p>${escapeHtml(boss.mainDanger)}</p>
          <div class="chip-row">${renderTagList(boss.tags || [])}</div>
          <div class="stat-stack">
            ${(boss.stats || [])
              .slice(0, 3)
              .map(
                (stat) =>
                  `<span><strong>${escapeHtml(stat.label)}</strong> ${escapeHtml(stat.value)}</span>`
              )
              .join("")}
          </div>
          ${ui.editMode ? `<button class=\"ghost-button ghost-button--small\" type=\"button\" data-action=\"open-boss\" data-boss-id=\"${escapeHtml(boss.id)}\">Open</button>` : ""}
        </article>
      `;
    },
  });
}

function renderMapEmptyLinkedPanel(title, header, text) {
  return `
    <article class="stack-panel map-panel">
      <div class="section-heading section-heading--compact">
        <div>
          <h3>${escapeHtml(title)}</h3>
          <p>${escapeHtml(text)}</p>
        </div>
      </div>
      <div class="empty-state">${escapeHtml(header)}</div>
    </article>
  `;
}

function renderLinkedEntityPanel({
  map,
  title,
  collectionKey,
  linkField,
  emptyTitle,
  emptyText,
  renderCard,
  cardClass = "mini-card-grid",
}) {
  const ids = getMapLinkIds(map, collectionKey, linkField);
  const items = ids.map((id) => findEntity(state, collectionKey, id)).filter(Boolean);

  return `
    <article class="stack-panel map-panel">
      <div class="section-heading section-heading--compact map-panel-heading">
        <div>
          <h3>${escapeHtml(title)}</h3>
          <p>${escapeHtml(emptyText)}</p>
        </div>
        <div class="map-panel-actions">
          ${renderMapLinkActions({ map, collectionKey, linkField })}
        </div>
      </div>
      ${
        !items.length
          ? `<div class="inline-empty">${escapeHtml(emptyTitle)}</div>`
          : `<div class="${escapeHtml(cardClass)}">
              ${items
                .map((item) => renderLinkedCardShell(item, renderCard(item), map, collectionKey))
                .join("")}
            </div>`
      }
    </article>
  `;
}

function renderLinkedCardShell(item, cardHtml, map, collectionKey) {
  const editButton = ui.editMode
    ? `<button
        class="ghost-button ghost-button--small"
        type="button"
        data-action="quick-edit"
        data-collection="${collectionKey}"
        data-entity-id="${escapeHtml(item.id)}"
      >
        Quick Edit
      </button>`
    : "";
  const removeButton = ui.editMode
    ? `<button
        class="ghost-button ghost-button--small"
        type="button"
        data-action="unlink-map-entity"
        data-map-id="${escapeHtml(map.id)}"
        data-collection="${collectionKey}"
        data-entity-id="${escapeHtml(item.id)}"
      >
        Remove Link
      </button>`
    : "";

  return cardHtml.includes("map-panel__card-actions")
    ? cardHtml
    : `
      <div class="map-linked-card">
        ${cardHtml}
        ${editButton || removeButton ? `<div class="map-linked-card__actions">${editButton}${removeButton}</div>` : ""}
      </div>
    `;
}

function renderMapLinkActions({ map, collectionKey, linkField }) {
  const actions = [];
  if (ui.editMode) {
    actions.push(
      `<button
        class="ghost-button ghost-button--small"
        type="button"
        data-action="open-map-link-picker"
        data-map-id="${escapeHtml(map.id)}"
        data-collection="${collectionKey}"
        data-link-field="${escapeHtml(linkField)}"
      >
        Add Existing
      </button>`
    );
    actions.push(
      `<button
        class="ghost-button ghost-button--small"
        type="button"
        data-action="create-map-link-entity"
        data-map-id="${escapeHtml(map.id)}"
        data-collection="${collectionKey}"
        data-link-field="${escapeHtml(linkField)}"
      >
        Create New
      </button>`
    );
  }
  return actions.join("");
}

function renderMapTamePlanner(map) {
  const dinos = toArray(map?.tameIds)
    .map((id) => getDino(id))
    .filter(Boolean);
  if (!dinos.length) {
    return renderEmptyState(
      "No tame notes yet",
      "Use edit mode to add map-specific tame cards and route notes."
    );
  }

  return `
    <div class="dino-gallery-shell">
      <div class="dino-gallery-grid">
        ${dinos.map((dino) => renderDinoCard(dino, true)).join("")}
      </div>
    </div>
  `;
}

function renderMapArtifacts(map) {
  const caveRuns = toArray(map?.caveRuns);

  if (!caveRuns.length) {
    return renderEmptyState(
      "Field notes pending",
      "This map can hold artifact and cave routes here when you are ready to document them."
    );
  }

  return `
    <div class="mini-card-grid">
      ${caveRuns
        .map((run) => {
          const artifact = getArtifact(run.artifactId);
          return `
            <article class="detail-card detail-card--artifact">
              ${artifact
                ? renderMediaSlot("artifacts", artifact, {
                    className: "detail-card__media",
                    label: "Artifact",
                    aspect: "square",
                  })
                : ""}
              <span class="detail-card__label">${escapeHtml(run.cave)}</span>
              <h3>${escapeHtml(artifact?.name || run.artifactId)}</h3>
              <p>${escapeHtml(run.danger)}</p>
              <div class="stat-stack">
                <span><strong>Mount</strong> ${escapeHtml(run.mount)}</span>
                <span><strong>Gear</strong> ${escapeHtml(run.gear)}</span>
                <span><strong>Difficulty</strong> ${escapeHtml(run.difficulty)}</span>
              </div>
              <div class="chip-row">
                ${toArray(run?.bossIds)
                  .map((bossId) => renderBossChip(bossId))
                  .join("")}
              </div>
            </article>
          `;
        })
        .join("")}
    </div>
  `;
}

function renderMapBossPrep(map) {
  const bosses = toArray(map?.bossIds)
    .map((id) => getBoss(id))
    .filter(Boolean);
  if (!bosses.length) {
    return renderEmptyState(
      "Boss dossier not filled yet",
      "This map still has room for your own boss page or progression notes."
    );
  }

  return `
    <div class="boss-prep-grid">
      ${bosses
        .map(
          (boss) => `
            <article class="boss-prep-card">
              <div class="boss-prep-card__head">
                <div>
                  <p class="eyebrow">${escapeHtml(boss.arena)}</p>
                  <h3>${escapeHtml(boss.name)}</h3>
                </div>
                <button
                  class="ghost-button ghost-button--small"
                  type="button"
                  data-action="open-boss"
                  data-boss-id="${boss.id}"
                >
                  Open
                </button>
              </div>
              <p>${escapeHtml(boss.mainDanger)}</p>
              <div class="chip-row">${renderTagList(boss.tags || [])}</div>
              <div class="stat-stack">
                ${(boss.stats || [])
                  .slice(0, 4)
                  .map(
                    (stat) => `
                      <span><strong>${escapeHtml(stat.label)}</strong> ${escapeHtml(stat.value)}</span>
                    `
                  )
                  .join("")}
              </div>
            </article>
          `
        )
        .join("")}
    </div>
  `;
}

function renderBaseSpots(baseSpotIds) {
  const spots = toArray(baseSpotIds)
    .map((id) => getBaseSpot(id))
    .filter(Boolean);
  if (!spots.length) {
    return renderEmptyState(
      "Base spots not documented yet",
      "Add main base, crafting base, forward base, breeding base, and staging base records in edit mode."
    );
  }

  return `
    <div class="mini-card-grid">
      ${spots.map((spot) => renderBaseSpotCard(spot)).join("")}
    </div>
  `;
}

function renderDinoCard(dino, compact = false) {
  const roleTags = Array.isArray(dino.roleTags) ? dino.roleTags : [];
  const stages = Array.isArray(dino.stages) ? dino.stages : [];
  const hasLongForm =
    roleTags.length ||
    stages.length ||
    String(dino.tameDifficulty || "").trim() ||
    String(dino.timeToValue || "").trim() ||
    String(dino.costPayoff || "").trim() ||
    String(dino.transferValue || "").trim() ||
    String(dino.bossRelevance || "").trim() ||
    String(dino.shortDescription || "").trim() ||
    String(dino.notes || "").trim();

  if (compact || !hasLongForm) {
    return `
      <article class="dino-card dino-card--name-only ${compact ? "dino-card--compact" : ""}">
        ${renderMediaSlot("dinos", dino, {
          className: "dino-card__media",
          label: "Creature Image",
          aspect: "square",
        })}
        <div class="dino-card__body">
          <h3>${escapeHtml(dino.name)}</h3>
        </div>
      </article>
    `;
  }

  return `
    <article class="dino-card ${compact ? "dino-card--compact" : ""}">
      ${renderMediaSlot("dinos", dino, {
        className: "dino-card__media",
        label: "Dino Image",
        aspect: "square",
      })}
      <div class="dino-card__body">
        <h3>${escapeHtml(dino.name)}</h3>
        <div class="chip-row">${renderTagList(dino.roleTags)}</div>
        <div class="chip-row chip-row--subtle">${renderTagList(toArray(dino?.stages).map(capitalize))}</div>
        <div class="stat-stack">
          <span><strong>Tame Difficulty</strong> ${escapeHtml(dino.tameDifficulty)}</span>
          <span><strong>Time to Value</strong> ${escapeHtml(dino.timeToValue)}</span>
          <span><strong>Cost vs Payoff</strong> ${escapeHtml(dino.costPayoff)}</span>
          <span><strong>Transfer Value</strong> ${escapeHtml(dino.transferValue)}</span>
          <span><strong>Boss Relevance</strong> ${escapeHtml(dino.bossRelevance)}</span>
        </div>
        <p>${escapeHtml(dino.shortDescription || dino.notes)}</p>
      </div>
    </article>
  `;
}

function renderArtifactCard(artifact) {
  return `
    <article class="detail-card detail-card--artifact">
      ${renderMediaSlot("artifacts", artifact, {
        className: "detail-card__media",
        label: "Artifact Image",
        aspect: "square",
      })}
      <span class="detail-card__label">${escapeHtml(getMap(artifact.mapId)?.name || "")}</span>
      <h3>${escapeHtml(artifact.name)}</h3>
      <p>${escapeHtml(artifact.quickRoute)}</p>
      <div class="chip-row">${renderTagList([artifact.cave, artifact.difficulty])}</div>
    </article>
  `;
}

function renderTributeCard(tribute) {
  return `
    <article class="detail-card">
      ${renderMediaSlot("tributeItems", tribute, {
        className: "detail-card__media",
        label: "Tribute Image",
        aspect: "square",
      })}
      <span class="detail-card__label">${escapeHtml(tribute.sourceCreature)}</span>
      <h3>${escapeHtml(tribute.name)}</h3>
      <p>${escapeHtml(tribute.sourceMethod)}</p>
      <div class="chip-row">${renderTagList([tribute.where, tribute.estimate])}</div>
    </article>
  `;
}

function renderResourceCard(resource) {
  const routeMap = getMap(resource.mapId);
  return `
    <article class="detail-card">
      ${renderMediaSlot("resources", resource, {
        className: "detail-card__media",
        label: "Resource Route",
        aspect: "square",
      })}
      <span class="detail-card__label">${escapeHtml(routeMap?.name || resource.mapId || "Resource route")}</span>
      <h3>${escapeHtml(resource.name || resource.title || "Resource")}</h3>
      <p>${escapeHtml(resource.route || resource.shortDescription || "")}</p>
      <div class="chip-row">
        ${renderTagList([
          resource.tool,
          resource.risk,
          ...(resource.tags || []),
        ])}
      </div>
    </article>
  `;
}

function renderGalleryCard(mediaItem) {
  const map = getMap(mediaItem.mapId);
  return `
    <article class="detail-card">
      ${renderMediaSlot("galleryMedia", mediaItem, {
        className: "detail-card__media",
        label: "Gallery Item",
        aspect: "poster",
      })}
      <span class="detail-card__label">${escapeHtml(
        mediaItem.type || mediaItem.location || "Gallery"
      )}</span>
      <h3>${escapeHtml(mediaItem.name || mediaItem.title || "Gallery asset")}</h3>
      <p>${escapeHtml(mediaItem.caption || mediaItem.shortDescription || "")}</p>
      <div class="chip-row">
        ${renderTagList([mediaItem.location, map?.name || mediaItem.mapId || ""]) }
      </div>
    </article>
  `;
}

function renderReferenceCard(reference) {
  const mapNames = (reference.mapIds || []).map((mapId) => getMap(mapId)?.name).filter(Boolean);
  const href = reference.url || "";
  const isSafeUrl = /^https?:\/\//i.test(href);
  return `
    <article class="detail-card">
      <span class="detail-card__label">${escapeHtml(reference.type || "Reference")}</span>
      <h3>${escapeHtml(reference.title || reference.url || "Reference")}</h3>
      <p>${escapeHtml(reference.citation || reference.shortDescription || "")}</p>
      ${isSafeUrl ? `<a class="text-link" href="${escapeAttribute(href)}" target="_blank" rel="noopener noreferrer">Open source</a>` : ""}
      ${mapNames.length ? `<div class="chip-row">${mapNames.map((name) => `<span class="chip">${escapeHtml(name)}</span>`).join("")}</div>` : ""}
    </article>
  `;
}

function renderItemCard(item) {
  return `
    <article class="detail-card">
      ${renderMediaSlot("items", item, {
        className: "detail-card__media",
        label: "Item Image",
        aspect: "square",
      })}
      <div class="chip-row">${renderTagList(item.tags || [])}</div>
      <h3>${escapeHtml(item.name)}</h3>
      <p>${escapeHtml(item.shortDescription)}</p>
    </article>
  `;
}

function renderBaseSpotCard(spot) {
  return `
    <article class="detail-card">
      ${renderMediaSlot("baseSpots", spot, {
        className: "detail-card__media",
        label: "Base Spot",
        aspect: "poster",
      })}
      <span class="detail-card__label">${escapeHtml(spot.type)}</span>
      <h3>${escapeHtml(spot.title)}</h3>
      <p>${escapeHtml(spot.shortDescription)}</p>
      <div class="chip-row">${renderTagList(spot.tags)}</div>
    </article>
  `;
}

function renderBossChip(bossId) {
  const boss = getBoss(bossId);
  if (!boss) return "";
  return `
    <button
      class="chip chip--button"
      type="button"
      data-action="open-boss"
      data-boss-id="${boss.id}"
    >
      ${escapeHtml(boss.name)}
    </button>
  `;
}

function renderMediaSlot(collectionKey, entity, options = {}) {
  const aspectClass = options.aspect ? `media-slot--${options.aspect}` : "";
  const toneClass = entity.media?.tone ? `tone-${entity.media.tone}` : "tone-bronze";
  const hasImage = Boolean(entity.media?.src);
  const title = escapeHtml(entity.name || entity.title || options.label || "Image");
  const placeholderLabel = escapeHtml(options.placeholderLabel || entity.media?.alt || title);
  const emptyLabel = escapeHtml(options.emptyLabel ?? "No image bound yet");
  const showImageTools = options.showActions ?? ui.editMode;
  const clickableUpload = showImageTools && collectionKey && entity.id;
  const slotAction = clickableUpload
    ? `data-action="image-upload" data-collection="${escapeHtml(
        collectionKey
      )}" data-entity-id="${escapeHtml(entity.id)}" aria-label="Upload image for ${title}"`
    : "";

  return `
    <div
      class="media-slot ${options.className || ""} ${aspectClass} ${toneClass} ${
        clickableUpload ? "media-slot--uploadable" : ""
      }"
      ${slotAction}
    >
      ${
        hasImage
          ? `<img src="${escapeAttribute(entity.media.src)}" alt="${title}" loading="lazy" />`
          : `
            <div class="media-slot__placeholder">
              <span>${placeholderLabel}</span>
              ${emptyLabel ? `<small>${emptyLabel}</small>` : ""}
            </div>
          `
      }
      <div class="media-slot__shade"></div>
      ${
        showImageTools
          ? `
            <div class="media-slot__actions">
              <button
                class="ghost-button ghost-button--small"
                type="button"
                data-action="image-url"
                data-collection="${collectionKey}"
                data-entity-id="${entity.id}"
              >
                Add URL
              </button>
              <button
                class="ghost-button ghost-button--small"
                type="button"
                data-action="image-upload"
                data-collection="${collectionKey}"
                data-entity-id="${entity.id}"
              >
                Upload
              </button>
              ${
                hasImage
                  ? `
                    <button
                      class="ghost-button ghost-button--small"
                      type="button"
                      data-action="image-remove"
                      data-collection="${collectionKey}"
                      data-entity-id="${entity.id}"
                    >
                      Remove
                    </button>
                  `
                  : ""
              }
            </div>
          `
          : ""
      }
    </div>
  `;
}

function renderAdminDrawer() {
  const collectionKey = ui.admin.collectionKey;
  const collection = state[collectionKey] || [];
  const currentEntity =
    collection.find((entry) => entry.id === ui.admin.entityId) || collection[0] || null;
  const isNew = ui.admin.entityId === "__new__";
  const entity = isNew ? createBlankEntity(collectionKey) : currentEntity;
  const titleValue = entity.name || entity.title || "";
  const shortValue =
    entity.shortDescription ||
    entity.difficultyFeel ||
    entity.vibe ||
    entity.notes ||
    "";
  const tagsValue = toTextList(entity.tags || entity.roleTags);
  const relatedValue = toTextList(
    entity.relatedIds || entity.artifacts || entity.tributeItems
  );
  const extraFields = renderAdminExtraFields(collectionKey, entity);
  const suppressAux = !!extraFields;
  const auxA =
    entity.mapId ||
    entity.type ||
    entity.role ||
    entity.sourceCreature ||
    entity.classification?.type ||
    "";
  const auxB =
    toTextList(entity.stages) ||
    entity.access ||
    entity.classification?.access ||
    entity.where ||
    entity.arena ||
    "";

  return `
    <div class="admin-drawer__inner">
      <div class="admin-drawer__header">
        <div>
          <p class="eyebrow">Edit Mode</p>
          <h2>Atlas Admin</h2>
          <p>All image slots are editable. Data saves locally in this browser profile.</p>
        </div>
        <button class="ghost-button" type="button" data-action="toggle-admin">Close</button>
      </div>

      <div class="admin-type-row">
        ${ENTITY_TYPES.map(
          (entry) => `
            <button
              type="button"
              class="chip chip--button ${
                collectionKey === entry.key ? "chip--active" : ""
              }"
              data-action="admin-collection"
              data-collection="${entry.key}"
            >
              ${escapeHtml(entry.label)}
            </button>
          `
        ).join("")}
      </div>

      <div class="admin-entity-select">
        <label>
          Existing ${escapeHtml(collectionLabels[collectionKey])}
          <select id="adminEntitySelect">
            <option value="__new__">Create New</option>
            ${collection
              .map(
                (entry) => `
                  <option value="${entry.id}" ${
                    !isNew && entry.id === entity.id ? "selected" : ""
                  }>
                    ${escapeHtml(entry.name || entry.title || entry.id)}
                  </option>
                `
              )
              .join("")}
          </select>
        </label>
      </div>

      <form id="adminForm" class="admin-form">
        <input type="hidden" name="collectionKey" value="${collectionKey}" />
        <label>
          ID
          <input name="id" value="${escapeHtml(entity.id || "")}" placeholder="the-island" required />
        </label>
        <label>
          Title / Name
          <input name="title" value="${escapeHtml(titleValue)}" placeholder="Entity title" required />
        </label>
        <label>
          Short Description
          <textarea name="shortDescription" rows="3" placeholder="Short readable summary">${escapeHtml(
            shortValue
          )}</textarea>
        </label>
        <label>
          Tags / Roles
          <input name="tags" value="${escapeHtml(tagsValue)}" placeholder="Story, Free, Boss Core" />
        </label>
        <label>
          Related Links
          <input name="relatedIds" value="${escapeHtml(
            relatedValue
          )}" placeholder="boss-id, artifact-id, dino-id" />
        </label>
        ${!suppressAux ? `
          <label>
            Auxiliary Field A
            <input
              name="auxA"
              value="${escapeHtml(auxA)}"
              placeholder="${escapeHtml(getAuxPlaceholderA(collectionKey))}"
            />
          </label>
          <label>
            Auxiliary Field B
            <input
              name="auxB"
              value="${escapeHtml(auxB)}"
              placeholder="${escapeHtml(getAuxPlaceholderB(collectionKey))}"
            />
          </label>
        ` : ""}
        ${extraFields}
        <div class="admin-form__media-tools">
          <span class="admin-form__media-label">Image Tools</span>
          ${
            entity.id
              ? `
                <button
                  type="button"
                  class="ghost-button ghost-button--small"
                  data-action="image-url"
                  data-collection="${collectionKey}"
                  data-entity-id="${entity.id}"
                >
                  Add image by URL
                </button>
                <button
                  type="button"
                  class="ghost-button ghost-button--small"
                  data-action="image-upload"
                  data-collection="${collectionKey}"
                  data-entity-id="${entity.id}"
                >
                  Upload local
                </button>
                <button
                  type="button"
                  class="ghost-button ghost-button--small"
                  data-action="image-remove"
                  data-collection="${collectionKey}"
                  data-entity-id="${entity.id}"
                >
                  Remove image
                </button>
              `
              : `<span class="admin-form__hint">Save the entity once to bind media tools cleanly.</span>`
          }
        </div>
        <div class="admin-form__actions">
          <button class="hero-button hero-button--primary" type="submit">Save Entry</button>
          <button class="ghost-button" type="button" data-action="export-state">Export Atlas Data</button>
          <button class="ghost-button" type="button" data-action="import-state">Import Atlas Data</button>
          <button class="ghost-button" type="button" data-action="reset-data">Reset Local Data</button>
        </div>
      </form>
    </div>
  `;
}

function renderAdminExtraFields(collectionKey, entity) {
  if (collectionKey === "maps") {
    return `
      <label>
        Map Role
        <input name="auxA" value="${escapeHtml(entity.role || "")}" placeholder="Foundation ARK, Explorer Spine..." />
      </label>
      <label>
        Classification Type
        <input
          name="classificationType"
          value="${escapeHtml(entity.classification?.type || "")}"
          placeholder="Story / Side"
        />
      </label>
      <label>
        Classification Access
        <input
          name="classificationAccess"
          value="${escapeHtml(entity.classification?.access || "")}"
          placeholder="Free / Paid"
        />
      </label>
      <label>
        Story Place
        <input name="storyPlace" value="${escapeHtml(entity.story?.place || "")}" placeholder="Story placement note" />
      </label>
      <label>
        Story Objective
        <textarea name="storyObjective" rows="2" placeholder="Why clear this map in sequence?">${escapeHtml(
          entity.story?.objective || ""
        )}</textarea>
      </label>
      <label>
        Story Next
        <input name="storyNext" value="${escapeHtml(entity.story?.next || "")}" placeholder="Where the atlas turns next" />
      </label>
      <label>
        Boss IDs
        <textarea name="bossIds" rows="2" placeholder="broodmother, megapithecus">${escapeHtml(
          toTextList(entity.bossIds)
        )}</textarea>
      </label>
      <label>
        Tame IDs
        <textarea name="tameIds" rows="2" placeholder="argy, anky, rex">${escapeHtml(
          toTextList(entity.tameIds)
        )}</textarea>
      </label>
      <label>
        Artifact IDs
        <textarea name="artifactIds" rows="2" placeholder="artifact-clever, artifact-hunter">${escapeHtml(
          toTextList(entity.artifactIds)
        )}</textarea>
      </label>
      <label>
        Resource IDs
        <textarea name="resourceIds" rows="2" placeholder="the-island-berry-farm">${escapeHtml(
          toTextList(entity.resourceIds)
        )}</textarea>
      </label>
      <label>
        Base Spot IDs
        <textarea name="baseSpotIds" rows="2" placeholder="island-hidden-lake">${escapeHtml(
          toTextList(entity.baseSpotIds)
        )}</textarea>
      </label>
      <label>
        Gallery IDs
        <textarea name="galleryIds" rows="2" placeholder="gallery-id-1, gallery-id-2">${escapeHtml(
          toTextList(entity.galleryIds)
        )}</textarea>
      </label>
      <label>
        Source IDs
        <textarea name="sourceIds" rows="2" placeholder="reference-id">${escapeHtml(
          toTextList(entity.sourceIds)
        )}</textarea>
      </label>
      <label>
        Transfer Carry Tags
        <textarea name="transferCarry" rows="2" placeholder="best bloodline, artifact stack">${escapeHtml(
          toTextList(entity.transferOut?.carry)
        )}</textarea>
      </label>
    `;
  }

  if (collectionKey === "bosses") {
    return `
      <label>
        Arena
        <input name="auxB" value="${escapeHtml(entity.arena || "")}" placeholder="Tek cave / Desert arena" />
      </label>
      <label>
        Artifact IDs
        <textarea name="artifactIds" rows="2" placeholder="artifact-clever, artifact-strong">${escapeHtml(
          toTextList(entity.artifacts)
        )}</textarea>
      </label>
      <label>
        Tribute IDs
        <textarea name="tributeIds" rows="2" placeholder="tribute-argy-talon">${escapeHtml(
          toTextList(entity.tributeItems)
        )}</textarea>
      </label>
      <label>
        Lineup JSON
        <textarea name="lineup" rows="4" placeholder='[{"role":"Main damage dealer","creatureId":"rex","quantity":"18","note":"Core plan"}]'>${escapeHtml(
          JSON.stringify(entity.lineup || [], null, 2)
        )}</textarea>
      </label>
      <label>
        Stats JSON
        <textarea name="stats" rows="4" placeholder='[{"label":"HP","value":"22000"}]'>${escapeHtml(
          JSON.stringify(entity.stats || [], null, 2)
        )}</textarea>
      </label>
      <label>
        Strategy Lines
        <textarea name="strategy" rows="3" placeholder="Open on cooldown, stay centered">${escapeHtml(
          toTextList(entity.strategy)
        )}</textarea>
      </label>
    `;
  }

  if (collectionKey === "dinos") {
    return `
      <label>
        Map ID
        <input name="auxA" value="${escapeHtml(entity.mapId || "")}" placeholder="the-island" />
      </label>
      <label>
        Role Tags
        <input name="tags" value="${escapeHtml(toTextList(entity.roleTags))}" placeholder="Boss DPS, Tank" />
      </label>
      <label>
        Stages
        <input name="auxB" value="${escapeHtml(toTextList(entity.stages))}" placeholder="early, mid, endgame" />
      </label>
      <label>
        Tame Food
        <textarea name="tameFood" rows="2" placeholder="Cooked Prime Meat / Raw Prime Meat / Kibble">${escapeHtml(
          entity.tameFood || ""
        )}</textarea>
      </label>
      <label>
        Tame Difficulty / ROI
        <textarea name="dinoStats" rows="2" placeholder="tame difficulty, transfer value, boss relevance">${escapeHtml(
          `${entity.tameDifficulty || ""} / ${entity.timeToValue || ""} / ${
            entity.costPayoff || ""
          } / ${entity.transferValue || ""} / ${entity.bossRelevance || ""}`
        )}</textarea>
      </label>
      <label>
        Notes
        <textarea name="notes" rows="3" placeholder="Operational note for this creature">${escapeHtml(
          entity.notes || ""
        )}</textarea>
      </label>
    `;
  }

  if (collectionKey === "artifacts") {
    return `
      <label>
        Map ID
        <input name="auxA" value="${escapeHtml(entity.mapId || "")}" placeholder="the-island" />
      </label>
      <label>
        Cave
        <input name="auxB" value="${escapeHtml(entity.cave || "")}" placeholder="South cave, Lost cave" />
      </label>
      <label>
        Boss IDs
        <textarea name="bossIds" rows="2" placeholder="broodmother, dragon">${escapeHtml(
          toTextList(entity.bosses)
        )}</textarea>
      </label>
      <label>
        Quick Route
        <textarea name="route" rows="2" placeholder="Route note you keep using">${escapeHtml(
          entity.quickRoute || ""
        )}</textarea>
      </label>
      <label>
        Difficulty
        <input name="difficulty" value="${escapeHtml(entity.difficulty || "")}" placeholder="Moderate / Extreme" />
      </label>
    `;
  }

  if (collectionKey === "tributeItems") {
    return `
      <label>
        Source Creature
        <input name="auxA" value="${escapeHtml(entity.sourceCreature || "")}" placeholder="Argentavis" />
      </label>
      <label>
        Source Method
        <input name="sourceMethod" value="${escapeHtml(entity.sourceMethod || "")}" placeholder="Kill and gather" />
      </label>
      <label>
        Source Zone
        <input name="where" value="${escapeHtml(entity.where || "")}" placeholder="The Island / mountains" />
      </label>
      <label>
        Quantity Estimate
        <input name="estimate" value="${escapeHtml(entity.estimate || "")}" placeholder="Low / Rare / Batch" />
      </label>
    `;
  }

  if (collectionKey === "baseSpots") {
    return `
      <label>
        Map ID
        <input name="auxA" value="${escapeHtml(entity.mapId || "")}" placeholder="the-island" />
      </label>
      <label>
        Base Type
        <input name="auxB" value="${escapeHtml(entity.type || "")}" placeholder="Main Base / Crafting Base" />
      </label>
      <label>
        Transfer Notes
        <textarea name="baseNotes" rows="2" placeholder="Core notes for this base placement">${escapeHtml(
          entity.shortDescription || ""
        )}</textarea>
      </label>
    `;
  }

  if (collectionKey === "resources") {
    return `
      <label>
        Map ID
        <input name="auxA" value="${escapeHtml(entity.mapId || "")}" placeholder="the-island" />
      </label>
      <label>
        Route Path
        <input name="route" value="${escapeHtml(entity.route || "")}" placeholder="Core run path" />
      </label>
      <label>
        Tool
        <input name="tool" value="${escapeHtml(entity.tool || "")}" placeholder="Doedicurus / flyer" />
      </label>
      <label>
        Risk
        <input name="auxB" value="${escapeHtml(entity.risk || "")}" placeholder="Medium / High / Extreme" />
      </label>
      <label>
        Map IDs
        <input name="mapIds" value="${escapeHtml(toTextList(entity.mapIds))}" placeholder="the-island, scorched-earth" />
      </label>
    `;
  }

  if (collectionKey === "knowledgeArticles") {
    return `
      <label>
        Section
        <input
          name="auxA"
          value="${escapeHtml(entity.section || "summary")}"
          placeholder="summary"
        />
      </label>
      <label>
        Sub-section
        <input name="auxB" value="${escapeHtml(entity.subSection || "")}" placeholder="General / Titans" />
      </label>
      <label>
        Summary
        <textarea name="summary" rows="3" placeholder="Compact article summary">${escapeHtml(
          entity.summary || ""
        )}</textarea>
      </label>
      <label>
        Content
        <textarea name="content" rows="4" placeholder="Optional long-form paragraph">${escapeHtml(
          entity.content || ""
        )}</textarea>
      </label>
      <label>
        Bullets
        <textarea name="bullets" rows="3" placeholder="Item 1, Item 2, Item 3">${escapeHtml(
          toTextList(entity.bullets)
        )}</textarea>
      </label>
      <label>
        Map IDs
        <input name="mapIds" value="${escapeHtml(toTextList(entity.mapIds))}" placeholder="the-island, extinction" />
      </label>
      <label>
        Reference IDs
        <input name="referenceIds" value="${escapeHtml(toTextList(entity.referenceIds))}" placeholder="ref-1, ref-2" />
      </label>
      <label>
        Patch IDs
        <input name="patchIds" value="${escapeHtml(toTextList(entity.patchIds))}" placeholder="v1.0, v1.1" />
      </label>
      <label>
        Creature IDs
        <input name="creatureIds" value="${escapeHtml(toTextList(entity.creatureIds))}" placeholder="argy, anky, theri" />
      </label>
      <label>
        Item IDs
        <input name="itemIds" value="${escapeHtml(toTextList(entity.itemIds))}" placeholder="item-shotgun, item-medbrew" />
      </label>
      <label>
        Gallery IDs
        <input name="galleryIds" value="${escapeHtml(toTextList(entity.galleryIds))}" placeholder="gallery-id-1" />
      </label>
      <label>
        DLC IDs
        <input name="dlcIds" value="${escapeHtml(toTextList(entity.dlcIds))}" placeholder="dlc-expansion-pack" />
      </label>
    `;
  }

  if (collectionKey === "references") {
    return `
      <label>
        Reference URL
        <input name="auxA" value="${escapeHtml(entity.url || "")}" placeholder="https://..." />
      </label>
      <label>
        Reference Type
        <input name="auxB" value="${escapeHtml(entity.type || "Reference")}" placeholder="Reference / Patch / Video" />
      </label>
      <label>
        Citation
        <textarea name="citation" rows="2" placeholder="Short citation or proof note">${escapeHtml(
          entity.citation || ""
        )}</textarea>
      </label>
      <label>
        Map IDs
        <input name="mapIds" value="${escapeHtml(toTextList(entity.mapIds))}" placeholder="the-island" />
      </label>
    `;
  }

  if (collectionKey === "galleryMedia") {
    return `
      <label>
        Map ID
        <input name="auxA" value="${escapeHtml(entity.mapId || "")}" placeholder="the-island" />
      </label>
      <label>
        Location
        <input name="auxB" value="${escapeHtml(entity.location || "")}" placeholder="South shore, cave mouth" />
      </label>
      <label>
        Caption
        <textarea name="caption" rows="2" placeholder="Short caption on this image">${escapeHtml(
          entity.caption || ""
        )}</textarea>
      </label>
      <label>
        Media Type
        <input name="type" value="${escapeHtml(entity.type || "Screenshot")}" placeholder="Screenshot / Art / Event" />
      </label>
    `;
  }

  if (collectionKey === "dlc") {
    return `
      <label>
        DLC Type
        <input name="auxA" value="${escapeHtml(entity.type || "Expansion Pack")}" placeholder="Expansion Pack" />
      </label>
      <label>
        Subtitle
        <textarea name="subtitle" rows="2" placeholder="Primary note for this DLC">${escapeHtml(
          entity.subtitle || ""
        )}</textarea>
      </label>
      <label>
        Map IDs
        <input name="mapIds" value="${escapeHtml(toTextList(entity.mapIds))}" placeholder="the-island" />
      </label>
      <label>
        Patch IDs
        <input name="patchIds" value="${escapeHtml(toTextList(entity.patchIds))}" placeholder="v1.0" />
      </label>
      <label>
        Related Map IDs
        <input name="notes" value="${escapeHtml(entity.notes || "")}" placeholder="Optional extra notes" />
      </label>
    `;
  }

  if (collectionKey === "patchHistory") {
    return `
      <label>
        Version
        <input name="auxA" value="${escapeHtml(entity.version || "")}" placeholder="0.310.0" />
      </label>
      <label>
        Status
        <input
          name="auxB"
          value="${escapeHtml(entity.status || "TBA")}"
          placeholder="Released / Upcoming / TBA"
        />
      </label>
      <label>
        Notes
        <textarea name="notes" rows="3" placeholder="Patch notes or entry summary">${escapeHtml(
          entity.notes || ""
        )}</textarea>
      </label>
      <label>
        Map IDs
        <input name="mapIds" value="${escapeHtml(toTextList(entity.mapIds))}" placeholder="the-island, extinction" />
      </label>
      <label>
        Note Bullets
        <textarea name="noteBullets" rows="3" placeholder="Bullet 1, Bullet 2">${escapeHtml(
          toTextList(entity.noteBullets)
        )}</textarea>
      </label>
    `;
  }

  return "";
}

function renderModal() {
  if (ui.imageModal) {
    return renderImageUrlModal();
  }

  if (ui.activeMapEntity) {
    return renderMapEntityModal();
  }

  if (ui.activeMapSection) {
    return renderMapSectionModal();
  }

  if (ui.activeMapLinkPicker) {
    return renderMapLinkPickerModal();
  }

  if (ui.activeBossId) {
    return renderBossModal(ui.activeBossId);
  }

  return "";
}

function renderMapLinkPickerModal() {
  const picker = ui.activeMapLinkPicker;
  if (!picker) return "";

  const map = getMap(picker.mapId);
  const collection = state[picker.collectionKey] || [];
  const linkedIds = new Set(
    getMapLinkIds(map || {}, picker.collectionKey, picker.linkField)
  );
  const unlinked = collection.filter(
    (entry) => entry && entry.id && !linkedIds.has(entry.id)
  );
  const emptyState = `
    <div class="inline-empty">
      No eligible entries remain. Create one to continue linking.
    </div>
  `;

  const mapName = map?.name || "Selected map";

  return `
    <div class="modal-backdrop" data-action="close-modal">
      <div class="modal-panel modal-panel--boss" role="dialog" aria-modal="true">
        <div class="modal-panel__header">
          <div>
            <p class="eyebrow">Map Link Picker</p>
            <h2>${escapeHtml(mapName)}</h2>
            <p>Select existing ${escapeHtml(
              collectionLabels[picker.collectionKey] || picker.collectionKey
            )} to link.</p>
          </div>
          <button
            class="ghost-button"
            type="button"
            data-action="close-modal"
          >
            Close
          </button>
        </div>
        <div class="modal-panel__body">
          <div class="modal-panel__actions">
            <button
              class="ghost-button ghost-button--small"
              type="button"
              data-action="create-map-link-entity"
              data-map-id="${escapeHtml(picker.mapId)}"
              data-collection="${escapeHtml(picker.collectionKey)}"
              data-link-field="${escapeHtml(picker.linkField)}"
            >
              Create New
            </button>
          </div>
          ${
            unlinked.length
              ? `<div class="stack-grid map-link-picker-grid">
                  ${unlinked
                    .map((entry) => renderEntityPickerCard(entry, picker))
                    .join("")}
                </div>`
              : emptyState
          }
        </div>
      </div>
    </div>
  `;
}

function renderEntityPickerCard(entity, picker) {
  return `
    <article class="detail-card">
      <h3>${escapeHtml(entity.name || entity.title || entity.id)}</h3>
      <p>${escapeHtml(entity.shortDescription || "")}</p>
      <div class="modal-link-actions">
        <button
          class="hero-button hero-button--primary"
          type="button"
          data-action="confirm-map-link"
          data-map-id="${escapeHtml(picker.mapId)}"
          data-collection="${escapeHtml(picker.collectionKey)}"
          data-link-field="${escapeHtml(picker.linkField)}"
          data-entity-id="${escapeHtml(entity.id)}"
        >
          Link
        </button>
        <button
          class="ghost-button ghost-button--small"
          type="button"
          data-action="quick-edit"
          data-collection="${escapeHtml(picker.collectionKey)}"
          data-entity-id="${escapeHtml(entity.id)}"
        >
          Quick Edit
        </button>
      </div>
    </article>
  `;
}

function renderImageUrlModal() {
  const { collectionKey, entityId } = ui.imageModal;
  const entity = findEntity(state, collectionKey, entityId);
  const currentUrl = entity?.media?.src || "";
  const title = entity?.name || entity?.title || entityId;

  return `
    <div class="modal-backdrop" data-action="close-modal">
      <div class="modal-panel modal-panel--image" role="dialog" aria-modal="true">
        <div class="modal-panel__header">
          <div>
            <p class="eyebrow">Image by URL</p>
            <h2>${escapeHtml(title)}</h2>
          </div>
          <button class="ghost-button" type="button" data-action="close-modal">Close</button>
        </div>
        <form id="imageUrlForm" class="image-url-form">
          <input type="hidden" name="collectionKey" value="${collectionKey}" />
          <input type="hidden" name="entityId" value="${entityId}" />
          <label>
            Paste image URL
            <input
              id="imageUrlInput"
              name="url"
              type="url"
              value="${escapeHtml(currentUrl)}"
              placeholder="https://example.com/ark-image.jpg"
              required
            />
          </label>
          <div class="image-preview-frame">
            ${
              currentUrl
                ? `<img id="imageUrlPreview" src="${escapeAttribute(currentUrl)}" alt="${escapeHtml(
                    title
                  )}" />`
                : `<div id="imageUrlPreview" class="image-preview-frame__placeholder">Preview will appear here</div>`
            }
          </div>
          <div class="modal-panel__footer">
            <button class="ghost-button" type="button" data-action="close-modal">Cancel</button>
            <button class="hero-button hero-button--primary" type="submit">Confirm</button>
          </div>
        </form>
      </div>
    </div>
  `;
}

function renderBossModal(bossId) {
  const boss = getBoss(bossId);
  if (!boss) return "";
  const map = getMap(boss.mapId);
  const artifactCards = toArray(boss?.artifacts)
    .map((id) => getArtifact(id))
    .filter(Boolean);
  const tributeCards = toArray(boss?.tributeItems)
    .map((id) => getTribute(id))
    .filter(Boolean);

  return `
    <div class="modal-backdrop" data-action="close-modal">
      <div class="modal-panel modal-panel--boss" role="dialog" aria-modal="true">
        <div class="modal-panel__header">
          <div>
            <p class="eyebrow">${escapeHtml(map?.name || "Unknown Map")}</p>
            <h2>${escapeHtml(boss.name)}</h2>
            <p>${escapeHtml(boss.difficultyFeel)}</p>
          </div>
          <button class="ghost-button" type="button" data-action="close-modal">Close</button>
        </div>
        <div class="boss-modal-grid">
          <div class="boss-modal-grid__hero">
            ${renderMediaSlot("bosses", boss, {
              className: "boss-modal-grid__media",
              label: "Boss Image",
              aspect: "hero",
            })}
            <div class="stat-ribbon">
              <span><strong>Arena</strong> ${escapeHtml(boss.arena)}</span>
              <span><strong>Main Danger</strong> ${escapeHtml(boss.mainDanger)}</span>
              <span><strong>Difficulties</strong> ${escapeHtml(toTextList(boss.tags, " / "))}</span>
            </div>
          </div>

          <div class="boss-modal-grid__section">
            <h3>Required Artifacts</h3>
            <div class="mini-card-grid">
              ${
                artifactCards.length
                  ? artifactCards.map(renderArtifactCard).join("")
                  : renderInlineEmpty("No artifacts listed yet")
              }
            </div>
          </div>

          <div class="boss-modal-grid__section">
            <h3>Required Tribute Items</h3>
            <div class="mini-card-grid">
              ${
                tributeCards.length
                  ? tributeCards.map(renderTributeCard).join("")
                  : renderInlineEmpty("No tribute items listed yet")
              }
            </div>
          </div>

          <div class="boss-modal-grid__section boss-modal-grid__section--split">
            <article class="focus-card">
              <p class="eyebrow">Dino Lineup</p>
              <div class="stat-stack">
                ${toArray(boss?.lineup)
                  .map((entry) => {
                    const creature =
                      getDino(entry?.creatureId)?.name ||
                      (entry?.creatureId
                        ? capitalize(entry.creatureId.replace(/-/g, " "))
                        : "Unknown");
                    return `
                      <span>
                        <strong>${escapeHtml(entry.role || "Support")}</strong>
                        ${escapeHtml(creature)} x ${escapeHtml(entry.quantity)}
                        <small>${escapeHtml(entry.note || "")}</small>
                      </span>
                    `;
                  })
                  .join("")}
              </div>
            </article>
            <article class="focus-card">
              <p class="eyebrow">Stats</p>
              <div class="stat-stack">
                ${toArray(boss?.stats)
                  .map(
                    (stat) => `
                      <span><strong>${escapeHtml(stat.label)}</strong> ${escapeHtml(stat.value)}</span>
                    `
                  )
                  .join("")}
              </div>
            </article>
          </div>

          <div class="boss-modal-grid__section boss-modal-grid__section--split">
            <article class="focus-card">
              <p class="eyebrow">Gear Checklist</p>
              <div class="chip-row">${renderTagList(boss.gear || [])}</div>
            </article>
            <article class="focus-card">
              <p class="eyebrow">Mistakes To Avoid</p>
              <div class="chip-row chip-row--warning">${renderTagList(boss.mistakes || [])}</div>
            </article>
          </div>

          <div class="boss-modal-grid__section">
            <h3>Strategy</h3>
              <div class="strategy-list">
                ${toArray(boss?.strategy)
                  .map(
                    (line, index) => `
                    <article class="strategy-step">
                      <span>0${index + 1}</span>
                      <p>${escapeHtml(line)}</p>
                    </article>
                  `
                )
                .join("")}
            </div>
          </div>
        </div>
      </div>
    </div>
  `;
}

function renderEmptyState(title, text) {
  return `
    <div class="empty-state">
      <h2>${escapeHtml(title)}</h2>
      <p>${escapeHtml(text)}</p>
    </div>
  `;
}

function renderInlineEmpty(text) {
  return `<div class="inline-empty">${escapeHtml(text)}</div>`;
}

function findById(collection, targetId) {
  if (!Array.isArray(collection) || !targetId) return undefined;

  const direct = collection.find((entry) => entry?.id === targetId);
  if (direct) return direct;

  const normalized = slugify(targetId);
  if (!normalized) return undefined;

  return collection.find(
    (entry) => slugify(entry?.id || entry?.name || "") === normalized
  );
}

function getMap(id) {
  return findById(state.maps, id);
}

function getBoss(id) {
  return findById(state.bosses, id);
}

function getDino(id) {
  return findById(state.dinos, id);
}

function getArtifact(id) {
  return findById(state.artifacts, id);
}

function getTribute(id) {
  return findById(state.tributeItems, id);
}

function getBaseSpot(id) {
  return findById(state.baseSpots, id);
}

function getResource(id) {
  return findById(state.resources, id);
}

function getReference(id) {
  return findById(state.references, id);
}

function getGalleryMedia(id) {
  return findById(state.galleryMedia, id);
}

function getItem(id) {
  return findById(state.items, id);
}

function getPatchHistory(id) {
  return findById(state.patchHistory, id);
}

function getDlc(id) {
  return findById(state.dlc, id);
}

function getMapLinkField(collectionKey, linkField) {
  if (linkField) return linkField;
  return MAP_LINK_FIELDS[collectionKey] || "relatedIds";
}

function getMapLinkIds(map, collectionKey, linkField) {
  if (!map) return [];
  const direct = toTextArray(map[getMapLinkField(collectionKey, linkField)]);

  if (direct.length) {
    return direct
      .map((id) => String(id || "").trim())
      .filter((id) => id);
  }

  if (collectionKey === "artifacts" && Array.isArray(map.caveRuns)) {
    return map.caveRuns
      .map((entry) => entry?.artifactId)
      .filter((value) => value);
  }

  if (collectionKey === "resources" && Array.isArray(map.resourceRoutes)) {
    return map.resourceRoutes.map((entry) => entry?.id).filter(Boolean);
  }

  if (collectionKey === "knowledgeArticles") {
    return toTextArray(map.relatedIds);
  }

  return [];
}

function setMapLinkIds(map, collectionKey, linkField, ids) {
  if (!map?.id) return;
  const normalized = Array.from(
    new Set(
      toList(ids)
        .map((entry) => String(entry || "").trim())
        .filter((entry) => entry)
    )
  );
  const field = getMapLinkField(collectionKey, linkField);
  updateEntity(state, "maps", map.id, (entry) => ({ ...entry, [field]: normalized }));
}

function linkEntityToMap(mapId, collectionKey, linkField, entityId) {
  const map = getMap(mapId);
  if (!map || !entityId) return;
  const current = getMapLinkIds(map, collectionKey, linkField);
  if (current.includes(entityId)) return;
  setMapLinkIds(map, collectionKey, linkField, [...current, entityId]);
}

function unlinkEntityFromMap(mapId, collectionKey, entityId, linkField) {
  const map = getMap(mapId);
  if (!map || !entityId) return;
  const current = getMapLinkIds(map, collectionKey, linkField);
  const next = current.filter((entry) => entry !== entityId);
  if (next.length === current.length) return;
  setMapLinkIds(map, collectionKey, linkField || getMapLinkField(collectionKey), next);
}

function createBlankEntity(collectionKey) {
  const base = {
    id: "",
    name: "",
    title: "",
    shortDescription: "",
    tags: [],
    relatedIds: [],
    media: { src: "", type: "empty", alt: "Awaiting image", tone: "bronze" },
  };

  if (collectionKey === "maps") {
    return {
      ...base,
      vibe: "",
      whyPlay: "",
      classification: { type: "Side", access: "Free" },
      role: "",
      story: { place: "", objective: "", next: "" },
      progression: [],
      tameIds: [],
      resourceRoutes: [],
      baseSpotIds: [],
      caveRuns: [],
      bossIds: [],
      transferOut: { leaveWhen: "", carry: [], blueprints: [], bloodline: [] },
    };
  }

  if (collectionKey === "bosses") {
    return {
      ...base,
      mapId: "",
      arena: "",
      difficultyFeel: "",
      mainDanger: "",
      tags: [],
      artifacts: [],
      tributeItems: [],
      lineup: [],
      stats: [],
      gear: [],
      strategy: [],
      mistakes: [],
    };
  }

  if (collectionKey === "dinos") {
    return {
      ...base,
      roleTags: [],
      stages: [],
      tameDifficulty: "",
      tameFood: "",
      tameMethod: "",
      tameMethodType: "empty",
      tameMethodDetail: "",
      timeToValue: "",
      costPayoff: "",
      transferValue: "",
      bossRelevance: "",
      loot: "",
      notes: "",
    };
  }

  if (collectionKey === "artifacts") {
    return {
      ...base,
      mapId: "",
      cave: "",
      quickRoute: "",
      difficulty: "",
      bosses: [],
    };
  }

  if (collectionKey === "tributeItems") {
    return {
      ...base,
      sourceCreature: "",
      sourceMethod: "",
      where: "",
      estimate: "",
    };
  }

  if (collectionKey === "baseSpots") {
    return {
      ...base,
      mapId: "",
      type: "",
      title: "",
    };
  }

  if (collectionKey === "resources") {
    return {
      ...base,
      mapId: "",
      route: "",
      tool: "",
      risk: "",
      tags: [],
    };
  }

  if (collectionKey === "items") {
    return {
      ...base,
      officialListGroup: "",
      officialIdCategory: "",
      officialSubcategory: "",
      dlc: "",
      isLiveASA: false,
      isObtainable: false,
      notes: "",
      practicalNote: "",
      relatedCreatureIds: [],
      relatedBossIds: [],
      relatedMapIds: [],
    };
  }

  if (collectionKey === "knowledgeArticles") {
    return {
      ...base,
      section: "summary",
      subSection: "",
      content: "",
      summary: "",
      bullets: [],
      mapIds: [],
      creatureIds: [],
      itemIds: [],
      referenceIds: [],
      patchIds: [],
      galleryIds: [],
      dlcIds: [],
    };
  }

  if (collectionKey === "references") {
    return {
      ...base,
      title: "",
      url: "",
      citation: "",
      type: "Reference",
      mapIds: [],
    };
  }

  if (collectionKey === "galleryMedia") {
    return {
      ...base,
      mapId: "",
      location: "",
      caption: "",
      type: "Screenshot",
    };
  }

  if (collectionKey === "dlc") {
    return {
      ...base,
      title: "",
      type: "Expansion Pack",
      subtitle: "",
      mapIds: [],
      patchIds: [],
    };
  }

  if (collectionKey === "patchHistory") {
    return {
      ...base,
      title: "",
      version: "",
      status: "TBA",
      notes: "",
      mapIds: [],
      noteBullets: [],
    };
  }

  return base;
}

function getAuxPlaceholderA(collectionKey) {
  const map = {
    maps: "Map role",
    bosses: "Map ID or arena",
    dinos: "Primary map or main role",
    items: "Official group",
    artifacts: "Map ID or cave",
    tributeItems: "Source creature",
    baseSpots: "Map ID or base type",
    resources: "Map ID",
    knowledgeArticles: "Section",
    references: "Reference URL",
    galleryMedia: "Map ID",
    dlc: "DLC category",
    patchHistory: "Version",
  };
  return map[collectionKey] || "Aux field A";
}

function getAuxPlaceholderB(collectionKey) {
  const map = {
    maps: "Access type (Free / Paid)",
    bosses: "Difficulty tags or warning",
    dinos: "Stages comma separated",
    items: "Official category",
    artifacts: "Difficulty or route note",
    tributeItems: "Where to farm",
    baseSpots: "Tags or travel note",
    resources: "Tool / risk note",
    knowledgeArticles: "Sub-section",
    references: "Reference type",
    galleryMedia: "Location",
    dlc: "Primary map ID",
    patchHistory: "Status (Released/Upcoming/TBA)",
  };
  return map[collectionKey] || "Aux field B";
}

function renderTagList(tags) {
  return toTextArray(tags)
    .filter(Boolean)
    .map((tag) => `<span class="chip">${escapeHtml(tag)}</span>`)
    .join("");
}

function capitalize(value) {
  if (!value) return "";
  return value
    .split(" ")
    .map((part) => part.charAt(0).toUpperCase() + part.slice(1))
    .join(" ");
}

function escapeHtml(value) {
  return String(value ?? "")
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;");
}

function escapeAttribute(value) {
  return escapeHtml(value).replaceAll("'", "&#39;");
}

function openImageUrlModal(collectionKey, entityId) {
  ui.imageModal = { collectionKey, entityId };
  render();
}

function normalizeRuntimeAtlasState(payload) {
  const normalizedPayload = payload || state;
  state = normalizeAtlasStateFromStore(normalizedPayload);
  const defaultState = normalizeAtlasStateFromStore();
  const rawMeta = state && typeof state.meta === "object" ? state.meta : {};

  state.meta = {
    ...(defaultState.meta || {}),
    ...(rawMeta || {}),
  };
  state.meta.title = String(state.meta.title || defaultState.meta?.title || "ARK Atlas");
  state.meta.heroActions = Array.isArray(state.meta.heroActions)
    ? state.meta.heroActions
    : [];
  state.meta.cloud = {
    ...(defaultState.meta?.cloud || {}),
    ...(state.meta.cloud || {}),
  };
  state.meta.cloud.syncLock = {
    ...(defaultState.meta?.cloud?.syncLock || {}),
    ...(state.meta.cloud.syncLock || {}),
  };

  const asArray = (value) => (Array.isArray(value) ? value : []);

  state.maps = asArray(state.maps);
  state.bosses = asArray(state.bosses);
  state.dinos = asArray(state.dinos);
  state.artifacts = asArray(state.artifacts);
  state.items = asArray(state.items);
  state.tributeItems = asArray(state.tributeItems);
  state.baseSpots = asArray(state.baseSpots);
  state.resources = asArray(state.resources);
  state.knowledgeArticles = asArray(state.knowledgeArticles);
  state.references = asArray(state.references);
  state.galleryMedia = asArray(state.galleryMedia);
  state.dlc = asArray(state.dlc);
  state.patchHistory = asArray(state.patchHistory);
  state.fastestRoute = asArray(state.fastestRoute);
  state.loreRecords = asArray(state.loreRecords);
  state.rankings = asArray(state.rankings);
  state.serverSettings = asArray(state.serverSettings);

  let changed = false;

  if (state.meta.creatureImportVersion !== ASA_CREATURE_IMPORT_VERSION) {
    syncImportedCreatureRoster(state);
    changed = true;
  }

  if (
    state.meta.itemImportVersion !== ASA_ITEM_IMPORT_VERSION ||
    hasImportedItemRosterGap(state.items)
  ) {
    syncImportedItemRoster(state);
    changed = true;
  }

  state.maps = (state.maps || []).map((map) => {
    const next = { ...map };

    if (!Array.isArray(next.tameIds)) {
      next.tameIds = next.tameIds
        ? toList(next.tameIds)
        : [];
    }

    if (!Array.isArray(next.bossIds)) {
      next.bossIds = next.bossIds ? toList(next.bossIds) : [];
    }

    const legacyResourceIds = (next.resourceRoutes || [])
      .map((route) => {
        if (!route) return null;
        if (route.id) return route.id;
        const routeId = `${next.id}-${slugify(route.resource || route.name || "resource")}`;
        return routeId;
      })
      .filter(Boolean);
    const resourceIds = toList(next.resourceIds);
    const finalResourceIds = resourceIds.length ? resourceIds : legacyResourceIds;
    if (!Array.isArray(next.resourceIds)) {
      next.resourceIds = finalResourceIds;
      changed = true;
    }

    const storedArtifactIds = toList(next.artifactIds);
    const fallbackArtifactIds = storedArtifactIds.length
      ? storedArtifactIds
      : Array.isArray(next.caveRuns)
      ? next.caveRuns.map((run) => run?.artifactId).filter(Boolean)
      : [];
    const normalizedArtifactIds = toTextArray(next.artifactIds);
    const finalArtifactIds = fallbackArtifactIds.length
      ? fallbackArtifactIds
      : [];
    if (
      !Array.isArray(next.artifactIds) ||
      JSON.stringify(normalizedArtifactIds) !== JSON.stringify(finalArtifactIds)
    ) {
      next.artifactIds = finalArtifactIds;
      changed = true;
    }

    if (!Array.isArray(next.baseSpotIds)) {
      next.baseSpotIds = toList(next.baseSpotIds);
      changed = true;
    }

    if (!Array.isArray(next.galleryIds)) {
      next.galleryIds = toList(next.galleryIds);
      changed = true;
    }

    if (!Array.isArray(next.sourceIds)) {
      next.sourceIds = toList(next.sourceIds);
      changed = true;
    }

    next.galleryIds = next.galleryIds || [];
    next.sourceIds = next.sourceIds || [];

    return next;
  });

  state.dinos = (state.dinos || []).map((dino) => {
    const practical = normalizeDinoPracticalFields(dino);
    const existingMedia =
      dino.media && typeof dino.media === "object" ? dino.media : null;
    const needsMediaBackfill =
      !existingMedia ||
      typeof existingMedia.src !== "string" ||
      !existingMedia.src.trim();
    const next = {
      ...dino,
      ...practical,
      media: needsMediaBackfill ? buildImportedCreatureMedia(dino, "amber") : existingMedia,
    };

    if (
      dino.tameFood !== next.tameFood ||
      dino.tameMethod !== next.tameMethod ||
      dino.tameMethodType !== next.tameMethodType ||
      dino.tameMethodDetail !== next.tameMethodDetail ||
      dino.loot !== next.loot ||
      needsMediaBackfill
    ) {
      changed = true;
    }

    return next;
  });

  state.items = (state.items || []).map((item) => {
    const normalized = normalizeItemFields(item);
    const next = {
      ...item,
      ...normalized,
      media:
        item.media && typeof item.media === "object"
          ? item.media
          : {
              src: "",
              type: "empty",
              alt: `${item.name || item.title || item.id || "Item"} icon`,
              tone: "bronze",
            },
    };

    if (
      item.officialListGroup !== next.officialListGroup ||
      item.officialIdCategory !== next.officialIdCategory ||
      item.officialSubcategory !== next.officialSubcategory ||
      item.dlc !== next.dlc ||
      item.isLiveASA !== next.isLiveASA ||
      item.isObtainable !== next.isObtainable ||
      item.notes !== next.notes ||
      item.practicalNote !== next.practicalNote ||
      JSON.stringify(toTextArray(item.relatedCreatureIds)) !==
        JSON.stringify(next.relatedCreatureIds) ||
      JSON.stringify(toTextArray(item.relatedBossIds)) !==
        JSON.stringify(next.relatedBossIds) ||
      JSON.stringify(toTextArray(item.relatedMapIds)) !==
        JSON.stringify(next.relatedMapIds)
    ) {
      changed = true;
    }

    return next;
  });

  (state.maps || []).forEach((map) => {
    (map.resourceRoutes || []).forEach((route) => {
      if (!route || !route.resource) return;
      const resourceId =
        route.id || `${map.id}-${slugify(route.resource || route.name || "resource")}`;
      if (!state.resources.find((entry) => entry.id === resourceId)) {
        state.resources.push({
          id: resourceId,
          name: route.resource || route.name || "Resource Route",
          shortDescription: route.route || route.quickRoute || "",
          route: route.route || route.quickRoute || route.note || "",
          tool: route.tool || "",
          risk: route.risk || "",
          tags: [
            route.resource,
            route.tool || map.classification?.type || "",
            route.risk ? `Risk: ${route.risk}` : "",
          ].filter(Boolean),
          media: {
            src: "",
            type: "empty",
            alt: `${route.resource} route`,
            tone: "bronze",
          },
          mapIds: [map.id],
        });
        changed = true;
      }
      map.resourceIds = map.resourceIds || [];
      if (!map.resourceIds.includes(resourceId)) {
        map.resourceIds.push(resourceId);
        changed = true;
      }
    });
  });

  if (changed) {
    saveState(state);
  }

  return state;
}

function closeModal() {
  ui.activeBossId = null;
  ui.imageModal = null;
  ui.activeMapLinkPicker = null;
  ui.activeMapSection = null;
  ui.activeMapEntity = null;
  render();
}

function exportAtlasState() {
  const backup = normalizeAtlasStateFromStore(state);
  const payload = JSON.stringify(backup, null, 2);
  const file = new Blob([payload], { type: "application/json;charset=utf-8" });
  const url = URL.createObjectURL(file);
  const anchor = document.createElement("a");
  const dateStamp = new Date().toISOString().replace(/[:.]/g, "-");
  anchor.href = url;
  anchor.download = `ark-ascended-atlas-backup-${dateStamp}.json`;
  document.body.appendChild(anchor);
  anchor.click();
  anchor.remove();
  URL.revokeObjectURL(url);
}

async function importAtlasStateFromFile(file) {
  if (!file) return;
  try {
    const content = await file.text();
    const payload = JSON.parse(content);
    const imported = normalizeAtlasStateFromStore(payload);
    if (!imported || typeof imported !== "object") {
      throw new Error("Invalid atlas backup payload.");
    }
    state = imported;
    state = normalizeRuntimeAtlasState(state);
    persist();
    void syncAllStateToCloud();
  } catch (error) {
    window.alert("Import failed. Please use a valid atlas backup JSON.");
    console.warn("Failed to import atlas state:", error);
  }
}

function persist() {
  saveState(state);
  render();
}

async function setEntityImage(collectionKey, entityId, src, type = "url") {
  const existingEntity = getStateEntity(collectionKey, entityId);
  if (!existingEntity) return;

  updateEntity(state, collectionKey, entityId, (entity) => ({
    ...entity,
    media: {
      ...(entity.media || {
        alt: entity.name || entity.title || entityId,
        tone: entity.media?.tone || "bronze",
      }),
      src,
      type,
    },
  }));
  persist();

  const latestEntity = getStateEntity(collectionKey, entityId);
  if (!latestEntity) return;

  const syncedEntity = await runCloudTask(
    "Uploading media",
    "Media synced",
    () =>
      saveAtlasEntityMediaToCloud(
        collectionKey,
        latestEntity,
        src,
        type
      )
  );
  if (!syncedEntity) return;

  upsertEntity(state, collectionKey, syncedEntity);
  saveState(state);
  render();
}

async function removeEntityImage(collectionKey, entityId) {
  const existingEntity = getStateEntity(collectionKey, entityId);
  if (!existingEntity) return;

  updateEntity(state, collectionKey, entityId, (entity) => ({
    ...entity,
    media: {
      ...(entity.media || {}),
      src: "",
      type: "empty",
      storagePath: "",
    },
  }));
  persist();

  const syncedEntity = await runCloudTask(
    "Removing media",
    "Media removed",
    () =>
      removeAtlasEntityMediaFromCloud(
        collectionKey,
        existingEntity
      )
  );
  if (!syncedEntity) return;

  upsertEntity(state, collectionKey, syncedEntity);
  saveState(state);
  render();
}

function buildEntityFromForm(formData) {
  const collectionKey = formData.get("collectionKey");
  const id = slugify(formData.get("id"));
  const title = String(formData.get("title") || "").trim();
  const shortDescription = String(formData.get("shortDescription") || "").trim();
  const tags = toList(formData.get("tags"));
  const relatedIds = toList(formData.get("relatedIds"));
  const auxA = String(formData.get("auxA") || "").trim();
  const auxB = String(formData.get("auxB") || "").trim();
  const existing = findEntity(state, collectionKey, id) || createBlankEntity(collectionKey);
  const displayKey = collectionKey === "baseSpots" ? "title" : "name";

  const shared = {
    ...existing,
    id,
    [displayKey]: title,
    shortDescription,
    tags,
    relatedIds,
    media: existing.media || {
      src: "",
      type: "empty",
      alt: title || id,
      tone: "bronze",
    },
  };

  switch (collectionKey) {
    case "maps":
      const storyPlace = String(formData.get("storyPlace") || existing.story?.place || "");
      const storyObjective = String(formData.get("storyObjective") || existing.story?.objective || "");
      const storyNext = String(formData.get("storyNext") || existing.story?.next || "");
      const classificationType = String(formData.get("classificationType") || existing.classification?.type || auxA || "Side");
      const classificationAccess = String(formData.get("classificationAccess") || existing.classification?.access || auxB || "Free");
      const transferCarry = toList(formData.get("transferCarry") || []);
      const transferBlueprints = toList(formData.get("transferBlueprints") || []);
      const transferBloodline = toList(formData.get("transferBloodline") || []);
      const baseTransferOut = existing.transferOut || {};
      return {
        ...shared,
        name: title,
        vibe: shortDescription || existing.vibe || "",
        whyPlay: existing.whyPlay || shortDescription || "",
        role: auxA || existing.role || "",
        classification: {
          type: classificationType || existing.classification?.type || (tags.includes("Story") ? "Story" : "Side"),
          access: classificationAccess || existing.classification?.access || "Free",
        },
        story: {
          place: storyPlace || existing.story?.place || "",
          objective: storyObjective || existing.story?.objective || "",
          next: storyNext || existing.story?.next || "",
        },
        tameIds: parseListFromForm(formData.get("tameIds"), existing.tameIds),
        bossIds: parseListFromForm(formData.get("bossIds"), existing.bossIds),
        artifactIds: parseListFromForm(formData.get("artifactIds"), existing.artifactIds),
        resourceIds: parseListFromForm(formData.get("resourceIds"), existing.resourceIds),
        baseSpotIds: parseListFromForm(formData.get("baseSpotIds"), existing.baseSpotIds),
        galleryIds: parseListFromForm(formData.get("galleryIds"), existing.galleryIds),
        sourceIds: parseListFromForm(formData.get("sourceIds"), existing.sourceIds),
        transferOut: {
          leaveWhen: existing.transferOut?.leaveWhen || "Follow your transfer rule.",
          carry: transferCarry.length ? transferCarry : baseTransferOut.carry || [],
          blueprints: transferBlueprints.length ? transferBlueprints : baseTransferOut.blueprints || [],
          bloodline: transferBloodline.length ? transferBloodline : baseTransferOut.bloodline || [],
        },
      };
  case "bosses":
      return {
        ...shared,
        name: title,
        mapId: auxA || existing.mapId || "",
        arena: auxB || existing.arena || "Arena",
        difficultyFeel: shortDescription || existing.difficultyFeel || "",
        artifacts: parseEntityListOrFallback(formData.get("artifactIds"), existing.artifacts),
        tributeItems: parseEntityListOrFallback(formData.get("tributeIds"), existing.tributeItems),
        lineup: parseEntityListOrFallback(formData.get("lineup"), existing.lineup, true),
        stats: parseEntityListOrFallback(formData.get("stats"), existing.stats, true),
        gear: toList(formData.get("gear") || existing.gear),
        strategy: toList(formData.get("strategy") || existing.strategy),
        mistakes: toList(formData.get("mistakes") || existing.mistakes),
      };
    case "dinos":
      const dinoStats = parseDinoStats(formData.get("dinoStats"), existing);
      const practical = normalizeDinoPracticalFields(existing);
      return {
        ...shared,
        name: title,
        roleTags: tags,
        stages: toList(auxB || toTextList(existing.stages)),
        tameFood: String(formData.get("tameFood") || existing.tameFood || ""),
        tameMethod: practical.tameMethod,
        tameMethodType: practical.tameMethodType,
        tameMethodDetail: practical.tameMethodDetail,
        notes: shortDescription || existing.notes || "",
        mapId: auxA || existing.mapId || "",
        tameDifficulty: dinoStats.tameDifficulty,
        timeToValue: dinoStats.timeToValue,
        costPayoff: dinoStats.costPayoff,
        transferValue: dinoStats.transferValue,
        bossRelevance: dinoStats.bossRelevance,
        loot: practical.loot,
      };
    case "artifacts":
      return {
        ...shared,
        name: title,
        mapId: auxA || existing.mapId || "",
        cave: auxB || existing.cave || "",
        quickRoute: shortDescription || existing.quickRoute || "",
        difficulty: String(formData.get("difficulty") || existing.difficulty || ""),
        bosses: parseListFromForm(formData.get("bossIds"), existing.bosses),
      };
    case "tributeItems":
      return {
        ...shared,
        name: title,
        sourceCreature: auxA || existing.sourceCreature || "",
        where: auxB || existing.where || "",
        sourceMethod: shortDescription || existing.sourceMethod || "",
        estimate: String(formData.get("estimate") || existing.estimate || ""),
      };
    case "baseSpots":
      return {
        ...shared,
        title,
        mapId: auxA || existing.mapId || "",
        type: auxB || existing.type || "",
        shortDescription: String(formData.get("baseNotes") || shortDescription || existing.shortDescription || ""),
      };
    case "resources":
      return {
        ...shared,
        name: title,
        mapId: auxA || existing.mapId || "",
        route: String(formData.get("route") || shortDescription || existing.route || ""),
        tool: String(formData.get("tool") || existing.tool || ""),
        risk: String(formData.get("auxB") || formData.get("risk") || existing.risk || "Medium"),
        mapIds: parseListFromForm(formData.get("mapIds"), existing.mapIds),
      };
    case "items":
      return {
        ...shared,
        name: title,
        officialListGroup: auxA || existing.officialListGroup || "",
        officialIdCategory: auxB || existing.officialIdCategory || "",
        officialSubcategory: String(formData.get("officialSubcategory") || existing.officialSubcategory || ""),
        dlc: String(formData.get("dlc") || existing.dlc || ""),
        isLiveASA:
          existing.isLiveASA === true ||
          String(formData.get("isLiveASA") || existing.isLiveASA || "").toLowerCase() === "true",
        isObtainable:
          existing.isObtainable === true ||
          String(formData.get("isObtainable") || existing.isObtainable || "").toLowerCase() === "true",
        notes: String(formData.get("notes") || shortDescription || existing.notes || ""),
        practicalNote: String(formData.get("practicalNote") || existing.practicalNote || ""),
        relatedCreatureIds: parseListFromForm(formData.get("relatedCreatureIds"), existing.relatedCreatureIds),
        relatedBossIds: parseListFromForm(formData.get("relatedBossIds"), existing.relatedBossIds),
        relatedMapIds: parseListFromForm(formData.get("relatedMapIds"), existing.relatedMapIds),
      };
    case "knowledgeArticles":
      const bulletList = toList(formData.get("bullets") || []);
      const mapIds = parseListFromForm(formData.get("mapIds"), existing.mapIds);
      const creatureIds = parseListFromForm(formData.get("creatureIds"), existing.creatureIds);
      const itemIds = parseListFromForm(formData.get("itemIds"), existing.itemIds);
      const referenceIds = parseListFromForm(formData.get("referenceIds"), existing.referenceIds);
      const patchIds = parseListFromForm(formData.get("patchIds"), existing.patchIds);
      const galleryIds = parseListFromForm(formData.get("galleryIds"), existing.galleryIds);
      const dlcIds = parseListFromForm(formData.get("dlcIds"), existing.dlcIds);
      return {
        ...shared,
        title,
        section: auxA || existing.section || "summary",
        subSection: auxB || existing.subSection || "",
        summary: String(formData.get("summary") || shortDescription || existing.summary || ""),
        content: formData.get("content") || existing.content || "",
        bullets: bulletList.length ? bulletList : existing.bullets || [],
        mapIds,
        creatureIds,
        itemIds,
        referenceIds,
        patchIds,
        galleryIds,
        dlcIds,
      };
    case "references":
      const citation = String(formData.get("citation") || shortDescription || existing.citation || "");
      return {
        ...shared,
        title,
        url: auxA || existing.url || "",
        citation,
        type: auxB || existing.type || "Reference",
        mapIds: toList(formData.get("mapIds") || existing.mapIds || []),
      };
    case "galleryMedia":
      return {
        ...shared,
        name: title,
        mapId: auxA || existing.mapId || "",
        location: auxB || existing.location || "",
        caption: String(formData.get("caption") || shortDescription || existing.caption || ""),
        type: String(formData.get("type") || existing.type || "Screenshot"),
      };
    case "dlc":
      return {
        ...shared,
        name: title,
        title,
        type: auxA || existing.type || "Expansion Pack",
        subtitle: String(formData.get("subtitle") || shortDescription || existing.subtitle || ""),
        mapIds: parseListFromForm(formData.get("mapIds"), existing.mapIds),
        patchIds: parseListFromForm(formData.get("patchIds"), existing.patchIds),
      };
    case "patchHistory":
      const patchNotes = String(formData.get("notes") || shortDescription || existing.notes || "");
      const noteBullets = toList(formData.get("noteBullets") || []);
      return {
        ...shared,
        title,
        version: auxA || existing.version || "",
        status: auxB || existing.status || "TBA",
        notes: patchNotes,
        mapIds: parseListFromForm(formData.get("mapIds"), existing.mapIds),
        noteBullets: noteBullets.length ? noteBullets : existing.noteBullets || [],
      };
    default:
      return {
        ...shared,
        name: title,
      };
  }
}

function slugify(value) {
  return String(value || "")
    .trim()
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "");
}

function toList(value) {
  if (Array.isArray(value)) {
    return value.map((entry) => String(entry || "").trim()).filter(Boolean);
  }

  if (typeof value === "string") {
    return value
      .split(",")
      .map((entry) => entry.trim())
      .filter(Boolean);
  }

  if (value == null) {
    return [];
  }

  return [];
}

function safeParseJson(value) {
  if (typeof value !== "string") return undefined;
  const trimmed = value.trim();
  if (!trimmed) return undefined;
  try {
    return JSON.parse(trimmed);
  } catch {
    return undefined;
  }
}

function parseListFromForm(rawValue, fallback = []) {
  const fallbackList = Array.isArray(fallback)
    ? fallback
    : toTextArray(fallback);
  const parsed = safeParseJson(rawValue);

  if (Array.isArray(parsed)) {
    const next = parsed
      .map((entry) =>
        typeof entry === "string"
          ? entry.trim()
          : entry?.id != null
            ? String(entry.id).trim()
            : entry == null
              ? ""
              : String(entry).trim()
      )
      .filter(Boolean);
    return next.length ? Array.from(new Set(next)) : fallbackList;
  }

  const asList = toList(rawValue);
  return asList.length ? Array.from(new Set(asList)) : fallbackList;
}

function parseEntityListOrFallback(rawValue, fallback = [], expectObject = false) {
  const fallbackList = Array.isArray(fallback)
    ? fallback
    : toTextArray(fallback);
  const parsed = safeParseJson(rawValue);

  if (Array.isArray(parsed)) {
    const next = parsed.filter(Boolean);
    if (next.length) {
      if (expectObject) {
        return next.map((entry) =>
          typeof entry === "string" ? { role: "", name: entry, creatureId: entry, quantity: "", note: "" } : entry
        );
      }
      return next
        .map((entry) =>
          typeof entry === "string"
            ? entry.trim()
            : entry?.id != null
              ? String(entry.id).trim()
              : ""
        )
        .filter(Boolean);
    }
  }

  const asList = toList(rawValue);
  if (asList.length) {
    return expectObject ? fallbackList : asList;
  }

  return fallbackList;
}

function parseDinoStats(rawValue, existing = {}) {
  const raw = String(rawValue || "").trim();
  if (!raw && existing) {
    return {
      tameDifficulty: existing.tameDifficulty || "",
      timeToValue: existing.timeToValue || "",
      costPayoff: existing.costPayoff || "",
      transferValue: existing.transferValue || "",
      bossRelevance: existing.bossRelevance || "",
    };
  }

  const parsed = safeParseJson(raw);
  if (Array.isArray(parsed)) {
    const first = parsed[0];
    if (first && typeof first === "object") {
      return {
        tameDifficulty: String(first.tameDifficulty || ""),
        timeToValue: String(first.timeToValue || ""),
        costPayoff: String(first.costPayoff || ""),
        transferValue: String(first.transferValue || ""),
        bossRelevance: String(first.bossRelevance || ""),
      };
    }
  }

  const parts = raw
    .split("/")
    .map((entry) => entry.trim())
    .filter(Boolean);
  if (parts.length >= 5) {
    return {
      tameDifficulty: parts[0],
      timeToValue: parts[1],
      costPayoff: parts[2],
      transferValue: parts[3],
      bossRelevance: parts[4],
    };
  }

  return {
    tameDifficulty: existing.tameDifficulty || "",
    timeToValue: existing.timeToValue || "",
    costPayoff: existing.costPayoff || "",
    transferValue: existing.transferValue || "",
    bossRelevance: existing.bossRelevance || "",
  };
}

function syncImagePreview() {
  const input = document.querySelector("#imageUrlInput");
  const preview = document.querySelector("#imageUrlPreview");
  if (!input || !preview) return;

  const url = input.value.trim();
  if (!url) {
    preview.outerHTML =
      '<div id="imageUrlPreview" class="image-preview-frame__placeholder">Preview will appear here</div>';
    return;
  }

  const img = document.createElement("img");
  img.id = "imageUrlPreview";
  img.src = url;
  img.alt = "Image preview";
  preview.replaceWith(img);
}

function toggleCreatureMethodDetailField(selectElement) {
  const form = selectElement?.closest("form");
  if (!form) return;

  const detailField = form.querySelector(".creature-inline-editor__detail");
  const textarea = form.querySelector('textarea[name="tameMethodDetail"]');
  const nextType = String(selectElement.value || "empty").toLowerCase();
  const shouldShow = nextType === "special";

  if (detailField) {
    detailField.hidden = !shouldShow;
  }

  if (textarea instanceof HTMLTextAreaElement) {
    textarea.disabled = !shouldShow;
    if (!shouldShow) {
      textarea.value = "";
    }
  }
}

function buildCreaturePracticalUpdate(formData, existing) {
  const practical = normalizeDinoPracticalFields(existing);
  const nextType = String(formData.get("tameMethodType") || practical.tameMethodType || "empty")
    .trim()
    .toLowerCase();
  const tameMethodType = DINO_TAME_METHOD_TYPES.includes(nextType)
    ? nextType
    : "empty";
  const tameFood = String(formData.get("tameFood") || "").trim();
  const loot = String(formData.get("loot") || "").trim();
  const tameMethod = String(formData.get("tameMethod") || "").trim();
  const tameMethodDetail = String(formData.get("tameMethodDetail") || "").trim();

  if (tameMethodType === "empty") {
    return {
      tameFood,
      tameMethod: "",
      tameMethodType,
      tameMethodDetail: "",
      loot,
    };
  }

  if (tameMethodType === "simple") {
    return {
      tameFood,
      tameMethod,
      tameMethodType,
      tameMethodDetail: "",
      loot,
    };
  }

  return {
    tameFood,
    tameMethod,
    tameMethodType,
    tameMethodDetail,
    loot,
  };
}

async function saveCreaturePracticalForm(formData) {
  const entityId = String(formData.get("entityId") || "").trim();
  if (!entityId) return false;

  const existing = getDino(entityId);
  if (!existing) return false;

  const practical = buildCreaturePracticalUpdate(formData, existing);

  updateEntity(state, "dinos", entityId, (entity) => ({
    ...entity,
    ...practical,
  }));

  persist();
  await syncEntityToCloud("dinos", entityId);
  return true;
}

window.addEventListener("hashchange", render);
window.addEventListener("storage", (event) => {
  if (event.storageArea !== window.localStorage) return;
  if (event.key !== STORAGE_KEY || !event.newValue) return;

  state = loadState();
  state = normalizeRuntimeAtlasState(state);
  render();
});

document.addEventListener("click", async (event) => {
  const actionTarget = event.target.closest("[data-action]");
  if (!actionTarget) return;

    const { action } = actionTarget.dataset;

  if (action === "image-url" || action === "image-upload" || action === "image-remove") {
    event.preventDefault();
    event.stopPropagation();
  }

  if (action === "toggle-admin") {
    ui.editMode = !ui.editMode;
    render();
    return;
  }

  if (action === "admin-collection") {
    ui.admin.collectionKey = actionTarget.dataset.collection;
    ui.admin.entityId = "__new__";
    render();
    return;
  }

  if (action === "open-boss") {
    ui.activeBossId = actionTarget.dataset.bossId;
    ui.imageModal = null;
    render();
    return;
  }

  if (action === "open-creature-editor") {
    ui.activeCreatureEditorId = actionTarget.dataset.entityId || null;
    ui.creatureEditorFocus = actionTarget.dataset.focus || "";
    render();
    return;
  }

  if (action === "close-creature-editor") {
    ui.activeCreatureEditorId = null;
    ui.creatureEditorFocus = "";
    render();
    return;
  }

  if (action === "open-map-section") {
    ui.activeMapSection = {
      mapId: actionTarget.dataset.mapId,
      section: actionTarget.dataset.section,
      mode: actionTarget.dataset.mode || "open",
    };
    ui.activeMapEntity = null;
    ui.activeMapLinkPicker = null;
    ui.activeBossId = null;
    ui.imageModal = null;
    render();
    return;
  }

  if (action === "open-map-entity") {
    ui.activeMapEntity = {
      collection: actionTarget.dataset.collection,
      entityId: actionTarget.dataset.entityId,
    };
    ui.activeMapSection = null;
    ui.activeMapLinkPicker = null;
    ui.activeBossId = null;
    ui.imageModal = null;
    render();
    return;
  }

  if (action === "close-modal") {
    if (event.target === actionTarget) {
      closeModal();
    }
    return;
  }

  if (action === "quick-edit") {
    ui.editMode = true;
    ui.admin.collectionKey = actionTarget.dataset.collection;
    ui.admin.entityId = actionTarget.dataset.entityId;
    render();
    return;
  }

  if (action === "open-map-link-picker") {
    ui.activeMapLinkPicker = {
      mapId: actionTarget.dataset.mapId,
      collectionKey: actionTarget.dataset.collection,
      linkField: actionTarget.dataset.linkField,
    };
    render();
    return;
  }

  if (action === "create-map-link-entity") {
    ui.mapLinkPending = {
      mapId: actionTarget.dataset.mapId,
      collectionKey: actionTarget.dataset.collection,
      linkField: actionTarget.dataset.linkField,
    };
    ui.admin.collectionKey = actionTarget.dataset.collection;
    ui.admin.entityId = "__new__";
    ui.editMode = true;
    render();
    return;
  }

  if (action === "confirm-map-link") {
    const mapId = actionTarget.dataset.mapId;
    linkEntityToMap(
      mapId,
      actionTarget.dataset.collection,
      actionTarget.dataset.linkField,
      actionTarget.dataset.entityId
    );
    ui.activeMapLinkPicker = null;
    persist();
    await syncMapToCloud(mapId);
    return;
  }

  if (action === "unlink-map-entity") {
    const mapId = actionTarget.dataset.mapId;
    unlinkEntityFromMap(
      mapId,
      actionTarget.dataset.collection,
      actionTarget.dataset.entityId
    );
    persist();
    await syncMapToCloud(mapId);
    return;
  }

  if (action === "toggle-map-card-edit") {
    ui.editMapCards = !ui.editMapCards;
    render();
    return;
  }

  if (action === "image-url") {
    openImageUrlModal(
      actionTarget.dataset.collection,
      actionTarget.dataset.entityId
    );
    return;
  }

  if (action === "image-upload") {
    filePicker.dataset.collection = actionTarget.dataset.collection;
    filePicker.dataset.entityId = actionTarget.dataset.entityId;
    filePicker.click();
    return;
  }

  if (action === "image-remove") {
    await removeEntityImage(
      actionTarget.dataset.collection,
      actionTarget.dataset.entityId
    );
    return;
  }

  if (action === "force-cloud-sync") {
    await syncAllStateToCloud();
    return;
  }

  if (action === "export-state") {
    exportAtlasState();
    return;
  }

  if (action === "import-state") {
    if (stateFilePicker) {
      stateFilePicker.click();
    }
    return;
  }

  if (action === "reset-data") {
    state = resetState();
    ui.activeBossId = null;
    ui.imageModal = null;
    ui.activeMapSection = null;
    ui.activeMapEntity = null;
    ui.activeMapLinkPicker = null;
    render();
    void syncAllStateToCloud();
  }
});

document.addEventListener("change", async (event) => {
  const mapFilterAction = event.target.dataset.action;
  if (mapFilterAction === "map-section-filter") {
    const sectionKey = event.target.dataset.section;
    const filterKey = event.target.dataset.filter;
    if (sectionKey && filterKey) {
      const sectionState = getMapSectionState(sectionKey);
      sectionState.filters = sectionState.filters || {};
      sectionState.filters[filterKey] = event.target.value || "";
      render();
    }
    return;
  }

  if (mapFilterAction === "creature-method-type") {
    toggleCreatureMethodDetailField(event.target);
    return;
  }

  if (mapFilterAction === "items-library-sort") {
    ui.itemsLibrarySort = event.target.value || "name";
    render();
    return;
  }

  if (event.target.id === "adminEntitySelect") {
    ui.admin.entityId = event.target.value;
    render();
    return;
  }

  const settingKey = event.target.dataset.settingKey;
  if (settingKey) {
    updateSetting(state, settingKey, event.target.value);
    saveState(state);
    await syncServerSettingToCloud(settingKey);
  }
});

document.addEventListener("input", (event) => {
  const mapSectionAction = event.target.dataset.action;
  if (mapSectionAction === "map-section-search") {
    const sectionKey = event.target.dataset.section;
    if (sectionKey) {
      const sectionState = getMapSectionState(sectionKey);
      sectionState.search = event.target.value || "";
      render();
    }
    return;
  }

  if (mapSectionAction === "creature-library-search") {
    ui.creatureLibrarySearch = event.target.value || "";
    render();
    return;
  }

  if (mapSectionAction === "items-library-search") {
    ui.itemsLibrarySearch = event.target.value || "";
    render();
    return;
  }

  if (event.target.id === "imageUrlInput") {
    syncImagePreview();
  }
});

document.addEventListener("paste", (event) => {
  if (event.target && event.target.id === "imageUrlInput") {
    window.setTimeout(syncImagePreview, 0);
  }
});

document.addEventListener("submit", async (event) => {
  if (event.target.matches(".creature-inline-editor")) {
    event.preventDefault();
    const formData = new FormData(event.target);
    await saveCreaturePracticalForm(formData);
    return;
  }

  if (event.target.id === "adminForm") {
    event.preventDefault();
    const formData = new FormData(event.target);
    const collectionKey = formData.get("collectionKey");
    const entity = buildEntityFromForm(formData);
    const pending = ui.mapLinkPending;
    upsertEntity(state, collectionKey, entity);
    ui.admin.entityId = entity.id;
    if (
      pending &&
      pending.collectionKey === collectionKey &&
      pending.mapId
    ) {
      const pendingMapId = pending.mapId;
      linkEntityToMap(
        pendingMapId,
        pending.collectionKey,
        pending.linkField,
        entity.id
      );
      ui.mapLinkPending = null;
      ui.activeMapLinkPicker = null;
      ui.admin.collectionKey = "maps";
      persist();
      await syncEntityToCloud(collectionKey, entity.id);
      await syncMapToCloud(pendingMapId);
      return;
    }
    persist();
    await syncEntityToCloud(collectionKey, entity.id);
    return;
  }

  if (event.target.id === "imageUrlForm") {
    event.preventDefault();
    const formData = new FormData(event.target);
    const collectionKey = formData.get("collectionKey");
    const entityId = formData.get("entityId");
    const url = String(formData.get("url") || "").trim();
    ui.imageModal = null;
    render();
    await setEntityImage(
      collectionKey,
      entityId,
      url,
      "url"
    );
  }
});

filePicker.addEventListener("change", async (event) => {
  const file = event.target.files?.[0];
  const collectionKey = filePicker.dataset.collection;
  const entityId = filePicker.dataset.entityId;
  if (!file || !collectionKey || !entityId) return;

  const dataUrl = await readFileAsDataUrl(file);
  await setEntityImage(collectionKey, entityId, dataUrl, "local");
  filePicker.value = "";
});

if (stateFilePicker) {
  stateFilePicker.addEventListener("change", async (event) => {
    const file = event.target.files?.[0];
    if (!file) return;
    await importAtlasStateFromFile(file);
    stateFilePicker.value = "";
  });
}

function readFileAsDataUrl(file) {
  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.onload = () => resolve(String(reader.result));
    reader.onerror = reject;
    reader.readAsDataURL(file);
  });
}

render();
void initializeCloudAtlas();
