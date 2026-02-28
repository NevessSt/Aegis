# Project Aegis Security Audit Checklist

## Cryptography & Key Management
- [ ] **Data at Rest**: Isar/Hive local databases must be encrypted using `AesGcm` 256-bit keys.
- [ ] **Key Derivation**: Passwords strictly use Argon2id with random salt.
- [ ] **Secure Storage**: Master Key material is strictly stored in device Secure Enclave (iOS) or hardware-backed Keystore (Android).
- [ ] **Zero-Knowledge Proof**: The server `User` table stores a `passwordHash` for login, and a `wrappedSyncKey`... which is the `SyncKey` encrypted by the `MasterKey`. Server *never* sees plaintext `MasterKey` or `SyncKey`.

## Application Security
- [ ] **Biometrics**: App enforces biometric prompt on resume (AppLifecycleState).
- [ ] **Memory**: Cryptographic keys are purged from RAM immediately after use when locking the app.
- [ ] **Screen Protection**: FLAG_SECURE (Android) and UIWindow modifications (iOS) are enabled to prevent screenshots/screen recording of the app.
- [ ] **Panic Feature**: Entering the panic pin (e.g. `999111=`) via the Calculator Vault instantly purges local DB files and wipes SecureStorage.

## API Security
- [ ] **Transport**: All API traffic strictly requires TLS 1.2+ (HTTPS). No plaintext HTTP allowed.
- [ ] **Replay Attacks**: Encrypted blobs track `lastModified` timestamps and server should validate sequence requests to mitigate replay attacks.
- [ ] **Rate Limiting**: Auth endpoints (`/login`, `/register`) have aggressive rate limiting to prevent brute-force attacks on the hashing layer.
- [ ] **CORS & Helmet**: Express is configured with tight CORS policies and security headers via Helmet.
