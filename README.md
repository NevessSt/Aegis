# Project Aegis 🛡️

A next-generation AI-powered encrypted digital brain application.

Project Aegis sets a new standard for hyper-secure, offline-first personal knowledge management. Built with Flutter for the frontend and a Node.js/Express zero-knowledge backend.

## Core Features Implemented
1. **Military-grade Encryption**: Core `EncryptionService` utilizes AES-256 with CBC mode, with keys stored safely in the platform's secure enclave (`flutter_secure_storage`).
2. **Offline-first Architecture**: `DatabaseHelper` ensures all sensitive data is encrypted *before* it rests in the local `sqflite` database.
3. **Zero-knowledge Cloud Sync**: The Express Backend only ever receives base64-encoded ciphertexts. The cloud provider has zero capability to decrypt or read your memories.
4. **Biometric Security**: Deep integration with `local_auth` enforces fingerprint or facial recognition upon app initialization.
5. **Modern Dynamic UI**: Glassmorphism cards, glowing gradients, and smooth transitional animations built using modern Flutter widgets.

## Folder Structure
```text
C:\Users\pc\Desktop\aegis\
├── backend/
│   ├── routes/
│   │   └── sync.js        # Zero-knowledge syncing endpoints
│   ├── server.js          # Express app entry point
│   ├── package.json       # Dependencies
├── flutter_app/
│   ├── lib/
│   │   ├── core/
│   │   │   ├── encryption_service.dart  # AES-256 implementation
│   │   │   ├── database_helper.dart     # sqflite implementation
│   │   ├── features/home/
│   │   │   └── home_screen.dart         # Glassmorphism dynamic UI
│   │   └── main.dart                    # App Shell + Biometric Lock
│   ├── pubspec.yaml       # Project dependencies
```

## How to Run & Build Internally

**Flutter Sandbox Note**: The pure Dart/Flutter source is comprehensively built. However, because sandbox environments block heavy external downloads, the underlying `ios/` and `android/` shell directories could not be dynamically fetched by `flutter doctor`.

To fully **build and compile** the `.apk` (Android) and `.ipa` (iOS) files on your personal machine with internet access, run the following commands sequentially inside `C:\Users\pc\Desktop\aegis\flutter_app`:

### 1. Generate Native Platform Code
Run this command to automatically generate the `ios` and `android` directories using the supplied codebase:
```bash
flutter create --org com.aegis --project-name aegis_app .
```

### 2. Fetch Dependencies
```bash
flutter pub get
```

### 3. Build for Android
```bash
flutter build apk --release
```
_The final APK will be located at `build/app/outputs/flutter-apk/app-release.apk`._

### 4. Build for iOS (Requires macOS)
```bash
flutter build ipa --release
```

## Backend Services
1. `cd backend` -> `npm install` -> `npm run start`
