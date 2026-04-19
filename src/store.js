import { defaultData } from "./data.js";

export const STORAGE_KEY = "ark-ascended-atlas-state-v1";
const STORAGE_SCHEMA_VERSION = 4;
const STORAGE_SCHEMA_KEY = "__schemaVersion";

const clone = (value) => JSON.parse(JSON.stringify(value));

function unwrapPersistedPayload(payload) {
  if (!payload || typeof payload !== "object") return null;
  if (Object.prototype.hasOwnProperty.call(payload, STORAGE_SCHEMA_KEY)) {
    return payload;
  }
  if (payload.state && typeof payload.state === "object") return payload.state;
  return null;
}

export const normalizeAtlasState = (payload = {}) => {
  const source = unwrapPersistedPayload(payload) || payload || {};
  const normalized = mergeWithDefaults(source, defaultData);
  normalized[STORAGE_SCHEMA_KEY] = STORAGE_SCHEMA_VERSION;
  return normalized;
};

const getEntityId = (entry) => {
  if (!entry || typeof entry !== "object") return null;
  if (entry.id) return entry.id;
  if (entry.key) return entry.key;
  return null;
};

function mergeArrays(base, saved) {
  if (!Array.isArray(base) || !Array.isArray(saved)) {
    return Array.isArray(saved) ? saved : clone(base);
  }

  const baseEntries = new Map();
  const ids = [];
  const allSavable = base.every((entry) => getEntityId(entry));
  if (!allSavable) {
    return saved;
  }

  for (const baseEntry of base) {
    const id = getEntityId(baseEntry);
    if (!ids.includes(id)) {
      ids.push(id);
    }
    baseEntries.set(id, baseEntry);
  }

  const used = new Set();
  const merged = [];

  for (const savedEntry of saved) {
    const id = getEntityId(savedEntry);
    if (!id) {
      merged.push(savedEntry);
      continue;
    }

    if (baseEntries.has(id)) {
      merged.push(mergeWithDefaults(savedEntry, baseEntries.get(id)));
    } else {
      merged.push(savedEntry);
    }
    used.add(id);
  }

  for (const id of ids) {
    if (!used.has(id)) {
      merged.push(clone(baseEntries.get(id)));
    }
  }

  return merged;
}

export const loadState = () => {
  try {
    const raw = window.localStorage.getItem(STORAGE_KEY);
    if (!raw) {
      return normalizeAtlasState();
    }

    const parsed = JSON.parse(raw);
    const needsMigration =
      !(STORAGE_SCHEMA_KEY in parsed) ||
      parsed[STORAGE_SCHEMA_KEY] !== STORAGE_SCHEMA_VERSION;

    if (needsMigration && Array.isArray(parsed.dinos)) {
      const metaFields = [
        "roleTags", "tameDifficulty", "timeToValue", "costPayoff",
        "transferValue", "bossRelevance", "tameFood", "tameMethod",
      ];
      parsed.dinos = parsed.dinos.map((dino) => {
        const clean = { ...dino };
        for (const f of metaFields) {
          const v = clean[f];
          if (v === undefined || v === null || v === "" || (Array.isArray(v) && v.length === 0)) {
            delete clean[f];
          }
        }
        return clean;
      });
    }

    const migrated = normalizeAtlasState(parsed);
    if (needsMigration) {
      saveState(migrated);
    }
    return migrated;
  } catch (error) {
    console.warn("Failed to load atlas state:", error);
    return normalizeAtlasState();
  }
};

export const saveState = (state) => {
  const payload = {
    ...state,
    [STORAGE_SCHEMA_KEY]: STORAGE_SCHEMA_VERSION,
  };
  window.localStorage.setItem(STORAGE_KEY, JSON.stringify(payload));
};

export const resetState = () => {
  const fresh = clone(defaultData);
  fresh[STORAGE_SCHEMA_KEY] = STORAGE_SCHEMA_VERSION;
  saveState(fresh);
  return fresh;
};

export const findEntity = (state, collectionKey, id) =>
  (state[collectionKey] || []).find((entry) => entry.id === id);

export const updateEntity = (state, collectionKey, entityId, updater) => {
  state[collectionKey] = (state[collectionKey] || []).map((entity) =>
    entity.id === entityId ? updater(entity) : entity
  );
  return state;
};

export const upsertEntity = (state, collectionKey, entity) => {
  const collection = state[collectionKey] || [];
  const index = collection.findIndex((entry) => entry.id === entity.id);
  if (index >= 0) {
    collection[index] = { ...collection[index], ...entity };
  } else {
    collection.push(entity);
  }
  state[collectionKey] = collection;
  return state;
};

export const updateSetting = (state, key, value) => {
  state.serverSettings = state.serverSettings.map((setting) =>
    setting.key === key ? { ...setting, value } : setting
  );
  return state;
};

function mergeWithDefaults(saved, base) {
  if (Array.isArray(base)) {
    return mergeArrays(base, saved);
  }

  if (base && typeof base === "object") {
    const output = {};
    const source = saved && typeof saved === "object" ? saved : {};

    for (const [key, value] of Object.entries(base)) {
      if (Array.isArray(value)) {
        output[key] = Array.isArray(source[key]) ? source[key] : clone(value);
      } else if (value && typeof value === "object") {
        output[key] = mergeWithDefaults(source[key], value);
      } else if (key === "src") {
        output[key] = source[key] || value;
      } else if (key === "type" && source[key] === "empty" && value !== "empty") {
        output[key] = value;
      } else {
        output[key] = source[key] ?? value;
      }
    }

    for (const [key, value] of Object.entries(source)) {
      if (!(key in output)) {
        output[key] = value;
      }
    }

    return output;
  }

  return saved ?? base;
}
