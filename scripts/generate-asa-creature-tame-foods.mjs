import { execFile } from "node:child_process";
import { writeFile } from "node:fs/promises";
import path from "node:path";
import { promisify } from "node:util";
import { fileURLToPath } from "node:url";

import { ASA_IMPORTED_CREATURES } from "../src/asa-creature-roster.js";
import { ASA_IMPORTED_ITEMS } from "../src/asa-items-roster.js";
import { ASA_IMPORTED_ITEM_SUPPLEMENTS } from "../src/asa-item-supplements.js";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const outputFile = path.join(__dirname, "..", "src", "asa-creature-tame-foods.js");

const IMPORT_VERSION = "2026-04-20";
const HUB_URL = "https://arkstatus.com/taming/";
const PAGE_PREFIX = "https://arkstatus.com/taming/";
const execFileAsync = promisify(execFile);
const IMPORTED_ITEM_ROSTER = [...ASA_IMPORTED_ITEMS, ...ASA_IMPORTED_ITEM_SUPPLEMENTS];

const HIDDEN_SLUG_ALIASES = new Map([
  ["parasaur", ["parasaurolophus"]],
  ["quetzal", ["quetzalcoatlus"]],
  ["sarco", ["sarcosuchus"]],
  ["pachy", ["pachycephalosaurus"]],
  ["dire-bear", ["direbear"]],
  ["dilophosaur", ["dilophosaurus"]],
  ["spino", ["spinosaurus"]],
  ["therizinosaur", ["therizinosaurus"]],
  ["rock-drake", ["rock-drake"]],
  ["bison", ["bison"]],
  ["carcharodontosaurus", ["carcharodontosaurus"]],
  ["ceratosaurus", ["ceratosaurus"]],
  ["pyromane", ["pyromane"]],
  ["desmodus", ["desmodus"]],
  ["deinosuchus", ["deinosuchus"]],
  ["deinonychus", ["deinonychus"]],
  ["dreadnoughtus", ["dreadnoughtus"]],
  ["cat", ["cat"]],
  ["armadoggo", ["armadoggo"]],
  ["veilwyn", ["veilwyn"]],
  ["xiphactinus", ["xiphactinus"]],
  ["yi-ling", ["yi-ling"]],
  ["shastasaurus", ["shastasaurus"]],
]);

const MANUAL_OVERRIDES = {
  achatina: {
    sourceLabel: "ARK Official Community Wiki",
    sourceUrl: "https://ark.wiki.gg/wiki/Achatina",
    tameFood: "Sweet Vegetable Cake",
    tameFoodEntries: [
      {
        label: "Sweet Vegetable Cake",
        itemId: "item-veggie-cake",
      },
    ],
  },
  acrocanthosaurus: {
    sourceLabel: "ARK Official Community Wiki",
    sourceUrl: "https://ark.wiki.gg/wiki/Acrocanthosaurus",
    tameFood:
      "Exceptional Kibble / Raw Mutton / Cooked Lamb Chop / Raw Prime Meat / Cooked Prime Meat",
    tameFoodEntries: [
      {
        label: "Exceptional Kibble",
        itemId: "exceptional-kibble",
      },
      {
        label: "Raw Mutton",
        itemId: "raw-mutton",
      },
      {
        label: "Cooked Lamb Chop",
        itemId: "cooked-lamb-chop",
      },
      {
        label: "Raw Prime Meat",
        itemId: "raw-prime-meat",
      },
      {
        label: "Cooked Prime Meat",
        itemId: "cooked-prime-meat",
      },
    ],
  },
};

const ITEM_NAME_ALIASES = new Map([
  ["archelon algae", ["archelon algae"]],
  ["archelon algae asa", ["archelon algae"]],
  ["berries", ["berries"]],
  ["mejoberries", ["mejoberry"]],
  ["amarberries", ["amarberry"]],
  ["azulberries", ["azulberry"]],
  ["tintoberries", ["tintoberry"]],
  ["stimberries", ["stimberry"]],
  ["narcoberries", ["narcoberry"]],
  ["crops", ["crops"]],
  ["vegetables", ["crops"]],
  ["raw fish", ["raw fish meat"]],
  ["raw fish meat", ["raw fish meat"]],
  ["cooked fish", ["cooked fish meat"]],
  ["cooked fish meat", ["cooked fish meat"]],
  ["raw prime fish", ["raw prime fish meat"]],
  ["raw prime fish meat", ["raw prime fish meat"]],
  ["cooked prime fish", ["cooked prime fish meat"]],
  ["cooked prime fish meat", ["cooked prime fish meat"]],
  ["raw meat", ["raw meat"]],
  ["cooked meat", ["cooked meat"]],
  ["raw prime meat", ["raw prime meat"]],
  ["cooked prime meat", ["cooked prime meat"]],
  ["prime meat jerky", ["prime meat jerky"]],
  ["raw mutton", ["raw mutton"]],
  ["cooked lamb chop", ["cooked lamb chop"]],
  ["basic kibble", ["basic kibble"]],
  ["simple kibble", ["simple kibble"]],
  ["regular kibble", ["regular kibble"]],
  ["superior kibble", ["superior kibble"]],
  ["exceptional kibble", ["exceptional kibble"]],
  ["extraordinary kibble", ["extraordinary kibble"]],
  ["sweet vegetable cake", ["sweet vegetable cake", "sweet veggie cake"]],
  ["sweet veggie cake", ["sweet vegetable cake", "sweet veggie cake"]],
  ["giant bee honey", ["giant bee honey"]],
  ["rare flower", ["rare flower"]],
  ["rare mushroom", ["rare mushroom"]],
  ["bio toxin", ["bio toxin"]],
  ["spoiled meat", ["spoiled meat"]],
  ["raw salt", ["raw salt"]],
  ["blood pack", ["blood pack"]],
  ["cactus sap", ["cactus sap"]],
  ["leech blood", ["leech blood"]],
  ["element", ["element"]],
  ["charge battery", ["charge battery"]],
  ["charged battery", ["charge battery"]],
  ["basilosaurus blubber", ["basilosaurus blubber"]],
  ["blubber", ["basilosaurus blubber"]],
  ["mutagel", ["mutagel"]],
  ["plant species z seed", ["plant species z seed"]],
  ["nameless venom", ["nameless venom"]],
  ["rock drake egg", ["rock drake egg"]],
  ["fertilized rock drake egg", ["fertilized rock drake egg", "rock drake egg"]],
  ["giganotosaurus egg", ["giganotosaurus egg"]],
  ["fertilized giganotosaurus egg", ["fertilized giganotosaurus egg", "giganotosaurus egg"]],
  ["quetzal egg", ["quetzal egg"]],
  ["fertilized quetzal egg", ["fertilized quetzal egg", "quetzal egg"]],
  ["tek quetzal egg", ["tek quetzal egg"]],
  ["fertilized tek quetzal egg", ["fertilized tek quetzal egg", "tek quetzal egg"]],
  ["voidwyrm egg", ["voidwyrm egg"]],
  ["wyvern egg", ["wyvern egg"]],
  ["fertilized magmasaur egg", ["fertilized magmasaur egg"]],
]);

function normalizeLookup(value) {
  return String(value || "")
    .toLowerCase()
    .replace(/\([^)]*\)/g, " ")
    .replace(/[^a-z0-9]+/g, " ")
    .replace(/\s+/g, " ")
    .trim();
}

function slugifyDash(value) {
  return String(value || "")
    .trim()
    .toLowerCase()
    .replace(/&/g, "and")
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "");
}

function slugifyTight(value) {
  return slugifyDash(value).replace(/-/g, "");
}

async function fetchText(url) {
  try {
    const { stdout } = await execFileAsync(
      "curl",
      ["-L", "-s", "--max-time", "12", url],
      {
        encoding: "utf8",
        maxBuffer: 32 * 1024 * 1024,
      }
    );
    return stdout;
  } catch (error) {
    const details = error?.stderr || error?.stdout || error?.message || "curl failed";
    throw new Error(String(details).trim());
  }
}

function extractHubEntries(html) {
  const scripts = [
    ...String(html || "").matchAll(
      /<script[^>]*type="application\/ld\+json"[^>]*>([\s\S]*?)<\/script>/g
    ),
  ];

  for (const match of scripts) {
    const blob = String(match[1] || "").trim();
    if (!blob.includes('"itemListElement"')) continue;
    const parsed = JSON.parse(blob);
    if (Array.isArray(parsed.itemListElement)) {
      return parsed.itemListElement;
    }
  }

  return [];
}

function extractPageFoods(html) {
  const foods = [];
  const seen = new Set();

  for (const match of String(html || "").matchAll(/data-food="([^"]+)"/g)) {
    const label = String(match[1] || "").trim();
    const normalized = normalizeLookup(label);
    if (!normalized || seen.has(normalized)) continue;
    seen.add(normalized);
    foods.push(label);
    if (foods.length >= 5) break;
  }

  return foods;
}

function buildItemLookup(items) {
  const lookup = new Map();

  for (const item of items) {
    const itemName = String(item.name || "").trim();
    if (!itemName) continue;

    const variants = new Set([normalizeLookup(itemName)]);

    if (/berry$/i.test(itemName)) {
      variants.add(normalizeLookup(itemName.replace(/berry$/i, "berries")));
    }

    if (/ meat$/i.test(itemName)) {
      variants.add(normalizeLookup(itemName.replace(/\s+meat$/i, "")));
    }

    (ITEM_NAME_ALIASES.get(normalizeLookup(itemName)) || []).forEach((alias) => {
      variants.add(normalizeLookup(alias));
    });

    variants.forEach((variant) => {
      if (variant && !lookup.has(variant)) {
        lookup.set(variant, item);
      }
    });
  }

  return lookup;
}

function resolveItemMatch(label, itemLookup) {
  const normalized = normalizeLookup(label);
  if (!normalized) return null;

  const direct = itemLookup.get(normalized);
  if (direct) return direct;

  const aliasTargets = ITEM_NAME_ALIASES.get(normalized) || [];
  for (const alias of aliasTargets) {
    const match = itemLookup.get(normalizeLookup(alias));
    if (match) return match;
  }

  return null;
}

function toRecordEntry(foodLabels, itemLookup) {
  const tameFoodEntries = [];
  const seen = new Set();

  for (const label of foodLabels) {
    const normalized = normalizeLookup(label);
    if (!normalized || seen.has(normalized)) continue;
    seen.add(normalized);

    const item = resolveItemMatch(label, itemLookup);
    tameFoodEntries.push({
      label,
      itemId: item?.id || "",
    });

    if (tameFoodEntries.length >= 5) break;
  }

  return {
    tameFood: tameFoodEntries.map((entry) => entry.label).join(" / "),
    tameFoodEntries,
  };
}

function buildHubLookup(entries) {
  const lookup = new Map();

  for (const entry of entries) {
    const name = String(entry.name || "").trim();
    const url = String(entry.url || "").trim();
    if (!name || !url) continue;

    lookup.set(normalizeLookup(name), {
      name,
      url,
      slug: url.replace(PAGE_PREFIX, "").replace(/\/+$/, ""),
    });
  }

  return lookup;
}

function getCandidatePages(creature, hubLookup) {
  const candidates = [];
  const seen = new Set();

  const push = (slug, sourceLabel) => {
    const safeSlug = String(slug || "").trim();
    if (!safeSlug || seen.has(safeSlug)) return;
    seen.add(safeSlug);
    candidates.push({
      slug: safeSlug,
      url: `${PAGE_PREFIX}${safeSlug}`,
      sourceLabel,
    });
  };

  const hubEntry =
    hubLookup.get(normalizeLookup(creature.name)) ||
    hubLookup.get(normalizeLookup(creature.id));
  if (hubEntry) {
    push(hubEntry.slug, "ARK Status");
  }

  const aliasSlugs = HIDDEN_SLUG_ALIASES.get(creature.id) || [];
  aliasSlugs.forEach((slug) => push(slug, "ARK Status"));

  return candidates;
}

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

async function resolveCreaturePage(creature, hubLookup) {
  const candidates = getCandidatePages(creature, hubLookup);

  for (const candidate of candidates) {
    try {
      const html = await fetchText(candidate.url);
      const foods = extractPageFoods(html);
      if (!foods.length) continue;
      return {
        sourceLabel: candidate.sourceLabel,
        sourceUrl: candidate.url,
        foods,
      };
    } catch {
      // Ignore candidate fetch failures and try the next slug.
    }
  }

  return null;
}

async function main() {
  const itemLookup = buildItemLookup(IMPORTED_ITEM_ROSTER);
  const hubHtml = await fetchText(HUB_URL);
  const hubLookup = buildHubLookup(extractHubEntries(hubHtml));
  const records = {};
  const unresolvedCreaturePages = [];

  for (const creature of ASA_IMPORTED_CREATURES) {
    const resolved = await resolveCreaturePage(creature, hubLookup);
    if (!resolved) {
      unresolvedCreaturePages.push(creature.name);
      await sleep(120);
      continue;
    }

    records[creature.id] = {
      sourceLabel: resolved.sourceLabel,
      sourceUrl: resolved.sourceUrl,
      ...toRecordEntry(resolved.foods, itemLookup),
    };
    await sleep(120);
  }

  Object.entries(MANUAL_OVERRIDES).forEach(([creatureId, entry]) => {
    if (!records[creatureId]) {
      records[creatureId] = entry;
    }
  });

  const unresolvedFoodLinks = Object.entries(records)
    .flatMap(([creatureId, entry]) =>
      entry.tameFoodEntries
        .filter((food) => !food.itemId)
        .map((food) => `${creatureId}: ${food.label}`)
    )
    .sort((left, right) => left.localeCompare(right));

  const fileContents = `${[
    `export const ASA_CREATURE_TAME_FOOD_IMPORT_VERSION = "${IMPORT_VERSION}";`,
    `export const ASA_IMPORTED_CREATURE_TAME_FOODS = ${JSON.stringify(records, null, 2)};`,
  ].join("\n\n")}\n`;

  await writeFile(outputFile, fileContents, "utf8");

  console.log(`Generated ${Object.keys(records).length} creature tame-food entries.`);
  console.log(`Creatures without ARK Status tame-food page: ${unresolvedCreaturePages.length}`);
  if (unresolvedCreaturePages.length) {
    console.log(unresolvedCreaturePages.sort((left, right) => left.localeCompare(right)).join("\n"));
  }
  console.log(`Unmatched tame-food item links: ${unresolvedFoodLinks.length}`);
  if (unresolvedFoodLinks.length) {
    console.log(unresolvedFoodLinks.join("\n"));
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
