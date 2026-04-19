import { getFirebaseServices } from "./firebase-client.js";

let authStatePromise = null;

export async function waitForAtlasUser() {
  const services = await getFirebaseServices();
  if (!services) return null;

  if (services.auth.currentUser) {
    return services.auth.currentUser;
  }

  if (!authStatePromise) {
    authStatePromise = new Promise((resolve) => {
      const unsubscribe = services.authApi.onAuthStateChanged(services.auth, (user) => {
        unsubscribe();
        authStatePromise = null;
        resolve(user || null);
      });
    });
  }

  return authStatePromise;
}

export async function ensureAtlasWriteAccess() {
  const services = await getFirebaseServices();
  if (!services) return null;

  const existingUser = services.auth.currentUser || await waitForAtlasUser();
  if (existingUser) {
    return existingUser;
  }

  try {
    const anonymousResult = await services.authApi.signInAnonymously(
      services.auth
    );
    return anonymousResult.user || null;
  } catch (anonymousError) {
    console.warn(
      "Atlas anonymous auth unavailable; falling back to interactive sign-in.",
      anonymousError
    );
  }

  try {
    const provider = new services.authApi.GoogleAuthProvider();
    const result = await services.authApi.signInWithPopup(services.auth, provider);
    return result.user || null;
  } catch (error) {
    console.warn("Atlas cloud write cancelled or failed; local persistence kept active.", error);
    return null;
  }
}
