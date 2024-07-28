// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDQpGljAT5uc4C6m-0U0zHBDxlUg7z_jC8',
    appId: '1:427398837926:web:758841f84bcf0415c0e667',
    messagingSenderId: '427398837926',
    projectId: 'stocksync-8a03e',
    authDomain: 'stocksync-8a03e.firebaseapp.com',
    storageBucket: 'stocksync-8a03e.appspot.com',
    measurementId: 'G-NY3PWS7DD6',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCE0VY2WQ1P1Ue7YG7lGx67vH2Li1hBG9A',
    appId: '1:427398837926:android:b2789da7f290aff4c0e667',
    messagingSenderId: '427398837926',
    projectId: 'stocksync-8a03e',
    storageBucket: 'stocksync-8a03e.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCreENdv9Y2NDt5EsxB2nRhhAKTtp3mje0',
    appId: '1:427398837926:ios:c9de4a43ee2024bcc0e667',
    messagingSenderId: '427398837926',
    projectId: 'stocksync-8a03e',
    storageBucket: 'stocksync-8a03e.appspot.com',
    iosBundleId: 'com.example.stocksync',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCreENdv9Y2NDt5EsxB2nRhhAKTtp3mje0',
    appId: '1:427398837926:ios:c9de4a43ee2024bcc0e667',
    messagingSenderId: '427398837926',
    projectId: 'stocksync-8a03e',
    storageBucket: 'stocksync-8a03e.appspot.com',
    iosBundleId: 'com.example.stocksync',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDQpGljAT5uc4C6m-0U0zHBDxlUg7z_jC8',
    appId: '1:427398837926:web:8d7fad9b57c86813c0e667',
    messagingSenderId: '427398837926',
    projectId: 'stocksync-8a03e',
    authDomain: 'stocksync-8a03e.firebaseapp.com',
    storageBucket: 'stocksync-8a03e.appspot.com',
    measurementId: 'G-0NKP71X4FZ',
  );

}