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
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyBxpgbJPQPaK_Hlm1wrHN0wXkE-ODiEASA',
    appId: '1:283900206729:web:28842078a3936522dbb058',
    messagingSenderId: '283900206729',
    projectId: 'eva3-iot-francisco-mario',
    authDomain: 'eva3-iot-francisco-mario.firebaseapp.com',
    storageBucket: 'eva3-iot-francisco-mario.firebasestorage.app',
    measurementId: 'G-MZ3WRZYJ3V',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD2eGUB9kLQCLLw4G2TJGyk1OIVX3qZupA',
    appId: '1:446386306991:android:4a6336b7f09276bd575f19',
    messagingSenderId: '446386306991',
    projectId: 'eva3-iot-francisco-mario',
    storageBucket: 'eva3-iot-francisco-mario.appspot.com',
  );
}