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
    apiKey: 'AIzaSyCrjhulqYfbx2xJSbwMonrIvqpSogN3r60',
    appId: '1:793813757199:ios:623c416acd923bf512627a',
    messagingSenderId: '793813757199',
    projectId: 'bws-chat-7469c',
    databaseURL: 'https://bws-chat-7469c-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'bws-chat-7469c.firebasestorage.app',
    iosBundleId: 'com.biweeklystudio.bwsChatExample',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCmkm4ktOBBbb-wjMenfs2gkx1GwQ_H1kY',
    appId: '1:793813757199:android:bb123d8139e08f0412627a',
    messagingSenderId: '793813757199',
    projectId: 'bws-chat-7469c',
    databaseURL: 'https://bws-chat-7469c-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'bws-chat-7469c.firebasestorage.app',
  );

}