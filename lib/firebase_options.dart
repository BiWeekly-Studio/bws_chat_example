// TODO: 이 파일은 flutterfire configure 실행 후 자동 생성되는 파일로 교체해야 합니다.
//
// 1. FlutterFire CLI 설치:
//    dart pub global activate flutterfire_cli
//
// 2. Firebase 프로젝트 연결:
//    flutterfire configure
//
// 3. 생성된 firebase_options.dart 파일이 이 파일을 대체합니다.
//
// 자세한 내용: https://firebase.google.com/docs/flutter/setup

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError('이 플랫폼은 아직 지원되지 않습니다.');
    }
  }

  // TODO: 아래 값들을 Firebase Console에서 가져온 실제 값으로 교체하세요.
  // 또는 flutterfire configure 를 실행하면 자동으로 채워집니다.

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: 'YOUR_IOS_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_STORAGE_BUCKET',
    iosBundleId: 'com.biweeklystudio.bwsChatExample',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_ANDROID_API_KEY',
    appId: 'YOUR_ANDROID_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_STORAGE_BUCKET',
  );
}
