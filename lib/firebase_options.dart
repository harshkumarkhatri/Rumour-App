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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyCPn6aOqF5r9GvyZNmiCO6yLKmG7POn23A',
    appId: '1:310926313558:web:fd7666a7c36c6a031953f7',
    messagingSenderId: '310926313558',
    projectId: 'rumour-chat-app-harsh',
    authDomain: 'rumour-chat-app-harsh.firebaseapp.com',
    storageBucket: 'rumour-chat-app-harsh.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDzjTsOJvNmzC2c4O2vYegFOTtahV_gZnc',
    appId: '1:310926313558:android:ac0717e668304ed91953f7',
    messagingSenderId: '310926313558',
    projectId: 'rumour-chat-app-harsh',
    storageBucket: 'rumour-chat-app-harsh.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCGY0lSN97mzo2y7uDNYdSdNHsM3aIBqxc',
    appId: '1:310926313558:ios:c01dd35a4178bf5f1953f7',
    messagingSenderId: '310926313558',
    projectId: 'rumour-chat-app-harsh',
    storageBucket: 'rumour-chat-app-harsh.firebasestorage.app',
    iosBundleId: 'com.example.rumour',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCGY0lSN97mzo2y7uDNYdSdNHsM3aIBqxc',
    appId: '1:310926313558:ios:c01dd35a4178bf5f1953f7',
    messagingSenderId: '310926313558',
    projectId: 'rumour-chat-app-harsh',
    storageBucket: 'rumour-chat-app-harsh.firebasestorage.app',
    iosBundleId: 'com.example.rumour',
  );
}
