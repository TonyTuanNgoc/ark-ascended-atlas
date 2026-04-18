import { defaultData } from "./data.js";

const STORAGE_KEY = "ark-ascended-atlas-state-v1";

const clone = (value) => JSON.parse(JSON.stringify(value));

export const loadState = () => {
  try {
    const raw = window.localStorage.getItem(STORAGE_KEY);
    if (!raw) return clone(defaultData);
    const parsed = JSON.parse(raw);
    return mergeWithDefaults(parsed, defaultData);
  } catch (error) {
    console.warn("Failed to load atlas state:", error);
    return clone(defaultData);
  }
};

export const saveState = (state) => {
  window.localStorage.setItem(STORAGE_KEY, JSON.stringify(state));
};

export const resetState = () => {
  const fresh = clone(defaultData);
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
    return Array.isArray(saved) ? saved : clone(base);
  }

  if (base && typeof base === "object") {
    const output = {};
    const source = saved && typeof saved === "object" ? saved : {};

    for (const [key, value] of Object.entries(base)) {
      if (Array.isArray(value)) {
        output[key] = Array.isArray(source[key]) ? source[key] : clone(value);
      } else if (value && typeof value === "object") {
        output[key] = mergeWithDefaults(source[key], value);
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
