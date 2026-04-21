import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
        return windows;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCr1iY1Eokmzg0ejZ1wrgHroIq7J-z-gUQ',
    appId: '1:63351165061:web:beae9584ad61b0b7d9d9ec',
    messagingSenderId: '63351165061',
    projectId: 'academicapp-9eeb4',
    authDomain: 'academicapp-9eeb4.firebaseapp.com',
    storageBucket: 'academicapp-9eeb4.firebasestorage.app',
    measurementId: 'G-THK8BR9T3K',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDDOWTAxZxlpR9AqNqkZ7R_uxJcNs2b5Gg',
    appId: '1:63351165061:android:65b36a57dcf55c7dd9d9ec',
    messagingSenderId: '63351165061',
    projectId: 'academicapp-9eeb4',
    storageBucket: 'academicapp-9eeb4.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCsbUwJv3Q73ysbqPtr613POtoXKIYjK8w',
    appId: '1:63351165061:ios:095209306f2d734ed9d9ec',
    messagingSenderId: '63351165061',
    projectId: 'academicapp-9eeb4',
    storageBucket: 'academicapp-9eeb4.firebasestorage.app',
    iosBundleId: 'com.example.academicapp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCsbUwJv3Q73ysbqPtr613POtoXKIYjK8w',
    appId: '1:63351165061:ios:095209306f2d734ed9d9ec',
    messagingSenderId: '63351165061',
    projectId: 'academicapp-9eeb4',
    storageBucket: 'academicapp-9eeb4.firebasestorage.app',
    iosBundleId: 'com.example.academicapp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCr1iY1Eokmzg0ejZ1wrgHroIq7J-z-gUQ',
    appId: '1:63351165061:web:4b84d8c915e08a51d9d9ec',
    messagingSenderId: '63351165061',
    projectId: 'academicapp-9eeb4',
    authDomain: 'academicapp-9eeb4.firebaseapp.com',
    storageBucket: 'academicapp-9eeb4.firebasestorage.app',
    measurementId: 'G-8K2416EFKK',
  );

}