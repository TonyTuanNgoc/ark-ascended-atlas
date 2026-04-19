import { ENTITY_TYPES } from "./data.js";
import { ensureAtlasWriteAccess } from "./cloud-auth.js";
import { getFirebaseServices } from "./firebase-client.js";

const CLOUD_COLLECTION_KEYS = [
  ...ENTITY_TYPES.map((entry) => entry.key),
  "rankings",
  "serverSettings",
];

const META_DOC = {
  collection: "atlasMeta",
  id: "default",
};

function getEntityId(entry) {
  if (!entry || typeof entry !== "object") return null;
  return entry.id || entry.key || null;
}

function sanitizeForCloud(value) {
  if (value === undefined) return undefined;
  if (
    value == null ||
    typeof value === "string" ||
    typeof value === "number" ||
    typeof value === "boolean"
  ) {
    return value;
  }

  if (Array.isArray(value)) {
    return value
      .map((entry) => sanitizeForCloud(entry))
      .filter((entry) => entry !== undefined);
  }

  if (typeof value === "object") {
    if (typeof value.toDate === "function") {
      return value.toDate().toISOString();
    }

    const output = {};
    Object.entries(value).forEach(([key, entry]) => {
      const sanitized = sanitizeForCloud(entry);
      if (sanitized !== undefined) {
        output[key] = sanitized;
      }
    });
    return output;
  }

  return undefined;
}

function getCollectionPath(collectionKey) {
  return collectionKey;
}

function getMediaStoragePath(collectionKey, entityId, dataUrl) {
  const mimeMatch = /^data:(image\/[a-zA-Z0-9.+-]+);base64,/.exec(dataUrl || "");
  const mimeType = mimeMatch?.[1] || "image/png";
  const extension = mimeType.split("/")[1]?.replace("jpeg", "jpg") || "png";
  return `atlas-media/${collectionKey}/${entityId}/${Date.now()}.${extension}`;
}

async function deleteStorageObject(storage, storageApi, path) {
  if (!path) return;
  try {
    await storageApi.deleteObject(storageApi.ref(storage, path));
  } catch (error) {
    console.warn("Atlas could not delete prior storage object.", error);
  }
}

export async function loadCloudAtlasData() {
  const services = await getFirebaseServices();
  if (!services) return null;

  try {
    const [metaSnapshot, ...collectionSnapshots] = await Promise.all([
      services.firestoreApi.getDoc(
        services.firestoreApi.doc(services.db, META_DOC.collection, META_DOC.id)
      ),
      ...CLOUD_COLLECTION_KEYS.map((key) =>
        services.firestoreApi.getDocs(
          services.firestoreApi.collection(services.db, getCollectionPath(key))
        )
      ),
    ]);

    const payload = {};

    if (metaSnapshot.exists()) {
      payload.meta = sanitizeForCloud(metaSnapshot.data());
    }

    CLOUD_COLLECTION_KEYS.forEach((key, index) => {
      const docs = collectionSnapshots[index].docs.map((doc) => sanitizeForCloud(doc.data()));
      if (docs.length) {
        payload[key] = docs;
      }
    });

    return Object.keys(payload).length ? payload : null;
  } catch (error) {
    console.warn("Atlas cloud load failed; continuing with local state.", error);
    return null;
  }
}

export async function saveAtlasMetaToCloud(meta) {
  const services = await getFirebaseServices();
  if (!services) return false;

  const user = await ensureAtlasWriteAccess();
  if (!user) return false;

  try {
    await services.firestoreApi.setDoc(
      services.firestoreApi.doc(services.db, META_DOC.collection, META_DOC.id),
      {
        ...sanitizeForCloud(meta),
        updatedAt: new Date().toISOString(),
      },
      { merge: true }
    );
    return true;
  } catch (error) {
    console.warn("Atlas meta cloud save failed.", error);
    return false;
  }
}

export async function saveAtlasEntityToCloud(collectionKey, entity) {
  const entityId = getEntityId(entity);
  if (!collectionKey || !entityId) return false;

  const services = await getFirebaseServices();
  if (!services) return false;

  const user = await ensureAtlasWriteAccess();
  if (!user) return false;

  try {
    await services.firestoreApi.setDoc(
      services.firestoreApi.doc(services.db, getCollectionPath(collectionKey), entityId),
      {
        ...sanitizeForCloud(entity),
        updatedAt: new Date().toISOString(),
      },
      { merge: true }
    );
    return true;
  } catch (error) {
    console.warn(`Atlas cloud save failed for ${collectionKey}/${entityId}.`, error);
    return false;
  }
}

export async function saveAtlasEntityMediaToCloud(collectionKey, entity, src, type = "url") {
  const entityId = getEntityId(entity);
  if (!collectionKey || !entityId || !entity) return null;

  const services = await getFirebaseServices();
  if (!services) return null;

  const user = await ensureAtlasWriteAccess();
  if (!user) return null;

  try {
    let mediaSrc = src;
    let mediaType = type;
    let storagePath = entity.media?.storagePath || "";

    if (type === "local" && typeof src === "string" && src.startsWith("data:image/")) {
      const nextPath = getMediaStoragePath(collectionKey, entityId, src);
      await deleteStorageObject(services.storage, services.storageApi, storagePath);

      const storageRef = services.storageApi.ref(services.storage, nextPath);
      await services.storageApi.uploadString(storageRef, src, "data_url");
      mediaSrc = await services.storageApi.getDownloadURL(storageRef);
      mediaType = "storage";
      storagePath = nextPath;
    } else if (storagePath) {
      await deleteStorageObject(services.storage, services.storageApi, storagePath);
      storagePath = "";
    }

    const nextEntity = {
      ...entity,
      media: {
        ...(entity.media || {}),
        src: mediaSrc,
        type: mediaType,
        storagePath,
      },
    };

    const saved = await saveAtlasEntityToCloud(collectionKey, nextEntity);
    return saved ? nextEntity : null;
  } catch (error) {
    console.warn(`Atlas media cloud save failed for ${collectionKey}/${entityId}.`, error);
    return null;
  }
}

export async function removeAtlasEntityMediaFromCloud(collectionKey, entity) {
  const entityId = getEntityId(entity);
  if (!collectionKey || !entityId || !entity) return null;

  const services = await getFirebaseServices();
  if (!services) return null;

  const user = await ensureAtlasWriteAccess();
  if (!user) return null;

  try {
    await deleteStorageObject(
      services.storage,
      services.storageApi,
      entity.media?.storagePath || ""
    );

    const nextEntity = {
      ...entity,
      media: {
        ...(entity.media || {}),
        src: "",
        type: "empty",
        storagePath: "",
      },
    };

    const saved = await saveAtlasEntityToCloud(collectionKey, nextEntity);
    return saved ? nextEntity : null;
  } catch (error) {
    console.warn(`Atlas media cloud removal failed for ${collectionKey}/${entityId}.`, error);
    return null;
  }
}
