import { FIREBASE_SDK_VERSION, firebaseConfig } from "./firebase-config.js";

let firebaseServicesPromise = null;

export async function getFirebaseServices() {
  if (firebaseServicesPromise) {
    return firebaseServicesPromise;
  }

  firebaseServicesPromise = (async () => {
    try {
      const [
        appModule,
        authModule,
        firestoreModule,
        storageModule,
      ] = await Promise.all([
        import(`https://www.gstatic.com/firebasejs/${FIREBASE_SDK_VERSION}/firebase-app.js`),
        import(`https://www.gstatic.com/firebasejs/${FIREBASE_SDK_VERSION}/firebase-auth.js`),
        import(`https://www.gstatic.com/firebasejs/${FIREBASE_SDK_VERSION}/firebase-firestore.js`),
        import(`https://www.gstatic.com/firebasejs/${FIREBASE_SDK_VERSION}/firebase-storage.js`),
      ]);

      const app = appModule.getApps().length
        ? appModule.getApp()
        : appModule.initializeApp(firebaseConfig);

      return {
        app,
        auth: authModule.getAuth(app),
        db: firestoreModule.getFirestore(app),
        storage: storageModule.getStorage(app),
        authApi: authModule,
        firestoreApi: firestoreModule,
        storageApi: storageModule,
      };
    } catch (error) {
      console.warn("Firebase SDK unavailable, Atlas will stay on local data.", error);
      firebaseServicesPromise = null;
      return null;
    }
  })();

  return firebaseServicesPromise;
}
