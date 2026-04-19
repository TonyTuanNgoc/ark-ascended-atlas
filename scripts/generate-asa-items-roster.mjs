import { writeFile } from "node:fs/promises";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const outputFile = path.join(__dirname, "..", "src", "asa-items-roster.js");

const IMPORT_VERSION = "2026-04-20";

const SOURCE_DEFS = [
  { bucket: "Resources", url: "https://ark.wiki.gg/wiki/Item_IDs/Resources" },
  { bucket: "Tools", url: "https://ark.wiki.gg/wiki/Item_IDs/Tools" },
  { bucket: "Armor", url: "https://ark.wiki.gg/wiki/Item_IDs/Armor" },
  { bucket: "Saddles", url: "https://ark.wiki.gg/wiki/Item_IDs/Saddles" },
  { bucket: "Structures", url: "https://ark.wiki.gg/wiki/Item_IDs/Structures" },
  { bucket: "Vehicles", url: "https://ark.wiki.gg/wiki/Item_IDs/Vehicles" },
  { bucket: "Dye", url: "https://ark.wiki.gg/wiki/Item_IDs/Dye" },
  { bucket: "Consumables", url: "https://ark.wiki.gg/wiki/Item_IDs/Consumables" },
  { bucket: "Recipes", url: "https://ark.wiki.gg/wiki/Item_IDs/Recipes" },
  { bucket: "Eggs", url: "https://ark.wiki.gg/wiki/Item_IDs/Eggs" },
  { bucket: "Farming", url: "https://ark.wiki.gg/wiki/Item_IDs/Farming" },
  { bucket: "Seeds", url: "https://ark.wiki.gg/wiki/Item_IDs/Seeds" },
  { bucket: "Weapons and Attachments", url: "https://ark.wiki.gg/wiki/Item_IDs/Weapons" },
  { bucket: "Ammunition", url: "https://ark.wiki.gg/wiki/Category:Ammunition", kind: "category" },
  { bucket: "Skins", url: "https://ark.wiki.gg/wiki/Item_IDs/Skins" },
  { bucket: "Chibi Pets", url: "https://ark.wiki.gg/wiki/Item_IDs/Chibi_Pets" },
  { bucket: "Artifacts", url: "https://ark.wiki.gg/wiki/Item_IDs/Artifacts" },
  { bucket: "Trophies", url: "https://ark.wiki.gg/wiki/Item_IDs/Trophy" },
];

const LEGACY_ID_BY_NAME = new Map([
  ["Pump-Action Shotgun", "item-shotgun"],
  ["Medical Brew", "item-medbrew"],
  ["Sweet Vegetable Cake", "item-veggie-cake"],
  ["Cryopod", "item-cryo"],
  ["Empty Cryopod", "item-cryo"],
  ["Gas Mask", "item-gasmask"],
  ["Industrial Forge", "item-industrial-forge"],
]);

const LIVE_ROOT_TO_DLC = new Map([
  ["PrimalEarth", "Base Game"],
  ["ScorchedEarth", "Scorched Earth"],
  ["Aberration", "Aberration"],
  ["Extinction", "Extinction"],
  ["TheCenter", "The Center"],
  ["Ragnarok", "Ragnarok"],
  ["Valguero", "Valguero"],
  ["Astraeos", "Astraeos"],
  ["LostColony", "Lost Colony"],
  ["ASA", "ASA"],
  ["Frontier", "Frontier"],
  ["Steampunk", "Steampunk"],
  ["Wasteland", "Wasteland"],
]);

const EXCLUDED_NAME_PATTERNS = [
  /^Ammunition$/i,
  /Primitive Plus/i,
  /^Admin /i,
];

const EXCLUDED_PATH_PATTERNS = [
  /\/Game\/Genesis\//i,
  /\/Game\/Genesis2\//i,
  /\/Game\/Mods\//i,
  /PrimitivePlus/i,
  /CrystalWyvern/i,
  /\/Game\/Abyss\//i,
  /\/Game\/Fjordur\//i,
  /\/Game\/LostIsland\//i,
  /\/Game\/CrystalIsles\//i,
];

function slugify(value) {
  return String(value || "")
    .toLowerCase()
    .replace(/&/g, "and")
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "");
}

function buildMirrorUrl(url) {
  return `https://r.jina.ai/http://${url}`;
}

async function fetchMirrorText(url) {
  const response = await fetch(buildMirrorUrl(url), {
    headers: {
      "User-Agent": "ark-ascended-atlas-item-import/1.0",
      Accept: "text/plain",
    },
  });

  if (!response.ok) {
    throw new Error(`Failed to fetch ${url}: ${response.status} ${response.statusText}`);
  }

  return response.text();
}

function extractImageUrl(markdown) {
  const match = markdown.match(/!\[[^\]]*]\(([^)]+)\)/);
  return match ? match[1].trim() : "";
}

function stripMarkdown(markdown) {
  return String(markdown || "")
    .replace(/\[\!\[[^\]]*]\([^)]+\)]\([^)]+\)/g, "")
    .replace(/!\[[^\]]*]\([^)]+\)/g, "")
    .replace(/\[([^\]]+)]\([^)]+\)/g, "$1")
    .replace(/[*_`"]/g, "")
    .replace(/&nbsp;/g, " ")
    .replace(/\s+/g, " ")
    .trim();
}

function extractCategoryColumn(cell, bucket) {
  const value = stripMarkdown(cell);
  return value || bucket;
}

function extractBlueprintPath(cell) {
  const match = String(cell || "").match(/Blueprint'([^']+)'/);
  return match ? match[1].trim() : "";
}

function deriveClassName(rawClassName, blueprintPath) {
  const clean = String(rawClassName || "").trim();
  if (clean && clean !== "-") return clean;
  if (!blueprintPath) return "";
  const blueprintName = blueprintPath.split("/").pop() || "";
  const dotParts = blueprintName.split(".");
  return dotParts[dotParts.length - 1] || "";
}

function parseTableRows(text, bucket) {
  const lines = String(text || "").split(/\r?\n/);
  const rows = [];

  for (const line of lines) {
    if (!line.trim().startsWith("|")) continue;
    if (/^\|\s*Name\s*\|/i.test(line)) continue;
    if (/^\|\s*---/.test(line)) continue;

    const cells = line.split("|").slice(1, -1).map((cell) => cell.trim());
    if (cells.length < 6) continue;

    const imageUrl = extractImageUrl(cells[0]);
    const name = stripMarkdown(cells[0]);
    const category = extractCategoryColumn(cells[1], bucket);
    const blueprintPath = extractBlueprintPath(cells[5]);
    const className = deriveClassName(cells[4], blueprintPath);

    if (!name) continue;

    rows.push({
      name,
      imageUrl,
      officialListGroup: bucket,
      officialIdCategory: category || bucket,
      officialSubcategory: "",
      className,
      blueprintPath,
      sourceUrl: "",
      sourceBucket: bucket,
    });
  }

  return rows;
}

function parseFlatRows(text, bucket) {
  const lines = String(text || "")
    .split(/\r?\n/)
    .map((line) => line.trim())
    .filter((line) => line.startsWith("[![Image"));
  const rows = [];

  for (const line of lines) {
    const imageUrl = extractImageUrl(line);
    const pathMatch = line.match(/"Blueprint'([^']+)'"/);
    const blueprintPath = pathMatch ? pathMatch[1].trim() : "";
    const prefix = pathMatch ? line.slice(0, pathMatch.index) : line;
    const links = [...prefix.matchAll(/\[([^\]]+)]\([^)]+\)/g)].map((match) => match[1]);
    const name = links[links.length >= 2 ? 1 : 0] || "";
    const category = links[links.length >= 3 ? 2 : 1] || bucket;
    const tail = prefix.replace(/\[\!\[[^\]]*]\([^)]+\)]\([^)]+\)/g, " ").replace(/\[[^\]]+]\([^)]+\)/g, " ");
    const tailTokens = tail
      .replace(/\s+/g, " ")
      .trim()
      .split(" ")
      .filter(Boolean);
    const className = deriveClassName(
      tailTokens.length ? tailTokens[tailTokens.length - 1] : "",
      blueprintPath
    );

    if (!name) continue;

    rows.push({
      name: stripMarkdown(name),
      imageUrl,
      officialListGroup: bucket,
      officialIdCategory: stripMarkdown(category) || bucket,
      officialSubcategory: "",
      className,
      blueprintPath,
      sourceUrl: "",
      sourceBucket: bucket,
    });
  }

  return rows;
}

function parseCategoryPage(text, bucket) {
  const rows = [];
  const lines = String(text || "").split(/\r?\n/);
  let inPages = false;

  for (const rawLine of lines) {
    const line = rawLine.trim();
    if (/^## Pages in category/i.test(line)) {
      inPages = true;
      continue;
    }
    if (!inPages) continue;
    if (/^Retrieved from /.test(line)) break;
    if (!line.startsWith("*")) continue;

    const match = line.match(/\[([^\]]+)]\((https:\/\/ark\.wiki\.gg\/wiki\/[^)]+)\s+"[^"]+"\)/);
    if (!match) continue;
    const name = stripMarkdown(match[1]);
    if (!name) continue;

    rows.push({
      name,
      imageUrl: "",
      officialListGroup: bucket,
      officialIdCategory: bucket,
      officialSubcategory: "",
      className: "",
      blueprintPath: "",
      sourceUrl: match[2],
      sourceBucket: bucket,
    });
  }

  return rows;
}

function extractRootFromPath(blueprintPath) {
  const match = String(blueprintPath || "").match(/^\/Game\/([^/]+)/);
  return match ? match[1] : "";
}

function inferDlc(blueprintPath) {
  const root = extractRootFromPath(blueprintPath);
  return LIVE_ROOT_TO_DLC.get(root) || "";
}

function shouldExcludeCandidate(candidate) {
  const name = String(candidate.name || "");
  const blueprintPath = String(candidate.blueprintPath || "");
  const className = String(candidate.className || "");

  for (const pattern of EXCLUDED_NAME_PATTERNS) {
    if (pattern.test(name)) {
      return { exclude: true, reason: "non-live-or-non-item-name" };
    }
  }

  if (/Admin/i.test(className) || /Admin/i.test(blueprintPath)) {
    return { exclude: true, reason: "admin-or-cheat-only" };
  }

  for (const pattern of EXCLUDED_PATH_PATTERNS) {
    if (pattern.test(blueprintPath)) {
      return { exclude: true, reason: "not-live-asa-scope" };
    }
  }

  if (blueprintPath) {
    const root = extractRootFromPath(blueprintPath);
    if (root && !LIVE_ROOT_TO_DLC.has(root)) {
      return { exclude: true, reason: "uncertain-live-scope" };
    }
  }

  return { exclude: false, reason: "" };
}

function buildItemRecord(candidate) {
  const id = LEGACY_ID_BY_NAME.get(candidate.name) || slugify(candidate.name);
  const imageSrc = candidate.imageUrl || "";
  const dlc = inferDlc(candidate.blueprintPath);

  return {
    id,
    name: candidate.name,
    officialListGroup: candidate.officialListGroup || "",
    officialIdCategory: candidate.officialIdCategory || candidate.officialListGroup || "",
    officialSubcategory: candidate.officialSubcategory || "",
    dlc,
    isLiveASA: true,
    isObtainable: true,
    media: {
      src: imageSrc,
      type: imageSrc ? "image" : "empty",
      alt: `${candidate.name} icon`,
      tone: "bronze",
    },
    notes: "",
    practicalNote: "",
    relatedCreatureIds: [],
    relatedBossIds: [],
    relatedMapIds: [],
  };
}

function mergeSecondaryCategory(record, candidate) {
  const nextOptions = [
    candidate.officialIdCategory || "",
    candidate.officialListGroup || "",
  ].filter(Boolean);

  const occupied = new Set(
    [record.officialListGroup, record.officialIdCategory, record.officialSubcategory]
      .map((value) => String(value || "").trim())
      .filter(Boolean)
  );

  for (const nextCategory of nextOptions) {
    if (!occupied.has(nextCategory) && !record.officialSubcategory) {
      return {
        ...record,
        officialSubcategory: nextCategory,
      };
    }
  }

  return record;
}

async function fetchCandidates() {
  const candidates = [];
  const sourceMeta = [];

  for (const source of SOURCE_DEFS) {
    const text = await fetchMirrorText(source.url);
    let parsed = [];

    if (source.kind === "category") {
      parsed = parseCategoryPage(text, source.bucket);
    } else if (text.includes("| Name | Category |")) {
      parsed = parseTableRows(text, source.bucket);
    } else {
      parsed = parseFlatRows(text, source.bucket);
    }

    parsed = parsed.map((entry) => ({
      ...entry,
      sourceUrl: source.url,
      sourceBucket: source.bucket,
    }));

    candidates.push(...parsed);
    sourceMeta.push({
      bucket: source.bucket,
      url: source.url,
      parsedCount: parsed.length,
    });
  }

  return { candidates, sourceMeta };
}

function compileRoster(candidates) {
  const excluded = [];
  const excludedKeys = new Set();
  const includedByKey = new Map();
  const includedKeyByNameSlug = new Map();
  let duplicateMergedCount = 0;

  for (const candidate of candidates) {
    const evaluation = shouldExcludeCandidate(candidate);
    const nameSlug = slugify(candidate.name);
    const primaryKey = candidate.className || candidate.blueprintPath || nameSlug;
    const key =
      includedByKey.has(primaryKey)
        ? primaryKey
        : includedKeyByNameSlug.get(nameSlug) || primaryKey;

    if (evaluation.exclude) {
      const excludedKey = primaryKey || nameSlug;
      if (!excludedKeys.has(excludedKey)) {
        excludedKeys.add(excludedKey);
        excluded.push({
          key: excludedKey,
          name: candidate.name,
          reason: evaluation.reason,
          sourceBucket: candidate.sourceBucket,
          sourceUrl: candidate.sourceUrl,
        });
      }
      continue;
    }

    if (!includedByKey.has(key)) {
      const record = buildItemRecord(candidate);
      includedByKey.set(key, record);
      includedKeyByNameSlug.set(nameSlug, key);
      continue;
    }

    duplicateMergedCount += 1;
    const existing = includedByKey.get(key);
    const merged = mergeSecondaryCategory(existing, candidate);

    if (!merged.media?.src && candidate.imageUrl) {
      merged.media = {
        src: candidate.imageUrl,
        type: "image",
        alt: `${candidate.name} icon`,
        tone: "bronze",
      };
    }

    if (!merged.dlc && candidate.blueprintPath) {
      merged.dlc = inferDlc(candidate.blueprintPath);
    }

    includedByKey.set(key, merged);
  }

  const items = [...includedByKey.values()].sort((a, b) => a.name.localeCompare(b.name));
  const countsByOfficialCategory = items.reduce((acc, item) => {
    const key = item.officialIdCategory || "Unclassified";
    acc[key] = (acc[key] || 0) + 1;
    return acc;
  }, {});

  const excludedByReason = excluded.reduce((acc, entry) => {
    acc[entry.reason] = (acc[entry.reason] || 0) + 1;
    return acc;
  }, {});

  return {
    items,
    stats: {
      totalImported: items.length,
      countsByOfficialCategory,
      excludedCount: excluded.length,
      excludedByReason,
      uncertainExcludedCount: (excludedByReason["uncertain-live-scope"] || 0),
      duplicateMergedCount,
    },
    excluded,
  };
}

async function main() {
  const { candidates, sourceMeta } = await fetchCandidates();
  const { items, stats, excluded } = compileRoster(candidates);

  const fileContents = `export const ASA_ITEM_IMPORT_VERSION = ${JSON.stringify(IMPORT_VERSION)};
export const ASA_IMPORTED_ITEMS = ${JSON.stringify(items, null, 2)};
export const ASA_ITEM_IMPORT_STATS = ${JSON.stringify(
    {
      ...stats,
      sourceMeta,
      excludedPreview: excluded.slice(0, 40),
    },
    null,
    2
  )};
`;

  await writeFile(outputFile, fileContents, "utf8");

  console.log(
    JSON.stringify(
      {
        outputFile,
        ...stats,
      },
      null,
      2
    )
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
