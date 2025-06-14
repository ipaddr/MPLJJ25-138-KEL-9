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
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBULiUqJgeDzEzCnTP-v_oZZF8kalnRJpg',
    appId: '1:298788198616:android:92c1a4d349d9854be8dfad',
    messagingSenderId: '298788198616',
    projectId: 'giziku-c2e7c',
    storageBucket: 'giziku-c2e7c.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBexAvEuZZHwcvRmQxxbxG_hcj-vE8nXjU',
    appId: '1:298788198616:ios:d518c25372cd1a65e8dfad',
    messagingSenderId: '298788198616',
    projectId: 'giziku-c2e7c',
    storageBucket: 'giziku-c2e7c.firebasestorage.app',
    iosBundleId: 'com.example.giziku',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBexAvEuZZHwcvRmQxxbxG_hcj-vE8nXjU',
    appId: '1:298788198616:ios:d518c25372cd1a65e8dfad',
    messagingSenderId: '298788198616',
    projectId: 'giziku-c2e7c',
    storageBucket: 'giziku-c2e7c.firebasestorage.app',
    iosBundleId: 'com.example.giziku',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBHOKmnzVJglcYEyQt5nuE7fa8hVC_It6Y',
    appId: '1:298788198616:web:d863105f443d5680e8dfad',
    messagingSenderId: '298788198616',
    projectId: 'giziku-c2e7c',
    authDomain: 'giziku-c2e7c.firebaseapp.com',
    storageBucket: 'giziku-c2e7c.firebasestorage.app',
    measurementId: 'G-40E817PVD0',
  );
}
