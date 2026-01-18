// File generated for Pet Circle Firebase project
// Project ID: pet-circle-app

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return web; // Use web config for Windows
      case TargetPlatform.linux:
        return web; // Use web config for Linux
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDakccCpRIASOwcyl0r08xwunRpVU_L8sA',
    appId: '1:999352037269:web:b6fc3103e6f3a9b419d09c',
    messagingSenderId: '999352037269',
    projectId: 'pet-circle-app',
    authDomain: 'pet-circle-app.firebaseapp.com',
    storageBucket: 'pet-circle-app.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDakccCpRIASOwcyl0r08xwunRpVU_L8sA',
    appId: '1:999352037269:android:a53d2788fdbee30519d09c',
    messagingSenderId: '999352037269',
    projectId: 'pet-circle-app',
    storageBucket: 'pet-circle-app.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDakccCpRIASOwcyl0r08xwunRpVU_L8sA',
    appId: '1:999352037269:ios:a02ee9ef3d7fa48d19d09c',
    messagingSenderId: '999352037269',
    projectId: 'pet-circle-app',
    storageBucket: 'pet-circle-app.firebasestorage.app',
    iosBundleId: 'com.example.petCircle',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDakccCpRIASOwcyl0r08xwunRpVU_L8sA',
    appId: '1:999352037269:ios:a02ee9ef3d7fa48d19d09c',
    messagingSenderId: '999352037269',
    projectId: 'pet-circle-app',
    storageBucket: 'pet-circle-app.firebasestorage.app',
    iosBundleId: 'com.example.petCircle',
  );
}
