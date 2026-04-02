# BWS Chat Example

`bws_chat` 모듈을 테스트하기 위한 예제 앱입니다.

## 사전 준비

- Flutter SDK 3.11.4+
- Firebase 프로젝트 (Firestore, Auth, Storage, Realtime Database 활성화)
- Xcode (iOS 빌드용)

## 설정 방법

### 1. Firebase 프로젝트 연결

```bash
# FlutterFire CLI 설치
dart pub global activate flutterfire_cli

# Firebase 프로젝트 연결 (자동으로 firebase_options.dart 생성)
flutterfire configure
```

### 2. Firebase Console에서 서비스 활성화

- **Authentication** → Sign-in method → **Anonymous** 활성화
- **Cloud Firestore** → 데이터베이스 생성 (테스트 모드)
- **Storage** → 활성화
- **Realtime Database** → 활성화

### 3. 의존성 설치

```bash
flutter pub get
```

### 4. iOS 실행

```bash
cd ios && pod install && cd ..
flutter run
```

## 테스트 방법

1. 앱 실행 후 닉네임 입력 → **시작하기**
2. 친구도 같은 앱을 설치하고 닉네임으로 로그인
3. 오른쪽 위 **+** 버튼 → 상대방 선택 → 채팅 시작

### 친구에게 앱 전달하기

- **같은 Mac**: USB로 친구 폰 연결 → `flutter run`
- **TestFlight**: `flutter build ipa` 후 App Store Connect에 업로드
- **Android**: `flutter build apk` 후 APK 전송
