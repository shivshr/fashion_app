// File generated manually for Balaji Textile Firebase project.
// ignore_for_file: type=lint

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
        throw UnsupportedError(
          'FirebaseOptions have not been configured for ios.',
        );

      case TargetPlatform.macOS:
        throw UnsupportedError(
          'FirebaseOptions have not been configured for macos.',
        );

      case TargetPlatform.windows:
        return web;

      case TargetPlatform.linux:
        throw UnsupportedError(
          'FirebaseOptions have not been configured for linux.',
        );

      default:
        throw UnsupportedError(
          'FirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyAhwaj6z6HucGjQsKMsxYUMPeqQNae8bVw",
    appId: "1:35290209521:android:888b25326a1e10baced50",
    messagingSenderId: "35290209521",
    projectId: "balaji-textile-and-garme-88714",
    storageBucket: "balaji-textile-and-garme-88714.firebasestorage.app",
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyAhwaj6z6HucGjQsKMsxYUMPeqQNae8bVw",
    appId: "1:35290209521:web:0ebe6b6fa0511160cedd50",
    messagingSenderId: "35290209521",
    projectId: "balaji-textile-and-garme-88714",
    authDomain: "balaji-textile-and-garme-88714.firebaseapp.com",
    storageBucket: "balaji-textile-and-garme-88714.firebasestorage.app",
  );
}